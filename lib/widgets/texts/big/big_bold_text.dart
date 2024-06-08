import 'package:flutter/cupertino.dart';
import 'package:letransporteur_client/widgets/texts/app_text.dart';

class BigBoldText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const BigBoldText({super.key, required this.text, this.textAlign = TextAlign.start,this.color = "#000000"});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
textAlign: textAlign,
      color: color,
      fontSize: 52,
      weight: FontWeight.bold
    );
  }
}
