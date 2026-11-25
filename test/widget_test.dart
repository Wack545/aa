import 'package:flutter_test/flutter_test.dart';

import 'package:aa/data/product_store.dart';
import 'package:aa/main.dart';

void main() {
  setUp(() {
    ProductStore.remoteEnabled = false;
  });

  testWidgets('หน้าคลังสีน้ำเปิดได้', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('คลังสีน้ำ'), findsOneWidget);
    expect(find.text('เพิ่มสี'), findsOneWidget);
  });
}
