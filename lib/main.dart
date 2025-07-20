import 'package:flutter/material.dart';
import 'package:sightway_mobile/modules/guest/views/login_page.dart';
import 'package:sightway_mobile/modules/guest/views/welcome_page.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sightway App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
