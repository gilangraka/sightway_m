import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'button.dart';

class ButtonPrimary extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const ButtonPrimary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      label: label,
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      textColor: AppColors.white,
      icon: icon,
    );
  }
}
