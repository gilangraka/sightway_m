import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/images.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_primary.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_white.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.logo, height: 180),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ButtonPrimary(
                    label: 'Login',
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ButtonWhite(
                    label: 'Register',
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
