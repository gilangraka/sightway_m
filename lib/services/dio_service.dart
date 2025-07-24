import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioService {
  final Dio _dio;

  static const String _baseUrl = 'https://api-sightway.dgdev.my.id';

  DioService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ),
      );

  Future<void> sendEmergencyReport(String detectedText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        '/emergency',
        data: {'text': detectedText, 'userId': '12345'},
      );

      print('Laporan darurat berhasil dikirim! Status: ${response.statusCode}');
    } on DioException catch (e) {
      print('Error Dio saat mengirim laporan: ${e.message}');
      throw Exception('Gagal menghubungi server: ${e.message}');
    } catch (e) {
      print('Error tidak terduga: $e');
      throw Exception('Terjadi error yang tidak diketahui.');
    }
  }
}
