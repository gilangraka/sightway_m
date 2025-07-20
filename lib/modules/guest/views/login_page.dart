import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'package:sightway_mobile/shared/widgets/buttons/button_primary.dart';
import 'package:sightway_mobile/shared/widgets/custom_input_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = 'Penyandang';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back, size: 32),
              ),
            ),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C2A39),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Email atau Username"),
                    const SizedBox(height: 8),
                    CustomInputField(
                      icon: Icons.person,
                      placeholder: "Masukkan Email atau Username",
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    const Text("Password"),
                    const SizedBox(height: 8),
                    CustomInputField(
                      icon: Icons.lock,
                      placeholder: "Masukkan Password",
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    const Text("Login sebagai :"),
                    const SizedBox(height: 8),
                    CustomInputField(
                      icon: Icons.person_outline,
                      placeholder: "Pilih Peran",
                      isSelect: true,
                      options: const ['Penyandang', 'Pemantau'],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ButtonPrimary(
                      label: "Login",
                      onPressed: () {
                        // handle login
                        print('Email: ${emailController.text}');
                        print('Password: ${passwordController.text}');
                        print('Role: $selectedRole');
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum memiliki akun? "),
                          GestureDetector(
                            onTap: () {
                              // pindah ke halaman daftar
                            },
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
