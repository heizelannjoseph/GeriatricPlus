import 'package:flutter/material.dart';
import 'package:dashboard_screen/pages/WelcomePage.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dashboard_screen/services/notification_service.dart';
import 'package:dashboard_screen/utils/global_variables.dart';
import 'package:dashboard_screen/database/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';

String defaultNotificationId = '7e91aed5-0286-44b8-a6ee-cb00b0f77caf';

NotificationsService notificationsService = NotificationsService();
DBHelper dbHelper = DBHelper();

askPermissions() async {
  if (!(await Permission.phone.status.isGranted)) {
    await Permission.phone.request();
  }
  var smsStatus = await Permission.sms.status;
  var locationStatus = await Permission.location.status;
  if (!smsStatus.isGranted) {
    await Permission.sms.request();
  }
  if (!locationStatus.isGranted) {
    await Permission.location.request();
  }
  if (!(await Permission.contacts.status.isGranted)) {
    await Permission.contacts.request();
  }
}

// write code to initialize notifications
initializeGlobalVariables() async {
  try {
    // initialize settings here
    GlobalVariables().settings = {};
    // initialize notifications here
    await Future.delayed(Duration(seconds: 2));
    String? loggedUser = await dbHelper.getFromCache('loggedUser');
    print('Logged user is: ');
    print(loggedUser);
    if (loggedUser == null) {
      GlobalVariables().isLoggedIn = false;
    } else {
      try {
        int userId = int.parse(loggedUser);
        int res = await dbHelper.setUserGlobalState(userId);
        if (res == 1) {
          GlobalVariables().isLoggedIn = true;
        } else {
          GlobalVariables().isLoggedIn = false;
        }
      } catch (e) {
        GlobalVariables().isLoggedIn = false;
      }
    }
    GlobalVariables().isHomePageReady = true;
  } catch (err) {
    print('startup error');
    print('${err}');
  }
}

void main() async {
  dbHelper = DBHelper();
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
  await askPermissions();
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
