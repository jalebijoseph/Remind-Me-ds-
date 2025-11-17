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

  Future<void> _notifyParent() async {
    if (onChanged != null) {
      await onChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = SupabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(med.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text("Purpose: ${med.purpose}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Illness: ${med.illness}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Dosage: ${med.dosageMg} mg", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Pills Remaining: ${med.pillsRemaining}/${med.pillsTotal}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Refill Alert At: ${med.refillThreshold} pills",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Daily Time: ${med.scheduleTime}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditMedScreen(
                      existing: med,
                      onSaved: _notifyParent,
                    ),
                  ),
                );
              },
              child: const Text("Edit"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                await db.deleteMedication(med.id);
                await reminderService.cancelReminder(med.id);
                await _notifyParent();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }
}
