import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sightway_mobile/services/dio_client.dart';
import 'package:sightway_mobile/services/firebase_service.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

class AuthController {
  final Dio _dio = DioClient.client;

  Future<void> loginUser({
    required BuildContext context,
    required String email,
    required String password,
    required String role,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _showSnackbar(context, 'Email dan password wajib diisi!');
      return;
    }

    final endpoint = role.toLowerCase() == 'penyandang'
        ? '/mobile/auth/login/penyandang'
        : '/mobile/auth/login/pemantau';

    try {
      final response = await _dio.post(
        endpoint,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      final token = data['access_token'];
      final user = data['user'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_id', user['id']);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);

        // ✅ Ambil token FCM
        final fcmToken = await FirebaseMessaging.instance.getToken();

        // ✅ Kirim ke Realtime Database sesuai role
        if (role.toLowerCase() == 'penyandang') {
          await FirebaseService.sendDataPenyandangToFirebase(
            user['id'],
            user['name'],
            user['email'],
            fcmToken ?? '',
          );
        } else {
          await FirebaseService.sendDataPemantauToFirebase(
            user['id'],
            user['name'],
            user['email'],
            fcmToken ?? '',
          );
        }

        _showSnackbar(context, 'Login berhasil!', AppColors.primary);

        // ✅ Arahkan ke home
        if (role.toLowerCase() == 'penyandang') {
          Navigator.pushReplacementNamed(context, '/penyandang/home');
        } else {
          Navigator.pushReplacementNamed(context, '/pemantau/home');
        }
      } else {
        _showSnackbar(
          context,
          'Login gagal, token tidak ditemukan!',
          AppColors.dangerText,
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message;
      _showSnackbar(context, 'Login gagal: $message', AppColors.dangerText);
      print(e.response?.data);
    } catch (e) {
      _showSnackbar(context, 'Terjadi error: $e', AppColors.dangerText);
    }
  }

  Future<void> registerUser({
    required BuildContext context,
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    if (email.isEmpty ||
        name.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackbar(context, 'Semua field harus diisi!');
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar(context, 'Password dan konfirmasi tidak cocok!');
      return;
    }

    // Tentukan endpoint berdasarkan role
    final endpoint = role.toLowerCase() == 'penyandang'
        ? '/mobile/auth/register/penyandang'
        : '/mobile/auth/register/pemantau';

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'email': email,
          'name': name,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );

      final data = response.data;
      final token = data['access_token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);

        _showSnackbar(context, 'Registrasi berhasil!', AppColors.primary);
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackbar(
          context,
          'Registrasi gagal, tidak ada token!',
          AppColors.dangerText,
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      _showSnackbar(context, 'Error: $message', AppColors.dangerText);
      print(e.response?.data);
    } catch (e) {
      _showSnackbar(context, 'Terjadi error: $e', AppColors.dangerText);
    }
  }

  void _showSnackbar(
    BuildContext context,
    String message, [
    Color color = AppColors.infoBtn,
  ]) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
