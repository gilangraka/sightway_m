import 'package:flutter/material.dart';
import 'package:sightway_mobile/modules/guest/views/login_page.dart';
import 'package:sightway_mobile/modules/guest/views/register_page.dart';
import 'package:sightway_mobile/modules/guest/views/welcome_page.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_index_page.dart';
import 'package:sightway_mobile/modules/penyandang/views/qr_scanner_page.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
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
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        '/penyandang': (context) => const PenyandangIndexPage(),
        '/scan-qr': (context) => const QrScannerPage(),
      },
    );
  }
}
