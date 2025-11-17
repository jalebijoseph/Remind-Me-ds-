import 'package:flutter/material.dart';

import '../models/medication.dart';
import '../services/supabase_service.dart';
import '../services/reminder_service.dart';
import 'add_edit_med_screen.dart';

class MedDetailScreen extends StatelessWidget {
  final Medication med;
  final Future<void> Function()? onChanged;

  const MedDetailScreen({
    super.key,
    required this.med,
    this.onChanged,
  });

  Future<void> _refreshParent() async {
    if (onChanged != null) {
      await onChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final SupabaseService db = SupabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(med.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Purpose: ${med.purpose}"),
            Text("Illness: ${med.illness}"),
            Text("Dosage: ${med.dosageMg} mg"),
            Text("Pills: ${med.pillsRemaining}/${med.pillsTotal}"),
            Text("Refill alert below: ${med.refillThreshold}"),
            Text("Time: ${med.scheduleTime}"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditMedScreen(
                      existing: med,
                      onSaved: _refreshParent,
                    ),
                  ),
                );
              },
              child: const Text("Edit"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                await db.deleteMedication(med.id);
                await reminderService.cancelReminder(med.id);
                await _refreshParent();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }
}
