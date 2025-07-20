import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'button.dart';

class ButtonWhite extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const ButtonWhite({
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
      backgroundColor: AppColors.white,
      textColor: AppColors.text,
      borderColor: Colors.grey.shade300,
      icon: icon,
    );
  }
}
