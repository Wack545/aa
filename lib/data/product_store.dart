import 'package:material_ui/material_ui.dart';

import '../api/api_client.dart';
import '../api/create_product.dart';
import '../api/delete_product.dart';
import '../api/get_product.dart';
import '../api/list_products.dart';
import '../api/update_product.dart';
import '../models/product.dart';
import '../services/warehouse_notifications.dart';

/// ข้อมูลจาก https://api-internal-uat.dohome.technology/dodee/v1/learn-product
class ProductStore extends ChangeNotifier {
  ProductStore._();

  static final ProductStore instance = ProductStore._();

  /// ปิดในเทส เพื่อไม่ให้ยิงเครือข่าย
  static bool remoteEnabled = true;

  final List<Product> _items = [];
  bool loading = false;
  String? error;

  List<Product> get items => List.unmodifiable(_items);

  Product? find(String id) {
    for (final product in _items) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  Future<void> load() async {
    if (!remoteEnabled) {
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      final products = await listProducts();
      _items
        ..clear()
        ..addAll(products);
    } catch (caught) {
      error = ApiClient.errorMessage(caught);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> create(Product input) async {
    final created = await createProduct(input);
    if (created != null) {
      _items.insert(0, created);
      notifyListeners();
      await WarehouseNotifications.instance.productAdded(created);
      return;
    }
    await load();
  }

  Future<void> edit(Product input) async {
    final previous = find(input.id);
    final updated = await updateProduct(input);
    Product? current = updated;
    if (updated != null) {
      final index = _items.indexWhere((item) => item.id == updated.id);
      if (index >= 0) {
        _items[index] = updated;
      }
      notifyListeners();
    } else {
      final fresh = await getProduct(input.id);
      current = fresh;
      final index = _items.indexWhere((item) => item.id == fresh.id);
      if (index >= 0) {
        _items[index] = fresh;
        notifyListeners();
      }
    }
    await _notifyEdits(previous, current);
  }

  Future<void> remove(String id) async {
    final existing = find(id);
    await deleteProduct(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    if (existing != null) {
      await WarehouseNotifications.instance.productRemoved(existing);
    }
  }

  Future<void> _notifyEdits(Product? previous, Product? current) async {
    if (previous == null || current == null) {
      return;
    }
    if ((previous.price - current.price).abs() > 0.001) {
      await WarehouseNotifications.instance.priceChanged(
        current,
        previous.price,
      );
    }
    if (previous.isActive != current.isActive) {
      await WarehouseNotifications.instance.statusChanged(current);
    }
  }
}
