import '../models/product.dart';
import 'api_client.dart';

/// List products
///
/// Method: GET
/// ลิงก์: https://api-internal-uat.dohome.technology/dodee/v1/learn-product
///
/// ไม่ใส่ id และไม่ต้องส่ง body
/// ฟิลด์อย่าง article_id, barcode, price เป็นข้อมูลในผลลัพธ์ ไม่ได้ต่อท้ายลิงก์
Future<List<Product>> listProducts() async {
  final response = await ApiClient.dio.get<dynamic>(ApiClient.productsPath);
  if (response.data == null || response.data == '') {
    return const [];
  }
  return parseProductList(response.data);
}
