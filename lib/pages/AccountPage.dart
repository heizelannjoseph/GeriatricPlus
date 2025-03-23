import 'package:dashboard_screen/main.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_screen/pages/LoginPage.dart';
import 'package:dashboard_screen/utils/global_variables.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dashboard_screen/utils/global_variables.dart';

class AccountInformationPage extends StatefulWidget {
  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

String? _name = GlobalVariables().userData['emergency_contact_name'];
String? _num = GlobalVariables().userData['emergency_contact_number'];

class _AccountInformationPageState extends State<AccountInformationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 22),
          Container(
            height: MediaQuery.of(context).size.height / 6,
            child: Column(children: [
              Container(
                height: MediaQuery.of(context).size.height / 6,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF143055), // Border color
                    width: 2.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height /
                        12, // Half of the container height to make it circular
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF143055),
                  size: MediaQuery.of(context).size.height / 6,
                ),
              ),
            ]),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "${GlobalVariables().userData['name']}",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "Age: ${GlobalVariables().userData['age']}",
              style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          _buildInfoTile('Email', "${GlobalVariables().userData['email']}"),
          _buildInfoTile('Date of Birth',
              "${GlobalVariables().userData['date_of_birth']}"),
          _buildInfoTile(
              'Phone Number', "${GlobalVariables().userData['mobile']}"),
    _buildInfoButtonTile(
        'Emergency Contact', (_name == null || _num == null) ? "Not Yet Added": "${_name!.length > 15 ? "${_name!.substring(0, 14)}..": _name}  ${_num}"),
          SizedBox(
            height: 25,
          ),
          SizedBox(
            width: double.infinity, // Full width button
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await dbHelper.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false, // Removes all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF143055),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Log out",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper method to create a ListTile for each piece of information
  Widget _buildInfoTile(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF143055),
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoButtonTile(String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF143055),
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.contacts),
          onPressed: () async {
            Map? contact = await dbHelper.selectContact();
            if(contact != null) {
              String name = contact['name'];
              String num = contact['phoneNumber'].replaceAll(RegExp(r'[^0-9]'), '');
              if(name != '' && num != '') {
                int r = await dbHelper.updateEmergencyContact(name, num, GlobalVariables().userId);
                if (r==1) {
                  setState(() {
                    _name = name;
                    _num = num;
                    GlobalVariables().userData['emergency_contact_name'] = name;
                    GlobalVariables().userData['emergency_contact_number'] = num;
                  });
                }
              }
            } else {
              print("Returned null contact");
            }
          },
        ),
      ),
    );
  }
}
