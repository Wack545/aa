import '../models/product.dart';
import 'api_client.dart';

/// Update product
///
/// Method: PUT
/// ลิงก์: https://api-internal-uat.dohome.technology/dodee/v1/learn-product/{id}
///
/// id อยู่ในลิงก์ ส่วนที่แก้ได้อยู่ใน Body:
/// article_id, barcode, product_name, price, unit_code, remark, is_active
/// created_at กับ updated_at ไม่ต้องส่ง เซิร์ฟเวอร์อัปเดต updated_at เอง
Future<Product?> updateProduct(Product input) async {
  final response = await ApiClient.dio.put<dynamic>(
    ApiClient.productPath(input.id),
    data: input.toRequestBody(),
  );
  if (response.data == null || response.data == '') {
    return null;
  }
  return parseProduct(response.data);
}
