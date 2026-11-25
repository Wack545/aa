import '../models/product.dart';
import 'api_client.dart';

/// Create product
///
/// Method: POST
/// ลิงก์: https://api-internal-uat.dohome.technology/dodee/v1/learn-product
///
/// ไม่มี id ในลิงก์ เซิร์ฟเวอร์สร้าง id, created_at, updated_at ให้
/// ค่าที่กรอกอยู่ที่ Body ไม่ได้อยู่ในลิงก์:
/// article_id, barcode, product_name, price, unit_code, remark, is_active
Future<Product?> createProduct(Product input) async {
  final response = await ApiClient.dio.post<dynamic>(
    ApiClient.productsPath,
    data: input.toRequestBody(),
  );
  if (response.data == null || response.data == '') {
    return null;
  }
  return parseProduct(response.data);
}
