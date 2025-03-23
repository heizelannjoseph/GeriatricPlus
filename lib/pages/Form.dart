import 'package:flutter/material.dart';
import 'package:dashboard_screen/database/database_helper.dart';
import 'package:dashboard_screen/components/default_button.dart';
import 'package:intl/intl.dart';
import 'dart:isolate';
import 'package:dashboard_screen/services/notification_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

NotificationsService nService = NotificationsService();

@pragma('vm:entry-point')
void showNotificationForMedicine() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  nService.sendNotification('Its time to have your medicine',
      'Time: ${now.hour}:${now.minute}:${now.second}',
      id: '112', name: 'medicine', sound: RawResourceAndroidNotificationSound('medicine_reminder'));
}

@pragma('vm:entry-point')
void showNotificationForReminder() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  nService.sendNotification('You have a reminder scheduled for now',
      'Time: ${now.hour}:${now.minute}:${now.second}',
      id: '113', name: 'reminder', sound: RawResourceAndroidNotificationSound('normal_reminder') );
}

class CustomFormInput extends StatefulWidget {
  CustomFormInput();

  @override
  _CustomFormInputState createState() => _CustomFormInputState();
}

class _CustomFormInputState extends State<CustomFormInput> {
  Map data = {};
  DBHelper? dbHelper;
  bool showProgress = false;
  late Future<List> dataList;
  int? selectedColorId;
  TimeOfDay _selectedTime = TimeOfDay.now();

  final _formKey = GlobalKey<FormState>();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String selectedDropDownValue = 'DAILY';
  String selectedRemTypeDropDownValue = 'MEDICINE';

  String comment = '';
  String title = '';

