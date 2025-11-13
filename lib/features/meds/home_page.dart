import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_colors.dart';
import '../../data/supa.dart';
import 'add_med.dart';
import 'edit_med.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<List<Map<String, dynamic>>> _medsStream() {
    final uid = supa.auth.currentUser?.id ?? '';
    return supa
        .from('medications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at')
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  int _dailyDoseCount(Map<String, dynamic> m) {
    final times = m['times_local'];
    if (times is List) return times.length;
    return 0;
  }

  DateTime? _runOutDate(Map<String, dynamic> m) {
    final pills = (m['pills_on_hand'] ?? 0) as int;
    final perDay = _dailyDoseCount(m);
    if (pills <= 0 || perDay <= 0) return null;
    final daysLeft = (pills / perDay).floor();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysLeft));
  }

  Future<void> _markTaken(Map<String, dynamic> m) async {
    final id = m['id'] as String;
    final pills = (m['pills_on_hand'] ?? 0) as int;
    final newCount = (pills - 1).clamp(0, 1 << 30);
    await updateMed(id, {'pills_on_hand': newCount});

    final quotes = [
      'You did it! Proud of you 💪',
      'Consistency is your superpower ✨',
      'One step closer to feeling great 🌸',
      'Small habits, big wins 🌟',
    ];
    final q = quotes[DateTime.now().second % quotes.length];

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$q  (Remaining: $newCount)'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async => updateMed(id, {'pills_on_hand': pills}),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Medications'),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedPage()));
          // stream auto-updates; no manual refresh needed
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _medsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final meds = snap.data ?? [];
          if (meds.isEmpty) {
            return const Center(child: Text('No medications added yet!'));
          }
          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, i) {
              final m = meds[i];
              final name = m['name'] ?? 'Unknown';
              final purpose = (m['purpose'] ?? '').toString();
              final condition = (m['condition'] ?? '').toString();
              final dosage = (m['dosage_amount'] != null && m['dosage_unit'] != null)
                  ? '${m['dosage_amount']} ${m['dosage_unit']}'
                  : '';
              final pills = (m['pills_on_hand'] ?? 0) as int;
              final threshold = (m['refill_threshold'] ?? 10) as int;
              final perDay = _dailyDoseCount(m);
              final runOut = _runOutDate(m);
              final lowStock = pills <= threshold;

              final subtitleLines = <String>[];
              if (purpose.isNotEmpty) subtitleLines.add('Purpose: $purpose');
              if (condition.isNotEmpty) subtitleLines.add('Condition: $condition');
              if (dosage.isNotEmpty) subtitleLines.add('Dosage: $dosage');
              subtitleLines.add('Times/day: $perDay');
              subtitleLines.add('Pills on hand: $pills');
              if (runOut != null) {
                subtitleLines.add(
                    'Est. run-out: ${runOut.year}-${runOut.month.toString().padLeft(2, '0')}-${runOut.day.toString().padLeft(2, '0')}');
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: lowStock ? AppColors.danger.withOpacity(0.1) : AppColors.secondary.withOpacity(0.18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      name,
                      style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(subtitleLines.join('\n')),
                    isThreeLine: true,
                    leading: lowStock
                        ? const Icon(Icons.warning_amber_rounded, color: AppColors.danger)
                        : const Icon(Icons.medication, color: AppColors.textDeep),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit, color: AppColors.textDeep),
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => EditMedPage(med: m)));
                            // stream auto-updates after save
                          },
                        ),
                        ElevatedButton(
                          onPressed: () => _markTaken(m),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Taken'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
