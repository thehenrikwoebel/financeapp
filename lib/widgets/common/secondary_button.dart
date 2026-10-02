import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isActive = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? Colors.blue : Colors.grey,
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: isActive ? Colors.blue : Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: isActive ? onPressed : null,
      child: Text(label),
    );
  }
}
