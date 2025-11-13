import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../data/supa.dart';
import '../../services/dose_generator.dart';
import 'schedule_picker.dart';

class AddMedPage extends StatefulWidget {
  const AddMedPage({super.key});
  @override
  State<AddMedPage> createState() => _AddMedPageState();
}

class _AddMedPageState extends State<AddMedPage> {
  final nameCtrl = TextEditingController();
  final purposeCtrl = TextEditingController();
  final conditionCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final unitCtrl = TextEditingController(text: 'mg');
  final pillsCtrl = TextEditingController(text: '0');
  final thresholdCtrl = TextEditingController(text: '10');

  DateTime? obtained;
  List<String> times = [];

  @override
  void dispose() {
    nameCtrl.dispose();
    purposeCtrl.dispose();
    conditionCtrl.dispose();
    dosageCtrl.dispose();
    unitCtrl.dispose();
    pillsCtrl.dispose();
    thresholdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: obtained ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => obtained = picked);
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    final doseAmt = num.tryParse(dosageCtrl.text.trim());
    final unit = unitCtrl.text.trim();
    final pills = int.tryParse(pillsCtrl.text.trim()) ?? 0;
    final threshold = int.tryParse(thresholdCtrl.text.trim()) ?? 10;

    if (name.isEmpty || doseAmt == null || unit.isEmpty || times.isEmpty || obtained == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name, dosage+unit, date obtained, and at least one time.')),
      );
      return;
    }

    final inserted = await supa.from('medications').insert({
      'user_id': supa.auth.currentUser!.id,
      'name': name,
      'purpose': purposeCtrl.text.trim().isEmpty ? null : purposeCtrl.text.trim(),
      'condition': conditionCtrl.text.trim().isEmpty ? null : conditionCtrl.text.trim(),
      'dosage_amount': doseAmt,
      'dosage_unit': unit,
      'pills_on_hand': pills,
      'refill_threshold': threshold,
      'is_active': true,
      'start_date': DateTime.now().toIso8601String(),
      'date_obtained': DateTime(obtained!.year, obtained!.month, obtained!.day).toIso8601String(),
      'times_local': times,
    }).select().single();

    await generateFixedTimesDoses(
      medId: inserted['id'] as String,
      times24h: times,
      daysAhead: 7,
      quantityPerDose: doseAmt,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine added ✅')));
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = obtained == null
        ? 'Pick Date Obtained *'
        : 'Obtained: ${obtained!.year}-${obtained!.month.toString().padLeft(2, '0')}-${obtained!.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine'), backgroundColor: AppColors.primary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicine Name *')),
          TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'Purpose')),
          TextField(controller: conditionCtrl, decoration: const InputDecoration(labelText: 'Illness / Condition')),
          Row(children: [
            Expanded(
              child: TextField(
                controller: dosageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Dosage Amount *'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: unitCtrl,
                decoration: const InputDecoration(labelText: 'Unit (mg, mL, etc.) *'),
              ),
            ),
          ]),
          Row(children: [
            Expanded(
              child: TextField(
                controller: pillsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pills on hand *'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: thresholdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Refill warn at (pills)'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(dateLabel),
            onPressed: _pickDate,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.access_time),
            label: const Text('Select Times *'),
            onPressed: () async {
              final selected = await showDialog<List<String>>(
                context: context,
                builder: (_) => const SchedulePickerDialog(),
              );
              if (selected != null && selected.isNotEmpty) setState(() => times = selected);
            },
          ),
          if (times.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(spacing: 8, children: times.map((t) => Chip(label: Text(t))).toList()),
            ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
