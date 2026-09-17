import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory DioClient() => _instance;

  DioClient._internal() {
    final String defaultUrl = kReleaseMode
        ? 'https://feelinx-backend-production-9537.up.railway.app/api/v1/'
        : (kIsWeb ? 'http://127.0.0.1:8000/api/v1/' : 'https://feelinx-backend-production-9537.up.railway.app/api/v1/');

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

  /// Utility to turn relative image paths or broken localhost paths into valid accessible HTTPS image URLs
  static String resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) {
      return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=800';
    }

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      if (!kDebugMode && (rawUrl.contains('localhost') || rawUrl.contains('127.0.0.1'))) {
        final path = Uri.parse(rawUrl).path;
        return 'https://feelinx-backend-production-9537.up.railway.app$path';
      }
      return rawUrl;
    }

    if (rawUrl.startsWith('/')) {
      return 'https://feelinx-backend-production-9537.up.railway.app$rawUrl';
    }

    return 'https://feelinx-backend-production-9537.up.railway.app/media/$rawUrl';
  }
}
