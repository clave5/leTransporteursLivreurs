// widgets/texts/medium/medium_light_text.dart
import 'package:flutter/cupertino.dart';import 'package:flutter/cupertino.dart';
import 'package:letransporteur_client/widgets/texts/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MediumLightText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const MediumLightText(
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
      fontSize: 16.sp,
      weight: FontWeight.w300,
    );
  }
}
