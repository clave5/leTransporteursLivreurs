// widgets/component/other/info_box_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';

class InfoBoxComponent extends StatefulWidget {
  String title;
  String content;
  Icon? icon;
  Map<String, dynamic> button_widget;
  InfoBoxComponent(
      {super.key,
      this.title = "",
      this.content = "",
      this.icon,
      required this.button_widget});

  @override
  State<InfoBoxComponent> createState() => _InfoBoxComponentState();
}

class _InfoBoxComponentState extends State<InfoBoxComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            transform: Matrix4.translationValues(10.sp, 10.sp, 0),
            padding: EdgeInsets.only(left: 5.sp),
            child: SmallRegularText(
              text: widget.title,
              color: Utils.colorToHex(AppColors.gray3),
            ),
          ),
          SizedBox(height: 5.sp),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                border: Border.all(
                  color: AppColors.gray5,
                )),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, left: 20.sp, right: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Container(
                            padding:
                                EdgeInsets.only(right: 10.sp, top: 15.sp, bottom: 15.sp),
                            child: Row(
                              children: [
                                widget.icon != null
                                    ? Row(
                                        children: [
                                          Container(child: widget.icon),
                                          SizedBox(
                                            width: 10.sp,
                                          )
                                        ],
                                      )
                                    : Container(),
                                Flexible(child: SmallBoldText(text: widget.content)),
                              ],
                            ))),
                    widget.button_widget["app_button"] == null
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.symmetric(vertical: 7),
                            child: widget.button_widget["app_button"] == true
                                ? AppButton(
                                    force_height: 30.sp,
                                    onPressed:
                                        widget.button_widget["on_pressed"],
                                    with_text:
                                        widget.button_widget["with_text"] ??
                                            true,
                                    svg_path: widget.button_widget["svg_path"],
                                    child_type: "svgimage",
                                    background_color: widget.button_widget[
                                                "background_color"] !=
                                            null
                                        ? widget.button_widget[
                                            "background_color"] as Color
                                        : AppColors.primary,
                                    foreground_color: widget.button_widget[
                                                "foreground_color"] !=
                                            null
                                        ? widget.button_widget[
                                            "foreground_color"] as Color
                                        : AppColors.dark,
                                    padding: widget.button_widget["padding"] ??
                                        [0, 15.sp, 0, 15.sp],
                                    border_radius_size: "large",
                                    svg_image_size: "wx15",
                                    text: widget.button_widget["text"],
                                    text_weight: "bold",
                                    text_size: "xsmall",
                                  )
                                : RouterButton(
                                    force_height: 30.sp,
                                    destination:
                                        widget.button_widget["destination"],
                                    with_text: true,
                                    svg_path: widget.button_widget["svg_path"],
                                    child_type: "svgimage",
                                    background_color: AppColors.primary,
                                    padding: [0, 15.sp, 0, 15.sp],
                                    border_radius_size: "large",
                                    svg_image_size: "wx15",
                                    text: widget.button_widget["text"],
                                    text_weight: "bold",
                                    text_size: "xsmall",
                                  ))
                  ],
                )),
          )
        ],
      ),
    );
  }
}
