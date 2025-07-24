import 'package:dio/dio.dart';
import 'token_storage.dart';

class DioClient {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: 'https://api-sightway.dgdev.my.id',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await TokenStorage.getToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              return handler.next(options);
            },
            onError: (error, handler) {
              // Tambahkan handler 401/403 kalau perlu
              return handler.next(error);
            },
          ),
        );

  static Dio get client => _dio;
}
