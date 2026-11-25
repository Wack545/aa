class Product {
  const Product({
    required this.id,
    required this.articleId,
    required this.barcode,
    required this.productName,
    required this.price,
    required this.unitCode,
    required this.remark,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// อยู่ใน path ตอน Get / Update / Delete ไม่ส่งใน body ตอนสร้าง
  final String id;

  final String articleId;
  final String barcode;
  final String productName;
  final double price;
  final String unitCode;
  final String remark;
  final bool isActive;

  /// เซิร์ฟเวอร์เป็นคนใส่ ไม่อยู่ในลิงก์และไม่ต้องกรอกตอนสร้าง
  final String? createdAt;
  final String? updatedAt;

  /// ฟิลด์ที่ผู้ใช้กรอก ส่งเป็น JSON body
  Map<String, dynamic> toRequestBody() {
    return {
      'article_id': articleId,
      'barcode': barcode,
      'product_name': productName,
      'price': price,
      'unit_code': unitCode,
      'remark': remark,
      'is_active': isActive,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _text(json['id']),
      articleId: _text(json['article_id']),
      barcode: _text(json['barcode']),
      productName: _text(json['product_name']),
      price: _double(json['price']),
      unitCode: _text(json['unit_code']),
      remark: _text(json['remark']),
      isActive: _bool(json['is_active']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Product copyWith({
    String? articleId,
    String? barcode,
    String? productName,
    double? price,
    String? unitCode,
    String? remark,
    bool? isActive,
    String? updatedAt,
  }) {
    return Product(
      id: id,
      articleId: articleId ?? this.articleId,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      unitCode: unitCode ?? this.unitCode,
      remark: remark ?? this.remark,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

Product parseProduct(dynamic raw) {
  final data = unwrapPayload(raw);
  if (data is Map<String, dynamic>) {
    return Product.fromJson(data);
  }
  if (data is Map) {
    return Product.fromJson(Map<String, dynamic>.from(data));
  }
  throw const FormatException('API ไม่ได้ส่งข้อมูลสินค้ากลับมา');
}

List<Product> parseProductList(dynamic raw) {
  final data = unwrapPayload(raw);
  if (data is List) {
    return data.map(parseProduct).toList();
  }
  if (data is Map) {
    for (final key in [
      'items',
      'products',
      'list',
      'records',
      'rows',
      'data',
    ]) {
      final value = data[key];
      if (value is List) {
        return value.map(parseProduct).toList();
      }
    }
  }
  throw const FormatException('รูปแบบรายการสินค้าไม่ตรงที่คาดไว้');
}

dynamic unwrapPayload(dynamic raw) {
  if (raw is Map) {
    for (final key in ['data', 'result', 'item', 'product']) {
      final value = raw[key];
      if (value != null) {
        return value;
      }
    }
  }
  return raw;
}

String _text(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

double _double(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _bool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}
