// widgets/texts/large/large_bold_text.dart
import 'package:flutter/cupertino.dart';import 'package:flutter/cupertino.dart';
import 'package:letransporteur_client/widgets/texts/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';


class LargeBoldText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const LargeBoldText(
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
        fontSize: 24.sp,
        weight: FontWeight.bold);
  }
}
