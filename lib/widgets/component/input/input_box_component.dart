// widgets/component/input/input_box_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';

class InputBoxComponent extends StatefulWidget {
  String title;
  String content;
  AppButton? button_widget;
  InputBoxComponent(
      {super.key, this.title = "", this.content = "", this.button_widget});

  @override
  State<InputBoxComponent> createState() => _InputBoxComponentState();
}

class _InputBoxComponentState extends State<InputBoxComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5.sp),
            child: SmallRegularText(
              text: widget.title,
            ),
          ),
          SizedBox(height: 5.sp),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gray5,
                )),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    SmallBoldText(text: widget.content),
                    Spacer(),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: widget.button_widget)
                  ],
                )),
          )
        ],
      ),
    );
  }
}
