import 'package:material_ui/material_ui.dart';

import '../api/api_client.dart';
import '../data/product_store.dart';
import '../models/product.dart';
import '../theme/warehouse_theme.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    ProductStore.instance.addListener(_refresh);
    if (ProductStore.remoteEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reload();
      });
    }
  }

  @override
  void dispose() {
    ProductStore.instance.removeListener(_refresh);
    _search.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _reload() async {
    await ProductStore.instance.load();
    if (!mounted) {
      return;
    }
    final error = ProductStore.instance.error;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  List<Product> get _products => ProductStore.instance.items;

  List<Product> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _products;
    }
    return _products.where((product) {
      return product.productName.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query) ||
          product.articleId.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openCreate() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormPage()),
    );
  }

  Future<void> _openDetail(Product product) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  Future<void> _remove(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นำสีออกจากคลัง'),
        content: Text('ลบ “${product.productName}” ออกจากคลังสีน้ำ'),
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
      await ProductStore.instance.remove(product.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('นำสีออกจากคลังแล้ว')));
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
    final visible = _visible;
    final ready = _products.where((product) => product.isActive).length;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: WarehouseColors.clay,
        foregroundColor: Colors.white,
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสี'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: WarehouseColors.ivory,
            title: const Text(
              'คลังสีน้ำ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ชั้นวางสีทาบ้าน เพิ่มสีใหม่ เปิดดูฉลาก แก้ไข หรือนำออกจากคลังได้',
                    style: TextStyle(color: WarehouseColors.mist, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatChip(
                        label: 'ทั้งหมด',
                        value: '${_products.length}',
                        color: WarehouseColors.ink,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'พร้อมใช้',
                        value: '$ready',
                        color: WarehouseColors.moss,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'ค้นชื่อสี บาร์โค้ด หรือรหัส',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          ..._slivers(visible),
        ],
      ),
    );
  }

  List<Widget> _slivers(List<Product> visible) {
    if (ProductStore.instance.loading && visible.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }
    if (visible.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: _EmptyShelf(
            icon: Icons.format_paint_outlined,
            title: 'ชั้นวางยังว่าง',
            message: 'กดเพิ่มสี เพื่อรับสีน้ำเข้าคลัง',
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        sliver: SliverList.separated(
          itemCount: visible.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = visible[index];
            return _PaintCard(
              product: product,
              onOpen: product.id.isEmpty ? null : () => _openDetail(product),
              onDelete: product.id.isEmpty ? null : () => _remove(product),
            );
          },
        ),
      ),
    ];
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: WarehouseColors.paper,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: WarehouseColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(color: WarehouseColors.mist)),
          ],
        ),
      ),
    );
  }
}

class _PaintCard extends StatelessWidget {
  const _PaintCard({
    required this.product,
    required this.onOpen,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = paintColorOf(
      product.productName,
      product.articleId + product.barcode,
    );
    final name = product.productName.isEmpty
        ? 'สีไม่มีชื่อ'
        : product.productName;
    return Material(
      color: WarehouseColors.paper,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: WarehouseColors.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _Can(color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.articleId} · ${product.barcode}',
                        style: const TextStyle(color: WarehouseColors.mist),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            baht(product.price),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            ' / ${product.unitCode}',
                            style: const TextStyle(color: WarehouseColors.mist),
                          ),
                          const Spacer(),
                          _StatusPill(active: product.isActive),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'ลบ',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Can extends StatelessWidget {
  const _Can({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 84,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
          bottom: Radius.circular(12),
        ),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 14,
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? WarehouseColors.moss : WarehouseColors.mist;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'พร้อมใช้' : 'ปิดใช้',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: WarehouseColors.clay),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: WarehouseColors.mist, height: 1.4),
          ),
        ],
      ),
    );
  }
}
