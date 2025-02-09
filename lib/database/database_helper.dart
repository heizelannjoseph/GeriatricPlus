import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DBHelper {
  static Database? _db;
  final dbName = 'geriatricplus_local.db';

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return null;
  }

  initDatabase() async {
    io.Directory? documentDirectory = await getExternalStorageDirectory();
    String pathToDB;
    if (documentDirectory != null) {
      pathToDB = documentDirectory.path;
    } else {
      pathToDB = '/storage/emulated/0/Android/data/plus.geriatric/files';
    }
    String path = join(pathToDB, dbName);
    print(path);
    var db = await openDatabase(path, version: 1, onCreate: _createDatabase);
    return db;
  }

  Future<void> saveToCache(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> removeFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<String?> getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  _createDatabase(Database db, int version) async {
    await db.execute("""
  CREATE TABLE medicine_reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR NOT NULL,
    type VARCHAR NOT NULL,
    time TIME NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    color_id INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)""");
    await db.execute("""
  CREATE TABLE completed_reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE NOT NULL,
    reminder_id INTEGER,
    is_done BOOLEAN NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(reminder_id) REFERENCES medicine_reminders(id)
)""");
  }

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<int> insertReminder(var reminderItem) async {
    // reminderItem {} of the form:
    // {
    //   'title': title,
    //   'type': selectedDropDownValue,
    //   'startDate': startDate,
    //   'endDate': endDate,
    //   'time': _selectedTime,
    //   'color': selectedColorId,
    //   'description': comment
    //  }

    try {
      await db;
      await _db!.rawQuery(""" 
          INSERT INTO 
          medicine_reminders(title,type,time,start_date,end_date,color_id,description) 
          VALUES("${reminderItem['title']}","${reminderItem['type']}",
          "${formatTimeOfDay(reminderItem['time'])}",
          "${reminderItem['startDate']}",
          "${reminderItem['endDate']}",
          "${reminderItem['color']}",
          "${reminderItem['description']}"
          )  
        """);
      return 0;
    } catch (e) {
      print('An Error occured while inserting reminder entry: ${reminderItem}');
      print(e);
      return -1;
    }
  }

  TimeOfDay parseTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<List> getValidReminders(DateTime givenDate) async {
    await db;
    String formattedDate = givenDate.toIso8601String().split('T')[0];

    List allReminders = await _db!.rawQuery(""" 
          SELECT *
          FROM (SELECT m.id AS id, m.title AS title, m.type AS type, m.time AS time,
                  IFNULL(c.is_done, 0) AS is_done, m.start_date AS start_date,
                  m.end_date AS end_date, m.color_id AS color_id, 
                  m.description AS description, 
                  IFNULL(c.created_date, "${formattedDate}") AS created_date 
          FROM medicine_reminders m
          LEFT JOIN completed_reminders c
          ON c.reminder_id = m.id AND c.created_date = "${formattedDate}"
          WHERE "${formattedDate}" >= m.start_date AND "${formattedDate}" <= m.end_date) AS t
          WHERE created_date = "${formattedDate}"
        """);

    List validReminders = allReminders.where((reminder) {
      String type = reminder['type'];
      DateTime startDate = DateTime.parse(reminder['start_date']);

      if (type == 'DAILY') {
        return true;
      } else if (type == 'WEEKLY') {
        int daysDifference = givenDate.difference(startDate).inDays;
        return daysDifference % 7 == 0;
      }
      return false;
    }).toList();

    List res = validReminders
        .map((e) => {...e, 'time': parseTimeOfDay('${e['time']}')})
        .toList();

    return res;
  }

  Future<void> markComplete(DateTime date, int id) async {
    await db;
    String _date = date.toIso8601String().split('T')[0];
    await _db!.rawQuery(
        """insert into completed_reminders(created_date, reminder_id, is_done) 
        VALUES ("${_date}",${id}, 1)""");
  }
}
