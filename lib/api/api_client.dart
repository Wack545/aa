import 'package:dio/dio.dart';

class ApiClient {
  /// โฮสต์ของ API สินค้า
  /// รายการเต็มคือ https://api-internal-uat.dohome.technology/dodee/v1/learn-product
  static const String baseUrl =
      'https://api-internal-uat.dohome.technology/dodee';
  static const String productsPath = '/v1/learn-product';

  static String token = '';

  static String productPath(String id) {
    return '$productsPath/${Uri.encodeComponent(id)}';
  }

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final token = ApiClient.token;
              if (token.isEmpty) {
                options.headers.remove('Authorization');
              } else if (token.toLowerCase().startsWith('bearer ')) {
                options.headers['Authorization'] = token;
              } else {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
          ),
        );

  static String errorMessage(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      final data = error.response?.data;
      final detail = _readDetail(data);
      if (code != null && detail != null) {
        return 'API ตอบกลับ $code: $detail';
      }
      if (code != null) {
        return 'API ตอบกลับ $code';
      }
      return error.message ?? 'เรียก API ไม่สำเร็จ';
    }
    return error.toString();
  }

  static String? _readDetail(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    if (data is Map) {
      for (final key in ['message', 'error', 'error_msg', 'detail', 'title']) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return null;
  }
}
