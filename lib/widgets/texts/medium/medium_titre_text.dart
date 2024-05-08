import 'package:flutter/cupertino.dart';
import 'package:letransporteur_livreur/widgets/texts/app_text.dart';

class MediumTitreText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const MediumTitreText({super.key, required this.text, this.textAlign = TextAlign.start,this.color = "#000000"});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
textAlign: textAlign,
      color: color,
      fontSize: 16,
      fontFamily: "Aller Display",
    );
  }
}
