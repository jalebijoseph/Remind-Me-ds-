import 'notifier.dart';

DateTime _trimMin(DateTime t) => DateTime(t.year, t.month, t.day, t.hour, t.minute);

Future<void> generateFixedTimesDoses({
  required String medId,
  required List<String> times24h,   // e.g., ['08:00','20:30']
  int daysAhead = 7,
  num quantityPerDose = 1,          // reserved for inventory math if you want it later
}) async {
  final now = DateTime.now();
  for (int d = 0; d < daysAhead; d++) {
    final day = DateTime(now.year, now.month, now.day + d);
    for (final t in times24h) {
      final parts = t.split(':');
      final when = _trimMin(DateTime(
        day.year, day.month, day.day, int.parse(parts[0]), int.parse(parts[1]),
      ));
      await Notifier.scheduleOnce(
        id: '$medId-$when',
        when: when,
        title: 'Dose Reminder',
        body: 'Time to take your medication',
      );
    }
  }
}
