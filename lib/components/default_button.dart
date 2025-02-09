import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final press;
  final color;

  const DefaultButton(
      {Key? key,
      required this.text,
      required this.press,
      this.color = Colors.deepPurpleAccent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 46,
      color: color,
      child: TextButton(
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
