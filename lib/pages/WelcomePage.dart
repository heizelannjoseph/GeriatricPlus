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
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    // Wait for 3 seconds
    await Future.delayed(Duration(seconds: 3));

    // Navigate to the appropriate page based on login status
    print("Login status - ${GlobalVariables().isLoggedIn}");
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
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: AssetImage('assets/images/geriatricplus_title.jpg'),
              ),
            ),
            child: GlobalVariables().isInitializationError
                ? Center(child: Text('An Error Occurred'))
                : Container(),
          ),
        ),
      ),
    );
  }
}