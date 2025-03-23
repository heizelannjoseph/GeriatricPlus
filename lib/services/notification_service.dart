import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  void initializeNotifications() async {
    InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(String title, String body,
      {sound = const RawResourceAndroidNotificationSound('medicine_reminder'),
      String id = 'id',
      String name = 'name'}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(id, name,
            importance: Importance.max,
            priority: Priority.high,
            sound: sound,
            playSound: true);
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails);
  }

  void scheduleNotification(String title, String body, scheduledDate) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('id', 'name',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true);
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation =
        UILocalNotificationDateInterpretation.wallClockTime;
    await _flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, title, body, scheduledDate, notificationDetails,
        uiLocalNotificationDateInterpretation:
            uiLocalNotificationDateInterpretation,
        androidAllowWhileIdle: true);
  }
}
