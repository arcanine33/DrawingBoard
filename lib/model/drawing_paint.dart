import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawingPaint extends CustomPainter {
  final offsets;
  final List<Color> colorList;

  DrawingPaint(this.offsets, this.colorList);

  @override
  void paint(Canvas canvas, Size size) {
     Paint paint;

     paint = Paint()
       ..strokeWidth = 2.0
       ..isAntiAlias = true;

    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        // 선그리는 중
        paint.color = colorList[i];
        canvas.drawLine(offsets[i], offsets[i + 1], paint);
      } else if (offsets[i] != null && offsets[i + 1] == null) {
        // 그리기 완료
        paint.color = colorList[i];
        canvas.drawPoints(PointMode.points, [offsets[i]], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
