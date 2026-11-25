import '../models/product.dart';
import 'api_client.dart';

/// Get product
///
/// Method: GET
/// ลิงก์: https://api-internal-uat.dohome.technology/dodee/v1/learn-product/{id}
///
/// id จากตัวอย่าง 1f6fc8eb-6475-4a4b-8efd-dd1f2fccb0cd
/// วางต่อท้าย path หลัง /v1/learn-product/
/// ไม่ใช้ ?id= และไม่ส่ง body
Future<Product> getProduct(String id) async {
  final response = await ApiClient.dio.get<dynamic>(ApiClient.productPath(id));
  return parseProduct(response.data);
}
