import 'package:flutter/material.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/primary_button.dart';

class LoadMoreButton extends StatelessWidget {
  const LoadMoreButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: AppStrings.get('more_button_text'),
      onPressed: onPressed,
      icon: Icons.expand_more,
    );
  }
}
