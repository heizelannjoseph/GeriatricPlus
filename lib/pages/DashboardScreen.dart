import 'package:dashboard_screen/database/database_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_screen/pages/HomePage.dart';
import 'package:dashboard_screen/pages/Form.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  DBHelper? dbHelper;
  static List<Widget> _pages = <Widget>[
    HomePage(),
    CustomFormInput(),
  ];

  @override
  void initState() {
    dbHelper = DBHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Container(
          width: 400,
          color: Colors.white,
          child: GestureDetector(
              onDoubleTap: () async {
                String msg = 'Successfully reversed app init state';
                try {
                  // code for app start state if any
                } catch (e) {
                  msg = '${e}';
                }
                final snackBar = SnackBar(
                    duration: Duration(seconds: 3), content: Text('${msg}'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height / 6,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage(
                                      'assets/images/geriatricplus_title.jpg')))),
                    ],
                  ),
                ],
              )),
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 30,
              height: 30,
              child: SvgPicture.asset("assets/icons/dashboard.svg"),
            ),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 30,
              height: 30,
              child: SvgPicture.asset("assets/icons/sheet.svg"),
            ),
            label: "Form",
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
