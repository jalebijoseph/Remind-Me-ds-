// lib/screens/add_edit_med_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/supabase_service.dart';
import '../services/reminder_service.dart';
import '../widgets/pastel_button.dart';
import '../widgets/pastel_text_field.dart';
import '../models/medication.dart';

class AddEditMedScreen extends StatefulWidget {
  final Medication? existing;
  final Future<void> Function()? onSaved;

  const AddEditMedScreen({
    super.key,
    this.existing,
    this.onSaved,
  });

  @override
  State<AddEditMedScreen> createState() => _AddEditMedScreenState();
}

class _AddEditMedScreenState extends State<AddEditMedScreen> {
  final nameC = TextEditingController();
  final purposeC = TextEditingController();
  final illnessC = TextEditingController();
  final dosageC = TextEditingController();
  final pillsTotalC = TextEditingController();
  final pillsRemainingC = TextEditingController();
  final thresholdC = TextEditingController();
  final scheduleC = TextEditingController();

  bool saving = false;
  final SupabaseService db = SupabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final m = widget.existing!;
      nameC.text = m.name;
      purposeC.text = m.purpose;
      illnessC.text = m.illness;
      dosageC.text = m.dosageMg.toString();
      pillsTotalC.text = m.pillsTotal.toString();
      pillsRemainingC.text = m.pillsRemaining.toString();
      thresholdC.text = m.refillThreshold.toString();
      scheduleC.text = m.scheduleTime;
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    purposeC.dispose();
    illnessC.dispose();
    dosageC.dispose();
    pillsTotalC.dispose();
    pillsRemainingC.dispose();
    thresholdC.dispose();
    scheduleC.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t == null) return;

    final parsed = DateFormat.jm().parse(t.format(context));
    scheduleC.text = DateFormat.Hm().format(parsed);
    setState(() {});
  }

  Future<void> saveMed() async {
    setState(() => saving = true);

    int parseInt(TextEditingController c) =>
        int.tryParse(c.text.trim()) ?? 0;

final medMap = {
  'name': nameC.text.trim(),
  'purpose': purposeC.text.trim(),
  'illness': illnessC.text.trim(),
  // 👇 match the DB column name
  'dosage': parseInt(dosageC),
  'pills_total': parseInt(pillsTotalC),
  'pills_remaining': parseInt(pillsRemainingC),
  'refill_threshold': parseInt(thresholdC),
  'schedule_time': scheduleC.text.trim(),
  'start_date': DateTime.now().toIso8601String(),
};

    try {
      int id;
      if (widget.existing == null) {
        // create new row
        id = await db.addMedication(medMap);
      } else {
        // update row
        id = widget.existing!.id;
        await db.updateMedication(id, medMap);
        await reminderService.cancelReminder(id);
      }

      await reminderService.scheduleDailyReminder(
        id: id,
        name: nameC.text.trim(),
        time: scheduleC.text.trim(),
      );

      final onSaved = widget.onSaved;
      if (onSaved != null) {
        await onSaved();
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // show what actually went wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save medication: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Medication" : "Add Medication"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              PastelTextField(controller: nameC, label: "Name"),
              const SizedBox(height: 12),
              PastelTextField(controller: purposeC, label: "Purpose"),
              const SizedBox(height: 12),
              PastelTextField(controller: illnessC, label: "Illness"),
              const SizedBox(height: 12),
              PastelTextField(
                controller: dosageC,
                label: "Dosage (mg)",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              PastelTextField(
                controller: pillsTotalC,
                label: "Total Pills",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              PastelTextField(
                controller: pillsRemainingC,
                label: "Pills Remaining",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              PastelTextField(
                controller: thresholdC,
                label: "Refill Alert Below",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PastelTextField(
                      controller: scheduleC,
                      label: "Time (HH:MM)",
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              saving
                  ? const Center(child: CircularProgressIndicator())
                  : PastelButton(
                      label: isEdit ? "Save Changes" : "Add Medication",
                      onPressed: () {
                        // closure returns void → no “void result” error
                        saveMed();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
