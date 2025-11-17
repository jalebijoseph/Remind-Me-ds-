import 'package:flutter/material.dart';

class PastelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  const PastelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? scheme.primary : Colors.transparent,
          foregroundColor: filled ? Colors.black : scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
