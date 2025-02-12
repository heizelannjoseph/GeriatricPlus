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
    await Future.delayed(Duration(seconds: 2));

    // Navigate to the DashboardPage after loading
    if (GlobalVariables().isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool homePageReady = GlobalVariables().isHomePageReady;
    bool shouldGoToDashboard =
        GlobalVariables().isLoggedIn; // Example condition
    bool isInitializationError = GlobalVariables().isInitializationError;

    if (homePageReady && shouldGoToDashboard) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
          (route) => false,
        );
      });
    } else if (homePageReady) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
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
