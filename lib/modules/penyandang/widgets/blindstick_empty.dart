import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/const.dart';

class BlindstickEmpty extends StatelessWidget {
  final VoidCallback mailOnClick;

  const BlindstickEmpty({super.key, required this.mailOnClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: mailOnClick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: const [
            Icon(
              Icons.center_focus_strong,
              size: 40,
              color: AppColors.background,
            ),
            SizedBox(height: 12),
            Text(
              "Kamu belum memiliki Blindstick",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
