import 'package:flutter/cupertino.dart';

class AppText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  final double fontSize;
  final String fontFamily;
  final FontWeight weight;
  const AppText(
      {super.key,
      required this.text,
      this.color = "#000000",
      this.fontSize = 14,
      this.fontFamily = "Aller",
      this.textAlign = TextAlign.start,
      this.weight = FontWeight.normal});

  @override
  Widget build(BuildContext context) {
    //print(color + ' ' + color.replaceAll('#', '0xFF'));
    return Text(
      text,
      softWrap: true,
      textAlign: textAlign,
      style: TextStyle(
          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: weight),
    );
  }
}