  TextEditingController notesController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.brown,
    Colors.purple,
  ];

  void initState() {
    dbHelper = DBHelper();
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now();
    notesController.clear();
    titleController.clear();
  }

  showConstantFields() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TextFormField(
            maxLines: 1,
            maxLength: 20,
            controller: titleController,
            decoration: new InputDecoration(
              labelText: "Enter Title",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(),
              ),
              //fillColor: Colors.green
            ),
            onChanged: (newValue) => title = newValue,
            validator: (val) {
              if (val!.length == 0) {
                return "Enter a title";
              } else if (val.length > 20) {
                return 'Max 20 characters allowed';
              } else {
                return null;
              }
            },
            keyboardType: TextInputType.text,
            style: new TextStyle(
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(children: [
            Container(width: 100, child: Text(
              "Reminder Type",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),),
            SizedBox(
              width: MediaQuery.of(context).size.width / 6,
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                  borderRadius: BorderRadius.circular(25.0)),
              child: Container(
                padding: EdgeInsets.all(10),
                child: DropdownButton<String>(
                  value: selectedDropDownValue,
                  underline: SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (newValue) {
                    setState(() {
                      selectedDropDownValue = '${newValue}';
                    });
                  },
                  items: <String>['DAILY', 'WEEKLY']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        '${value}',
                        style: TextStyle(fontSize: 17),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ]),
          SizedBox(
            height: 20,
          ),
          Row(children: [
            Container(width: 100, child: Text(
              "Notification Type",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),),
            SizedBox(
              width: MediaQuery.of(context).size.width / 6,
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                  borderRadius: BorderRadius.circular(25.0)),
              child: Container(
                padding: EdgeInsets.all(10),
                child: DropdownButton<String>(
                  value: selectedRemTypeDropDownValue,
                  underline: SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (newValue) {
                    setState(() {
                      selectedRemTypeDropDownValue = '${newValue}';
                    });
                  },
                  items: <String>['MEDICINE', 'ACTIVITY']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        '${value}',
                        style: TextStyle(fontSize: 17),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ]),
          SizedBox(height: 20,),
          Container(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5),
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    child: ListTile(
                      title: Text(
                        'Time to Remind:  ${_formatTime(_selectedTime)}',
                      ),
                      trailing: Icon(Icons.keyboard_arrow_down),
                      onTap: _pickTime,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5),
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    child: ListTile(
                      title: Text(
                        'Start Date:  ${_formatDate(startDate)}',
                      ),
                      trailing: Icon(Icons.keyboard_arrow_down),
                      onTap: _pickStartDate,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5),
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Container(
                    child: ListTile(
                      title: Text(
                        'End Date:  ${_formatDate(endDate)}',
                      ),
                      trailing: Icon(Icons.keyboard_arrow_down),
                      onTap: _pickEndDate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.all(1),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pick a color:',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                SizedBox(width: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: colors.asMap().entries.map((entry) {
                    int index = entry.key;
                    Color color = entry.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColorId = index;
                        });
                      },
                      child: Container(
                        width: 27,
                        height: 27,
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColorId == index
                                ? Colors.yellow
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            maxLines: 10,
            maxLength: 50,
            controller: notesController,
            decoration: new InputDecoration(
              labelText: "Short Description, if any",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(),
              ),
            ),
            onChanged: (newValue) => comment = newValue,
            validator: (val) {
              if (val!.length == 0) {
                return "Enter a Note";
              } else if (val.length > 50) {
                return "Max 50 characters allowed";
              } else {
                return null;
              }
            },
            keyboardType: TextInputType.text,
            style: new TextStyle(
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    "Create Reminder for Medicine",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 50),
                  Expanded(
                    child: showProgress
                        ? CircularProgressIndicator()
                        : showConstantFields(),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DefaultButton(
                          text: 'Submit',
                          press: () async {
                            // create an entry for alarm notification
                            bool validator = title.length >= 3 &&
                                endDate.isAfter(startDate) &&
                                selectedColorId != null;
                            if (validator) {
                              var objectMap = {
                                'title': title,
                                'type': selectedDropDownValue,
                                'remType': selectedRemTypeDropDownValue == 'MEDICINE' ? 0: 1,
                                'startDate':
                                    startDate.toIso8601String().split('T')[0],
                                'endDate':
                                    endDate.toIso8601String().split('T')[0],
                                'time': _selectedTime,
                                'color': selectedColorId,
                                'description': comment
                              };

                              int res =
                                  await dbHelper!.insertReminder(objectMap);

                              if (res == -1) {
                                final snackBar = SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text(
                                        'An Error Occured while creating reminder'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else {
                                // create entry for notification
                                // if today in range then create notification
                                DateTime now = DateTime.now();
                                bool isInRange = now.isAfter(startDate) &&
                                    now.isBefore(endDate);
                                bool isStartToday = startDate.day == now.day &&
                                    startDate.month == now.month &&
                                    startDate.year == now.year;
                                bool isEndToday = endDate.day == now.day &&
                                    endDate.month == now.month &&
                                    endDate.year == now.year;
                                if (isInRange || isStartToday || isEndToday) {
                                  TimeOfDay currTime = TimeOfDay.now();
                                  print(
                                      '${currTime.hour} ${_selectedTime.hour} ${currTime.minute} ${_selectedTime.minute}');
                                  bool isBefore = (currTime.hour <
                                          _selectedTime.hour) ||
                                      ((currTime.hour == _selectedTime.hour) &&
                                          (currTime.minute <
                                              _selectedTime.minute));
                                  if (isBefore) {
                                    // create a one shot notification
                                    if (selectedRemTypeDropDownValue == 'MEDICINE') {
                                      await AndroidAlarmManager.oneShotAt(
                                          DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              _selectedTime.hour,
                                              _selectedTime.minute,
                                              0),
                                          525,
                                          showNotificationForMedicine,
                                          exact: true,
                                          allowWhileIdle: true,
                                          alarmClock: true,
                                          wakeup: true,
                                          rescheduleOnReboot: true);
                                    } else {
                                      await AndroidAlarmManager.oneShotAt(
                                          DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              _selectedTime.hour,
                                              _selectedTime.minute,
                                              0),
                                          526,
                                          showNotificationForReminder,
                                          exact: true,
                                          allowWhileIdle: true,
                                          alarmClock: true,
                                          wakeup: true,
                                          rescheduleOnReboot: true);
                                    }

                                  }
                                }

                                notesController.clear();
                                titleController.clear();
                                setState(() {
                                  startDate = DateTime.now();
                                  endDate = DateTime.now();
                                  selectedColorId = null;
                                  _selectedTime = TimeOfDay.now();
                                  title = "";
                                  selectedDropDownValue = "DAILY";
                                  comment = "";
                                });
                                showAlertDialog(context, objectMap);
                              }
                            } else {
                              if (!endDate.isAfter(startDate)) {
                                final snackBar = SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text(
                                        'End date should be after Start Date.'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else if (title.length < 3) {
                                final snackBar = SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text(
                                        'Title Should have atleast 3 characters'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else if (selectedColorId == null) {
                                final snackBar = SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text('You should select a Color'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else {
                                final snackBar = SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text('Something went wrong'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          })
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod; // Convert 0 to 12 for AM
    final String minute =
        time.minute.toString().padLeft(2, '0'); // Ensure two-digit minute
    final String period = time.period == DayPeriod.am ? "AM" : "PM";

    return "$hour:$minute $period";
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context, initialTime: _selectedTime // Default to current time
        );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _pickStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  void _pickEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }
}

showAlertDialog(BuildContext context, objectMap) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Reminder successfully Created !"),
    content: Text("Reminder will appear shortly in the home page"),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
