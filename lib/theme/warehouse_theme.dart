import 'package:material_ui/material_ui.dart';

class WarehouseColors {
  static const ivory = Color(0xFFF3EEE6);
  static const paper = Color(0xFFFFFBF6);
  static const ink = Color(0xFF1E2430);
  static const clay = Color(0xFFC4492C);
  static const moss = Color(0xFF2F6B4F);
  static const mist = Color(0xFF8A8175);
  static const line = Color(0xFFE6D9CC);
}

ThemeData warehouseTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: WarehouseColors.clay,
    surface: WarehouseColors.ivory,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: WarehouseColors.ivory,
    appBarTheme: const AppBarTheme(
      backgroundColor: WarehouseColors.ivory,
      foregroundColor: WarehouseColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: WarehouseColors.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: WarehouseColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WarehouseColors.paper,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WarehouseColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WarehouseColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WarehouseColors.clay, width: 1.4),
      ),
      labelStyle: const TextStyle(color: WarehouseColors.ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: WarehouseColors.clay,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

Color paintColorOf(String name, String seed) {
  const named = <String, Color>{
    'ขาว': Color(0xFFF4F1EA),
    'ครีม': Color(0xFFF3E2C4),
    'เหลือง': Color(0xFFE6B325),
    'ส้ม': Color(0xFFE07A2F),
    'แดง': Color(0xFFD24B45),
    'ชมพู': Color(0xFFE989A3),
    'ม่วง': Color(0xFF7A5EA7),
    'น้ำเงิน': Color(0xFF2F5D9F),
    'ฟ้า': Color(0xFF7EBFDC),
    'เขียว': Color(0xFF3E8C5A),
    'น้ำตาล': Color(0xFF8A5A3B),
    'เทา': Color(0xFF8E939A),
    'ดำ': Color(0xFF2A2A2A),
  };
  for (final entry in named.entries) {
    if (name.contains(entry.key)) {
      return entry.value;
    }
  }
  const palette = <Color>[
    Color(0xFFD24B45),
    Color(0xFFE07A2F),
    Color(0xFFE6B325),
    Color(0xFF3E8C5A),
    Color(0xFF2F6B8A),
    Color(0xFF3D4F8A),
    Color(0xFF7A5EA7),
    Color(0xFF8A5A3B),
  ];
  final index = seed.hashCode.abs() % palette.length;
  return palette[index];
}

Color paintInk(Color color) {
  return color.computeLuminance() > 0.62 ? WarehouseColors.ink : Colors.white;
}

String baht(double price) {
  final text = price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);
  return '฿$text';
}

String prettyDate(String? raw) {
  if (raw == null || raw.isEmpty) {
    return '-';
  }
  final text = raw.replaceFirst('T', ' ').replaceFirst('Z', '');
  final dot = text.indexOf('.');
  if (dot == -1) {
    return text;
  }
  return text.substring(0, dot);
}
