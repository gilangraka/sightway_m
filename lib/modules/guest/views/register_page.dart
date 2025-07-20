import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/images.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_primary.dart';
import 'package:sightway_mobile/shared/widgets/inputs/alt_select_option_field.dart';
import 'package:sightway_mobile/shared/widgets/inputs/custom_input_field.dart';
import 'package:sightway_mobile/shared/widgets/navigations/custom_app_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const List<String> roles = ['Penyandang', 'Pemantau'];
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String selectedRole = roles[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Register'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(AppImages.logoBlank, height: 80),
            const SizedBox(height: 24),
            const Text(
              "Register sebagai :",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            AltSelectOptionField(
              options: roles,
              selectedValue: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),

            const SizedBox(height: 10),
            const Text(
              "Data User :",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            CustomInputField(
              icon: Icons.email,
              placeholder: 'Masukkan Email',
              controller: emailController,
            ),
            const SizedBox(height: 10),
            CustomInputField(
              icon: Icons.person,
              placeholder: 'Masukkan Nama',
              controller: nameController,
            ),
            const SizedBox(height: 10),
            CustomInputField(
              icon: Icons.lock,
              placeholder: 'Masukkan Password',
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            CustomInputField(
              icon: Icons.lock,
              placeholder: 'Konfirmasi Password',
              controller: confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ButtonPrimary(label: 'Register', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
