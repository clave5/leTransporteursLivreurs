import 'package:flutter/cupertino.dart';
import 'package:letransporteur_client/widgets/texts/app_text.dart';

class SmallTitreText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const SmallTitreText({super.key, required this.text, this.textAlign = TextAlign.start,this.color = "#000000"});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
textAlign: textAlign,
      color: color,
      fontFamily: "Aller Display",
    );
  }
}
