import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RaisedBtn extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final IconData icon;
  final Color color;

  RaisedBtn({this.text, this.onPressed, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    if(text != null)
    return Expanded(
      child: RaisedButton(
        color: color,
        child: Text('$text'),
        onPressed: onPressed,
      ),
    );
    else
      return Expanded(
          child: IconButton(
            icon: Icon(icon),
            color: Colors.white,
            onPressed: onPressed,
      ),);
  }
}
