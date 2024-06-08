// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/misc/colors.dart';
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
  Map<String, dynamic> button_widget;
  InfoBoxComponent(
      {super.key,
      this.title = "",
      this.content = "",
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
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: SmallRegularText(
              text: widget.title,
            ),
          ),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gray5,
                )),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Container(
                            padding: EdgeInsets.only(right: 10),
                            child: SmallBoldText(text: widget.content))),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: widget.button_widget["app_button"] == true
                            ? AppButton(
                                force_height: 30,
                                onPressed: widget.button_widget["on_pressed"],
                                with_text: widget.button_widget["with_text"] ?? true,
                                svg_path: widget.button_widget["svg_path"],
                                child_type: "svgimage",
                                background_color: widget.button_widget[
                                            "background_color"] !=
                                        null
                                    ? widget.button_widget["background_color"]
                                        as Color
                                    : AppColors.primary,
                                foreground_color: widget.button_widget[
                                            "foreground_color"] !=
                                        null
                                    ? widget.button_widget["foreground_color"]
                                        as Color
                                    : AppColors.dark,
                                padding: widget.button_widget["padding"] ??
                                    [0, 15, 0, 15],
                                border_radius_size: "large",
                                svg_image_size: "wx15",
                                text: widget.button_widget["text"],
                                text_weight: "bold",
                                text_size: "xsmall",
                              )
                            : RouterButton(
                                force_height: 30,
                                destination:
                                    widget.button_widget["destination"],
                                with_text: true,
                                svg_path: widget.button_widget["svg_path"],
                                child_type: "svgimage",
                                background_color: AppColors.primary,
                                padding: [0, 15, 0, 15],
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
