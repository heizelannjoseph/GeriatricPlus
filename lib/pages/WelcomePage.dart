import 'package:dashboard_screen/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_screen/pages/DashboardScreen.dart';
import 'package:dashboard_screen/pages/LoginPage.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    // Simulate a loading delay (e.g., fetching data, initializing services)
    await Future.delayed(Duration(seconds: 3));

    // Navigate to the DashboardPage after loading
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool shouldGoToDashboard =
        GlobalVariables().isHomePageReady; // Example condition
    bool isInitializationError = GlobalVariables().isInitializationError;

    if (shouldGoToDashboard) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
    return Scaffold(
      body: Center(
          child: Container(
        color: Colors.white,
        child: DrawerHeader(
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage('assets/images/geriatricplus_title.jpg'))),
          child: !isInitializationError
              ? Container()
              : Center(child: Text('An Error Occured')),
        ),
      )),
    );
  }
}
