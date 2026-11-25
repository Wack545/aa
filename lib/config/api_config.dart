import '../api/api_client.dart';

/// ลิงก์สินค้าจริงอยู่ที่ ApiClient.baseUrl
/// https://api-internal-uat.dohome.technology/dodee/v1/learn-product
class ApiConfig {
  static String get baseUrl => ApiClient.baseUrl;

  static String get productsUrl =>
      '${ApiClient.baseUrl}${ApiClient.productsPath}';

  static String productUrl(String id) {
    return '${ApiClient.baseUrl}${ApiClient.productPath(id)}';
  }
}
