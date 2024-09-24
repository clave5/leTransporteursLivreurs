// widgets/texts/xsmall/xsmall_bold_text.dart
import 'package:flutter/cupertino.dart';import 'package:flutter/cupertino.dart';
import 'package:letransporteur_client/widgets/texts/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class XSmallBoldText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const XSmallBoldText({super.key, required this.text, this.textAlign = TextAlign.start,this.color = "#000000"});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
textAlign: textAlign,
      color: color,
      fontSize: 12.sp,
      weight: FontWeight.bold,
    );
  }
}
