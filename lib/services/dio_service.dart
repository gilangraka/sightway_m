import 'package:dio/dio.dart';

class DioService {
  // Buat instance Dio pribadi
  final Dio _dio;

  // Ganti dengan URL backend API Anda
  static const String _baseUrl = 'https://api.domain-proyek-anda.com';

  DioService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5), // Timeout koneksi 5 detik
          receiveTimeout: const Duration(
            seconds: 3,
          ), // Timeout menerima data 3 detik
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            // Anda juga bisa menaruh header global di sini, misal token otentikasi
          },
        ),
      );

  /// Mengirim laporan darurat ke endpoint /emergency
  Future<void> sendEmergencyReport(String detectedText) async {
    try {
      final response = await _dio.post(
        '/emergency', // Endpoint spesifik
        data: {
          'text': detectedText,
          'userId': '12345', // Contoh data tambahan
        },
      );

      // Dio akan melempar error untuk status code non-2xx secara default,
      // jadi kita bisa asumsikan request berhasil jika tidak ada error.
      print('Laporan darurat berhasil dikirim! Status: ${response.statusCode}');
    } on DioException catch (e) {
      // Tangani error spesifik dari Dio (misal: timeout, tidak ada koneksi, error server)
      print('Error Dio saat mengirim laporan: ${e.message}');
      // Lempar kembali error agar bisa ditangani di UI
      throw Exception('Gagal menghubungi server: ${e.message}');
    } catch (e) {
      // Tangani error lainnya
      print('Error tidak terduga: $e');
      throw Exception('Terjadi error yang tidak diketahui.');
    }
  }
}
