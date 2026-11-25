import 'package:material_ui/material_ui.dart';

import '../api/api_client.dart';
import '../data/product_store.dart';
import '../models/product.dart';
import '../theme/warehouse_theme.dart';
import 'product_form_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    ProductStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ProductStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Product? get _product => ProductStore.instance.find(widget.productId);

  Future<void> _edit() async {
    final product = _product;
    if (product == null) {
      return;
    }
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
  }

  Future<void> _remove() async {
    final name = _product?.productName ?? 'สีนี้';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นำสีออกจากคลัง'),
        content: Text('ลบ “$name” ออกจากคลังสีน้ำ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await ProductStore.instance.remove(widget.productId);
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.errorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final color = paintColorOf(
      product?.productName ?? '',
      '${product?.articleId ?? ''}${product?.barcode ?? widget.productId}',
    );
    final ink = paintInk(color);
    final name = product == null || product.productName.isEmpty
        ? 'ไม่พบสินค้า'
        : product.productName;
    return Scaffold(
      appBar: AppBar(title: const Text('ฉลากสี')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _remove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('ลบ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: product == null ? null : _edit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('แก้ไข'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.isActive == false ? 'ปิดใช้' : 'พร้อมใช้',
                  style: TextStyle(color: ink.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    color: ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product == null
                      ? ''
                      : '${baht(product.price)} / ${product.unitCode}',
                  style: TextStyle(
                    color: ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (product != null) ...[
            const SizedBox(height: 18),
            const Text(
              'ข้อมูลในฉลาก',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _sheet([
              _line('ชื่อสี', product.productName),
              _line('รหัสสินค้า', product.articleId),
              _line('บาร์โค้ด', product.barcode),
              _line('ราคา', baht(product.price)),
              _line('หน่วย', product.unitCode),
              _line('หมายเหตุ', product.remark.isEmpty ? '-' : product.remark),
              _line('สถานะ', product.isActive ? 'พร้อมใช้' : 'ปิดใช้'),
            ]),
            const SizedBox(height: 14),
            const Text(
              'บันทึกของคลัง',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _sheet([
              _line('รหัสในระบบ', product.id),
              _line('รับเข้าเมื่อ', prettyDate(product.createdAt)),
              _line('แก้ไขล่าสุด', prettyDate(product.updatedAt)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _sheet(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: WarehouseColors.paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WarehouseColors.line),
      ),
      child: Column(children: children),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: WarehouseColors.mist),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
