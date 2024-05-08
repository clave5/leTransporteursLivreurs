import 'package:flutter/cupertino.dart';
import 'package:letransporteur_livreur/widgets/texts/app_text.dart';

class SmallBoldText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const SmallBoldText(
      {super.key,
      required this.text,
      this.textAlign = TextAlign.start,
      this.color = "#000000"});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      textAlign: textAlign,
      color: color,
      weight: FontWeight.bold,
    );
  }
}
