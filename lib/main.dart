import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/modules/guest/views/login_page.dart';
import 'package:sightway_mobile/modules/guest/views/register_page.dart';
import 'package:sightway_mobile/modules/guest/views/welcome_page.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_index_page.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_mail_page.dart';
import 'package:sightway_mobile/modules/penyandang/views/qr_scanner_page.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    // Inisialisasi saat service mulai
    print("Foreground service started");
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Aksi berkala tiap beberapa detik
    print("Foreground service is running: $timestamp");
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isCancelled) async {
    print("Foreground service destroyed");
  }

  @override
  void onButtonPressed(String id) {
    print('Button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterForegroundTask.startService(
    notificationTitle: 'Aplikasi Berjalan',
    notificationText: 'Menjalankan layanan latar depan.',
    callback: startCallback,
  );

  await Permission.location.request();
  await FirebaseService.init();
  WakelockPlus.enable();

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

  if (role == 'Penyandang') {
    return '/penyandang';
  } else if (role == 'Pemantau') {
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

        // Tambahkan nanti halaman pemantau kalau ada
        '/pemantau': (context) =>
            const Placeholder(), // ganti dengan halaman sebenarnya

        '/mail': (context) => const PenyandangMailPage(),
      },
    );
  }
}
