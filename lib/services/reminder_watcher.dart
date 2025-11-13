import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/supa.dart';
import 'notifier.dart';

/// While the app is open:
/// - listens to medications changes (insert/update/delete)
/// - sets timers for today's/tomorrow's dose times
/// - shows in-app snackbars exactly at dose time
class ReminderWatcher {
  static final ReminderWatcher _instance = ReminderWatcher._();
  ReminderWatcher._();
  factory ReminderWatcher() => _instance;

  RealtimeChannel? _channel;
  final Map<String, Timer> _timers = {}; // key = medId|HH:mm|yyyy-MM-dd

  Future<void> start() async {
    await _rescheduleAll();

    // Live changes -> reschedule
    _channel ??= supa
        .channel('meds-watch')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'medications',
        callback: (_) => _rescheduleAll(),
      )
      ..subscribe();

    // Safety: refresh every 30 minutes (in case time zone / clock drift)
    Timer.periodic(const Duration(minutes: 30), (_) => _rescheduleAll());
  }

  Future<void> _rescheduleAll() async {
    // cancel existing timers
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();

    final meds = await getAllMeds();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (final m in meds) {
      final id = m['id'] as String;
      final name = (m['name'] ?? 'your medication').toString();
      final times = (m['times_local'] as List?)
              ?.map((e) => e.toString())
              .where((s) => s.contains(':'))
              .toList() ??
          const <String>[];

      for (final t in times) {
        final hhmm = t.split(':');
        if (hhmm.length != 2) continue;
        // create reminder for today or tomorrow
        DateTime when = DateTime(today.year, today.month, today.day,
            int.parse(hhmm[0]), int.parse(hhmm[1]));
        if (when.isBefore(now)) {
          when = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, when.hour, when.minute);
        }

        final key = '$id|$t|${when.toIso8601String().substring(0,10)}';
        final dur = when.difference(now);
        _timers[key] = Timer(dur, () {
          Notifier.inApp('⏰ Time to take $name ($t)');
        });
      }

      // low stock gentle nudge at 9:00 today if applicable and still upcoming
      final pills = (m['pills_on_hand'] ?? 0) as int;
      final threshold = (m['refill_threshold'] ?? 10) as int;
      if (pills <= threshold) {
        final nineAM = DateTime(today.year, today.month, today.day, 9, 0);
        if (now.isBefore(nineAM)) {
          final key = '$id|low|${nineAM.toIso8601String().substring(0,10)}';
          _timers[key] = Timer(nineAM.difference(now), () {
            Notifier.inApp('⚠️ Low stock on $name: $pills pills left — consider refilling.');
          });
        }
      }
    }
  }
}
