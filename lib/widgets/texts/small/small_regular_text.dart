// widgets/texts/small/small_regular_text.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:letransporteur_client/widgets/texts/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmallRegularText extends StatelessWidget {
  final String text;
  final String color;
  final TextAlign textAlign;
  const SmallRegularText(
      {super.key,
      required this.text,
      this.textAlign = TextAlign.start,
      this.color = "#000000"});

  @override
  Widget build(BuildContext context) {
    return AppText(
        text: text, color: color, fontSize: 14.sp, textAlign: textAlign);
  }
}
