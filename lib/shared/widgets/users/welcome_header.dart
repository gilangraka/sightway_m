import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

class WelcomeHeader extends StatelessWidget {
  final String imgUrl;
  final String role;
  final String name;
  final VoidCallback mailOnClick;

  const WelcomeHeader({
    super.key,
    required this.imgUrl,
    required this.role,
    required this.name,
    required this.mailOnClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 12),

        // Teks dan badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.text),
                  children: [
                    const TextSpan(text: 'Selamat datang,\n'),
                    TextSpan(
                      text: '$name!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tombol mail
        InkWell(
          onTap: mailOnClick,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: AppColors.background,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
