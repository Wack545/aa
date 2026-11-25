import 'package:material_ui/material_ui.dart';

import 'pages/product_list_page.dart';
import 'services/warehouse_notifications.dart';
import 'theme/warehouse_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WarehouseNotifications.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'คลังสีน้ำ',
      debugShowCheckedModeBanner: false,
      theme: warehouseTheme(),
      home: const ProductListPage(),
    );
  }
}
