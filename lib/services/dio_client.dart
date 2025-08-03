import 'package:dio/dio.dart';
import 'token_storage.dart';

class DioClient {
  static final Dio _dio = _createDio(); // Ubah cara inisialisasi

  static Dio get client => _dio; // Getter tetap sama

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api-sightway.dgdev.my.id',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.addAll([
      // Gunakan addAll untuk multiple interceptors
      // Interceptor untuk otorisasi
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
      // Interceptor untuk logging (SANGAT BERGUNA)
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }
}
