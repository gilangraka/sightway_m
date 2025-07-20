import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/const.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_primary.dart';
import 'package:sightway_mobile/shared/widgets/inputs/custom_input_field.dart';
import 'package:sightway_mobile/shared/widgets/inputs/custom_select_field.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final List<String> roles = ['Penyandang', 'Pemantau'];
    String selectedRole = roles[0];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Image.asset(AppImages.logo, height: 80),
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

            CustomSelectField(
              icon: Icons.person,
              placeholder: 'Login Sebagai',
              options: roles,
              selectedValue: selectedRole,
              onChanged: (value) {
                selectedRole = value!;
              },
            ),
            const SizedBox(height: 32),

            ButtonPrimary(
              label: 'Login',
              onPressed: () {
                // TODO: handle login
              },
            ),
          ],
        ),
      ),
    );
  }
}
