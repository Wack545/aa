import 'api_client.dart';

/// Delete product
///
/// Method: DELETE
/// ลิงก์: https://api-internal-uat.dohome.technology/dodee/v1/learn-product/{id}
///
/// ใส่เฉพาะ id ใน path ไม่ส่ง body และไม่ใส่ฟิลด์อื่นในลิงก์
Future<void> deleteProduct(String id) async {
  await ApiClient.dio.delete<dynamic>(ApiClient.productPath(id));
}
