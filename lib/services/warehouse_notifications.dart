import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import '../models/product.dart';
import '../theme/warehouse_theme.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// แจ้งเตือนจากผลของ API learn-product และจากข้อความ FCM
class WarehouseNotifications {
  WarehouseNotifications._();

  static final WarehouseNotifications instance = WarehouseNotifications._();

  static const String _channelId = 'warehouse';
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  int _nextId = 0;

  Future<void> start() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (error) {
      debugPrint('เริ่ม Firebase ไม่สำเร็จ: $error');
    }
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const apple = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: android,
          iOS: apple,
          macOS: apple,
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              'คลังสีน้ำ',
              description: 'แจ้งเตือนเมื่อสินค้าเข้า ปรับราคา เปลี่ยนสถานะ หรือออกจากคลัง',
              importance: Importance.high,
            ),
          );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (error) {
      debugPrint('เริ่มการแจ้งเตือนไม่สำเร็จ: $error');
    }
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onForegroundMessage);
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((token) {
        debugPrint('fcm_token: $token');
      });
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      debugPrint('fcm_token: $token');
    } catch (error) {
      debugPrint('เริ่ม Firebase Messaging ไม่สำเร็จ: $error');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? '';
    final body = notification?.body ?? message.data['body'] ?? '';
    debugPrint('ได้รับข้อความ FCM: $title $body');
    if (title.isEmpty && body.isEmpty) {
      return;
    }
    _show(title: title.isEmpty ? 'คลังสีน้ำ' : title, body: body);
  }

  Future<void> productAdded(Product product) {
    return _show(
      title: 'สินค้าเข้าคลัง',
      body: '${_name(product)} ${baht(product.price)} / ${product.unitCode}',
    );
  }

  Future<void> priceChanged(Product product, double oldPrice) {
    return _show(
      title: 'ปรับราคาสินค้า',
      body:
          '${_name(product)} จาก ${baht(oldPrice)} เป็น ${baht(product.price)}',
    );
  }

  Future<void> statusChanged(Product product) {
    final body = product.isActive
        ? '${_name(product)} กลับมาพร้อมใช้'
        : '${_name(product)} ถูกปิดใช้';
    return _show(title: 'สถานะสินค้าเปลี่ยน', body: body);
  }

  Future<void> productRemoved(Product product) {
    return _show(title: 'นำสินค้าออกจากคลัง', body: _name(product));
  }

  Future<void> _show({required String title, required String body}) async {
    if (!_ready) {
      return;
    }
    await _plugin.show(
      id: _nextId++,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'คลังสีน้ำ',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }

  String _name(Product product) {
    return product.productName.isEmpty ? 'สินค้า' : product.productName;
  }
}
