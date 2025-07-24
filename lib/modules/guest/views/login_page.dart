import 'package:flutter/material.dart';
import 'package:sightway_mobile/modules/guest/controllers/auth_controller.dart';
import 'package:sightway_mobile/shared/constants/const.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_primary.dart';
import 'package:sightway_mobile/shared/widgets/inputs/alt_select_option_field.dart';
import 'package:sightway_mobile/shared/widgets/inputs/custom_input_field.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final List<String> roles = ['Penyandang', 'Pemantau'];
  String selectedRole = 'Penyandang';
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Image.asset(AppImages.logoBlank, height: 80),
            const SizedBox(height: 32),

            CustomInputField(
              icon: Icons.email,
              placeholder: 'Masukkan Email',
              controller: emailController,
            ),

            const SizedBox(height: 16),

            CustomInputField(
              icon: Icons.lock,
              placeholder: 'Masukkan Password',
              isPassword: true,
              controller: passwordController,
            ),
            const SizedBox(height: 16),

            const Text(
              "Login sebagai :",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            AltSelectOptionField(
              options: roles,
              selectedValue: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),
            const SizedBox(height: 32),

            ButtonPrimary(
              label: 'Login',
              onPressed: () {
                _authController.loginUser(
                  context: context,
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  role: selectedRole,
                );
              },
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum memiliki akun?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    "Daftar",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
