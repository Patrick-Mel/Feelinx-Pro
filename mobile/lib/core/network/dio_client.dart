import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory DioClient() => _instance;

  DioClient._internal() {
    final String defaultUrl = kIsWeb
        ? 'http://127.0.0.1:8000/api/v1/'
        : 'http://192.168.1.154:8000/api/v1/';

    dio = Dio(
      BaseOptions(
        baseUrl: defaultUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Attempt token refresh
            final refreshToken = await _storage.read(key: 'jwt_refresh_token');
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
                final res = await refreshDio.post('auth/refresh/', data: {'refresh': refreshToken});
                if (res.statusCode == 200) {
                  final newAccessToken = res.data['access'];
                  await _storage.write(key: 'jwt_access_token', value: newAccessToken);
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  return handler.resolve(await dio.fetch(error.requestOptions));
                }
              } catch (_) {
                await _storage.deleteAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }
}
