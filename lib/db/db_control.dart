import 'dart:ui';

import 'package:Drawing/model/drawing.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final List<String> createTablesSQL = [
  'CREATE TABLE DRAW (ID_CODE INTEGER PRIMARY KEY AUTOINCREMENT, '
      'OFFSET TEXT, FILE_PATH TEXT, UP_DATE TEXT, COLOR_LIST TEXT)'
];

class DBControl {
  static Database _database;
  static final String dbName = 'drawing.db';
  static bool isUpgrade = false;
  static final int dbVersion = 1;

  static Future<String> _getDataBasePath() async {
    String path;

    path = await getDatabasesPath();
    return join(path, dbName);
  }

  static Future<Database> open() async {
    _database = await openDatabase(
      await _getDataBasePath(),
      version: dbVersion,
      onCreate: (Database db, int version) async {
        for (String sql in createTablesSQL) {
          await db.execute(sql);
        }
      },
    );
    return _database;
  }

  static Future<void> insert(String offsets, String filePath, bool isPen, String colorList) async {

    if(_database == null)
      await open();

    Drawing saveFile = Drawing(
      offsets: offsets,
      update: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    filePath: filePath, colorList: colorList);

    await _database.insert('DRAW', saveFile.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Drawing>> selectAll() async {
    if(_database == null)
      await open();

    List<Map<String, dynamic>> queryList = await _database.query('DRAW', orderBy: 'UP_DATE');

    return List.generate(queryList.length, (index) => Drawing.fromJson(queryList[index]));
  }
}