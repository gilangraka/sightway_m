import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/modules/guest/views/login_page.dart';
import 'package:sightway_mobile/modules/guest/views/register_page.dart';
import 'package:sightway_mobile/modules/guest/views/welcome_page.dart';
import 'package:sightway_mobile/modules/pemantau/views/pemantau_detail_penyandang.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_index_page.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_mail_page.dart';
import 'package:sightway_mobile/modules/penyandang/views/qr_scanner_page.dart';
import 'package:sightway_mobile/modules/pemantau/views/pemantau_index_page.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Permission.location.request();
  await FirebaseService.init();

  // Ambil initial route berdasarkan shared preferences
  final initialRoute = await getInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> getInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final role = prefs.getString('user_role');

  if (token == null) {
    return '/';
  }

  if (role == 'penyandang') {
    return '/penyandang';
  } else if (role == 'pemantau') {
    return '/pemantau'; // Pastikan rute ini nanti ada juga
  }

  // fallback default
  return '/';
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

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
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/penyandang': (context) => const PenyandangIndexPage(),
        '/scan-qr': (context) => const QrScannerPage(),
        '/pemantau': (context) => const PemantauIndexPage(),
        '/mail': (context) => const PenyandangMailPage(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        if (uri.pathSegments.length == 3 &&
            uri.pathSegments[0] == 'pemantau' &&
            uri.pathSegments[1] == 'detail-penyandang') {
          final userId = uri.pathSegments[2];
          return MaterialPageRoute(
            builder: (_) => PemantauDetailPenyandangPage(userId: userId),
          );
        }

        // fallback
        return null;
      },
    );
  }
}
