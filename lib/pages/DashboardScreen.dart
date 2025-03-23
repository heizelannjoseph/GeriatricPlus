import 'package:dashboard_screen/database/database_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_screen/pages/HomePage.dart';
import 'package:dashboard_screen/pages/Form.dart';
import 'package:dashboard_screen/pages/LoginPage.dart';
import 'package:dashboard_screen/pages/AccountPage.dart';
import 'package:dashboard_screen/utils/global_variables.dart';

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
    double w = size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountInformationPage()));
            },
            child: Container(
              width: w / 15,
              child: Icon(
                Icons.person,
                color: Color(0xFF143055),
                size: 30,
              ),
            )),
        title: Row(children: [
          SizedBox(width: 10),
          Center(
              child: Container(
            width: MediaQuery.of(context).size.width / 2 - 10,
            color: Colors.white,
            child: GestureDetector(
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
          )),
          SizedBox(width: 10),
          GestureDetector(
              onTap: () async {
                String? num = GlobalVariables().userData['emergency_contact_number'];
                if(num != null && num.length >= 10) {
                  await dbHelper!.phoneCall(num);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Emergency contact not yet added')),
                  );
                }
              },
              child: Container(
                width: w / 15,
                child: Icon(
                  Icons.phone,
                  color: Colors.red,
                  size: 30,
                ),
              )),
          SizedBox(width: 20,),
          GestureDetector(
              onTap: () async {
                String? num = GlobalVariables().userData['emergency_contact_number'];
                if(num != null && num.length >= 10) {
                  print("Valid");
                  String name = GlobalVariables().userData['name'] ?? "";
                  int res = await dbHelper!.sendLocationSMS([num], name);
                  if (res == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Success! Message Queued')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('An Error Occured')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Emergency contact not yet added')),
                  );
                }
              },
              child: Container(
                width: w / 15,
                child: Icon(
                  Icons.emergency_share,
                  color: Colors.red,
                  size: 30,
                ),
              )),
        ]),
      ),
      drawer: Drawer(child: null),
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
