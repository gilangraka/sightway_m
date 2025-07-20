import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/images.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_primary.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_white.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xF5F8FCFF,
      ), // Warna latar belakang sesuai gambar
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.logo, height: 180),
                const SizedBox(height: 32),
                const Text(
                  'Sightway',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1E28),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Navigate with Clarity\nConnect with Confidence',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF2C2F3B)),
                ),
                const SizedBox(height: 48),
                ButtonPrimary(
                  label: 'Login',
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                const SizedBox(height: 16),
                ButtonWhite(
                  label: 'Register',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
