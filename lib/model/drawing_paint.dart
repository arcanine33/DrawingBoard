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
       ..strokeWidth = 3.0
       ..isAntiAlias = true;

     canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        // 선그리는 중
        if(colorList[i] == Colors.white)
         paint.blendMode = BlendMode.clear;
        else
          paint.color = colorList[i];

         canvas.drawLine(offsets[i], offsets[i + 1], paint);

      } else if (offsets[i] != null && offsets[i + 1] == null) {
        // 그리기 완료
        if(colorList[i] == Colors.white)
          paint.blendMode = BlendMode.clear;
        else
          paint.color = colorList[i];

        canvas.drawPoints(PointMode.points, [offsets[i]], paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
