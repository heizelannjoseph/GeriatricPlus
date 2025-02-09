import 'package:flutter/material.dart';
import 'package:dashboard_screen/database/database_helper.dart';
import 'dart:isolate';
import 'package:dashboard_screen/services/notification_service.dart';

String defaultNotificationId = '7e91aed5-0286-44b8-a6ee-cb00b0f77caf';

bool showTimer = true;

bool globalShowProgress = false;
ValueNotifier<List> selectedDateReminders = ValueNotifier<List>([]);
DateTime selectedDate = DateTime.now();

NotificationsService nService = NotificationsService();

@pragma('vm:entry-point')
void showNotificationForMedicine() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  nService.sendNotification('Its time to have your medicine',
      'Time: ${now.hour}:${now.minute}:${now.second}',
      id: defaultNotificationId, name: 'medicine');
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

var data = []; // Stores the List of items in CSV
var items = [];
bool status = true;

final List<Color> colors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.brown,
  Colors.purple,
];

class _HomePageState extends State<HomePage> {
  DBHelper? dbHelper;
  bool showProgress = false;

  @override
  void initState() {
    dbHelper = DBHelper();
    getSelectedDateReminders().then((list) {
      selectedDateReminders.value = list;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSelectedDateReminders() async {
    setState(() {
      showProgress = true;
    });
    DateTime now = DateTime.now();
    List data = await dbHelper!.getValidReminders(now);

    setState(() {
      selectedDateReminders.value = data;
      showProgress = false;
    });
    return data;
  }

  final List<DateTime> dates =
      List.generate(31, (index) => DateTime.now().add(Duration(days: index)));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder<List>(
        valueListenable: selectedDateReminders,
        builder: (context, value, child) {
          return showProgress
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: Container(
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: dates.length,
                          itemBuilder: (context, index) {
                            final date = dates[index];
                            final isSelected = date.day == selectedDate.day;
                            return GestureDetector(
                              onTap: () async {
                                List newList =
                                    await dbHelper!.getValidReminders(date);
                                setState(() {
                                  selectedDate = date;
                                  selectedDateReminders.value = newList;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.indigo
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '${_getMonth(date)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: selectedDateReminders.value.length == 0
                            ? Center(
                                child: Container(
                                  child: Text("Nothing to Show"),
                                ),
                              )
                            : ListView.builder(
                                itemCount: selectedDateReminders.value.length,
                                itemBuilder: (context, index) {
                                  final reminder =
                                      selectedDateReminders.value[index];
                                  return ReminderBox(
                                    description: reminder['description'],
                                    title: reminder['title'],
                                    time: reminder['time'],
                                    colorId: reminder['color_id'],
                                    id: reminder['id'],
                                    isComplete: reminder['is_done'],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ));
        });
  }

  String _getDay(DateTime date) {
    return ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][date.weekday];
  }

  String _getMonth(DateTime date) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][date.month - 1];
  }
}

class ReminderBox extends StatefulWidget {
  final String title;
  final TimeOfDay time;
  final String description;
  final int colorId;
  final int isComplete;
  final int id;

  const ReminderBox(
      {required this.title,
      required this.time,
      required this.description,
      required this.colorId,
      required this.id,
      required this.isComplete});

  @override
  State<ReminderBox> createState() => _ReminderBoxState();
}

class _ReminderBoxState extends State<ReminderBox> {
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colors[widget.colorId],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey[200],
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(widget.time),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            widget.isComplete == 1
                ? IconButton(
                    icon: Icon(Icons.check, color: Colors.white),
                    onPressed: () async {},
                  )
                : Radio(
                    value: true,
                    groupValue: false,
                    onChanged: (bool? value) async {
                      DBHelper dbHelper = DBHelper();
                      await dbHelper.markComplete(selectedDate, widget.id);
                      List newList =
                          await dbHelper.getValidReminders(selectedDate);
                      setState(() {
                        selectedDateReminders.value = newList;
                      });
                    },
                    activeColor: Colors.white,
                  ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(TimeOfDay time) {
  final int hour =
      time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod; // Convert 0 to 12 for AM
  final String minute =
      time.minute.toString().padLeft(2, '0'); // Ensure two-digit minute
  final String period = time.period == DayPeriod.am ? "AM" : "PM";

  return "$hour:$minute $period";
}
