import 'package:material_ui/material_ui.dart';

import '../api/api_client.dart';
import '../data/product_store.dart';
import '../models/product.dart';
import '../theme/warehouse_theme.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _articleId;
  late final TextEditingController _barcode;
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _unit;
  late final TextEditingController _remark;
  late bool _isActive;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _articleId = TextEditingController(text: product?.articleId ?? '');
    _barcode = TextEditingController(text: product?.barcode ?? '');
    _name = TextEditingController(text: product?.productName ?? '');
    _price = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _unit = TextEditingController(text: product?.unitCode ?? 'EA');
    _remark = TextEditingController(text: product?.remark ?? '');
    _isActive = product?.isActive ?? true;
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _articleId.dispose();
    _barcode.dispose();
    _name.dispose();
    _price.dispose();
    _unit.dispose();
    _remark.dispose();
    super.dispose();
  }

  void _fillSample() {
    _articleId.text = '100002';
    _barcode.text = '885000000002';
    _name.text = 'สีทาบ้าน 2';
    _price.text = '300.5';
    _unit.text = 'EA';
    _remark.text = 'ของฝึก';
    setState(() => _isActive = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final input = Product(
      id: widget.product?.id ?? '',
      articleId: _articleId.text.trim(),
      barcode: _barcode.text.trim(),
      productName: _name.text.trim(),
      price: double.parse(_price.text.trim()),
      unitCode: _unit.text.trim(),
      remark: _remark.text.trim(),
      isActive: _isActive,
    );
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await ProductStore.instance.edit(input);
      } else {
        await ProductStore.instance.create(input);
      }
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiClient.errorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = paintColorOf(_name.text, _articleId.text + _barcode.text);
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'แก้ไขสี' : 'รับสีเข้าคลัง')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                _name.text.trim().isEmpty
                    ? 'ชื่อสีจะอยู่บนฉลาก'
                    : _name.text.trim(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: paintInk(color),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (!_isEdit)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _fillSample,
                  child: const Text('ใส่สีตัวอย่าง'),
                ),
              ),
            _field(_name, 'ชื่อสี', 'เช่น สีน้ำขาว'),
            _field(_articleId, 'รหัสสินค้า', 'เช่น 100002'),
            _field(_barcode, 'บาร์โค้ด', 'เช่น 885000000002'),
            _field(
              _price,
              'ราคา',
              'เช่น 300.5',
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (double.tryParse(value?.trim() ?? '') == null) {
                  return 'กรอกราคาเป็นตัวเลข';
                }
                return null;
              },
            ),
            _field(_unit, 'หน่วย', 'เช่น EA'),
            _field(_remark, 'หมายเหตุ', 'เช่น สีทาภายใน', requiredField: false),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: WarehouseColors.paper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WarehouseColors.line),
              ),
              child: SwitchListTile(
                title: const Text('พร้อมใช้ในคลัง'),
                subtitle: Text(
                  _isActive ? 'เปิดขายและเบิกได้' : 'เก็บไว้ แต่ยังไม่พร้อมใช้',
                ),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'กำลังบันทึก'
                    : (_isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มเข้าคลัง'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool requiredField = true,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator:
            validator ??
            (value) {
              if (requiredField && (value == null || value.trim().isEmpty)) {
                return 'กรอก$label';
              }
              return null;
            },
      ),
    );
  }
}
