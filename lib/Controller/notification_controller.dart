import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _storageKey = 'local_notifications';

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    loadNotifications();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      // Fixed: Using named parameter 'settings' as required by the library version
      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );
    } catch (e) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_storageKey);
    if (notificationsJson != null) {
      final List<dynamic> decoded = jsonDecode(notificationsJson);
      notifications.value =
          decoded.map((item) => NotificationModel.fromJson(item)).toList();
    }
  }

  Future<void> saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(notifications.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addNotification(String title, String message) async {
    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      dateTime: DateTime.now(),
    );
    notifications.insert(0, newNotification);
    await saveNotifications();
    _showLocalNotification(newNotification);
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'shopsy_channel',
      'Shopsy Notifications',
      channelDescription: 'Shopsy Notifications Description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    try {
      // Fixed: Using named parameters as required by the library version
      await _flutterLocalNotificationsPlugin.show(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.message,
        notificationDetails: platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }

  void markAsRead(int index) {
    notifications[index].isRead = true;
    notifications.refresh();
    saveNotifications();
  }

  void clearAll() {
    notifications.clear();
    saveNotifications();
  }
}
