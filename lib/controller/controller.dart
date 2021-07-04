
import 'dart:convert';
import 'dart:ui';

import 'package:Drawing/model/drawing.dart';
import 'package:Drawing/db/db_control.dart';

final controller = Controller();
class Controller {

  Future<List<Drawing>> getSaveList () async  {
    return await DBControl.selectAll();
  }

  Future<void> saveData (List<Offset> offsets, String file, bool isPen, List<Color> colorList) async {
    var offsetsList = offsets.map((e) {
      if(e == null) {
        return [null, null];
      } else {
        return [e.dx, e.dy];
      }
    }).toList();

    String offsetsJson = json.encode(offsetsList);

    var color = colorList.map((e) => e.toString()).toList();
    String colorJson = json.encode(color);

    await DBControl.insert(offsetsJson, file, isPen, colorJson);
  }
}