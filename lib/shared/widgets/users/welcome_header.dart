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
        // Foto profil
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imgUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600]),
              );
            },
          ),
        ),

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
