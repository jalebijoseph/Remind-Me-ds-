import 'package:flutter/material.dart';

class SchedulePickerDialog extends StatefulWidget {
  const SchedulePickerDialog({super.key});
  @override
  State<SchedulePickerDialog> createState() => _SchedulePickerDialogState();
}

class _SchedulePickerDialogState extends State<SchedulePickerDialog> {
  final List<String> times = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Times'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (times.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Add one or more times for when you take this medicine.'),
              ),
            ...times.map((t) => ListTile(
                  title: Text(t),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => times.remove(t)),
                  ),
                )),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Time'),
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) {
                  final hh = picked.hour.toString().padLeft(2, '0');
                  final mm = picked.minute.toString().padLeft(2, '0');
                  setState(() => times.add('$hh:$mm'));
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, times), child: const Text('Done')),
      ],
    );
  }
}
