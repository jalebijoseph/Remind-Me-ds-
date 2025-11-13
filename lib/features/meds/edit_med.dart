import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../data/supa.dart';
import 'schedule_picker.dart';

class EditMedPage extends StatefulWidget {
  final Map<String, dynamic> med;
  const EditMedPage({super.key, required this.med});

  @override
  State<EditMedPage> createState() => _EditMedPageState();
}

class _EditMedPageState extends State<EditMedPage> {
  late TextEditingController nameCtrl;
  late TextEditingController purposeCtrl;
  late TextEditingController conditionCtrl;
  late TextEditingController dosageCtrl;
  late TextEditingController unitCtrl;
  late TextEditingController pillsCtrl;
  late TextEditingController thresholdCtrl;
  DateTime? obtained;
  List<String> times = [];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.med['name'] ?? '');
    purposeCtrl = TextEditingController(text: widget.med['purpose'] ?? '');
    conditionCtrl = TextEditingController(text: widget.med['condition'] ?? '');
    dosageCtrl = TextEditingController(text: (widget.med['dosage_amount']?.toString() ?? ''));
    unitCtrl = TextEditingController(text: widget.med['dosage_unit'] ?? 'mg');
    pillsCtrl = TextEditingController(text: (widget.med['pills_on_hand']?.toString() ?? '0'));
    thresholdCtrl = TextEditingController(text: (widget.med['refill_threshold']?.toString() ?? '10'));
    if (widget.med['date_obtained'] != null) {
      try {
        final dt = DateTime.parse(widget.med['date_obtained']);
        obtained = DateTime(dt.year, dt.month, dt.day);
      } catch (_) {}
    }
    final rawTimes = widget.med['times_local'];
    if (rawTimes is List) {
      times = rawTimes.map((e) => e.toString()).toList();
    }
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

  Future<void> _update() async {
    await supa.from('medications').update({
      'name': nameCtrl.text.trim(),
      'purpose': purposeCtrl.text.trim().isEmpty ? null : purposeCtrl.text.trim(),
      'condition': conditionCtrl.text.trim().isEmpty ? null : conditionCtrl.text.trim(),
      'dosage_amount': double.tryParse(dosageCtrl.text.trim()) ?? 0,
      'dosage_unit': unitCtrl.text.trim(),
      'pills_on_hand': int.tryParse(pillsCtrl.text.trim()) ?? 0,
      'refill_threshold': int.tryParse(thresholdCtrl.text.trim()) ?? 10,
      'date_obtained': obtained == null
          ? null
          : DateTime(obtained!.year, obtained!.month, obtained!.day).toIso8601String(),
      'times_local': times,
    }).eq('id', widget.med['id']);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    await supa.from('medications').delete().eq('id', widget.med['id']);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = obtained == null
        ? 'Pick Date Obtained'
        : 'Obtained: ${obtained!.year}-${obtained!.month.toString().padLeft(2, '0')}-${obtained!.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Medication'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'Purpose')),
            const SizedBox(height: 10),
            TextField(controller: conditionCtrl, decoration: const InputDecoration(labelText: 'Illness / Condition')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Dosage'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit'))),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: pillsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pills on hand'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: thresholdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Refill warn at'),
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
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Edit Reminder Times'),
              onPressed: () async {
                final result = await showDialog<List<String>>(
                  context: context,
                  builder: (_) => const SchedulePickerDialog(),
                );
                if (result != null) setState(() => times = result);
              },
            ),
            if (times.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(spacing: 8, children: times.map((t) => Chip(label: Text(t))).toList()),
              ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _update, child: const Text('Save Changes')),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: _delete,
              child: const Text('Delete Medicine'),
            ),
          ],
        ),
      ),
    );
  }
}
