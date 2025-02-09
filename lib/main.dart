import 'package:flutter/material.dart';
import 'package:dashboard_screen/pages/WelcomePage.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dashboard_screen/services/notification_service.dart';
import 'package:dashboard_screen/utils/global_variables.dart';

String defaultNotificationId = '7e91aed5-0286-44b8-a6ee-cb00b0f77caf';

NotificationsService notificationsService = NotificationsService();

// write code to initialize notifications

initializeGlobalVariables() async {
  try {
    // initialize settings here
    GlobalVariables().settings = {};
    // initialize notifications here
    GlobalVariables().isHomePageReady = true;
  } catch (err) {
    print('startup error');
    print('${err}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
  notificationsService.initializeNotifications();
  await initializeGlobalVariables();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFFFFDFD)),
        home: WelcomePage());
  }
}
