// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';

class Activites extends StatefulWidget {
  const Activites({super.key});

  @override
  State<Activites> createState() => _ActivitesState();
}

class _ActivitesState extends State<Activites> {
  @override
  Widget build(BuildContext context) {
    var isSelected = [false, false, false, false, false];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 20), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 10), // Add bottom padding
          child: AppBar(
            title: Container(
                child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LargeBoldText(
                        text: "Activités",
                        color: Utils.colorToHex(AppColors.dark)),
                    RouterButton(
                      destination: Notifications(),
                      child_type: "svgimage",
                      svg_image_size: "wx25",
                      svg_path: "assets/SVG/notif-unread.svg",
                    ),
                  ],
                ),
              ],
            )),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(0), // Set the radius here
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        width: double.infinity,
        transform: Matrix4.translationValues(0, -20, 0),
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primary,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                        background_color: isSelected[0]
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        text: "Tout",
                        text_size: "small",
                        text_weight: "bold",
                        border_radius_size: "large",
                        onPressed: () {
                          setState(() {
                            isSelected[0] = !isSelected[0];
                            print(["isSelected", isSelected]);
                          });
                        }),
                    SizedBox(width: 10),
                    AppButton(
                        background_color: isSelected[2]
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        text: "En cours",
                        text_size: "small",
                        text_weight: "bold",
                        border_radius_size: "large",
                        onPressed: () {
                          setState(() {
                            isSelected[2] = !isSelected[2];
                            print(["isSelected", isSelected]);
                          });
                        }),
                    SizedBox(width: 10),
                    AppButton(
                        background_color: isSelected[4]
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        text: "Terminées",
                        text_size: "small",
                        text_weight: "bold",
                        border_radius_size: "large",
                        onPressed: () {
                          setState(() {
                            isSelected[4] = !isSelected[4];
                            print(["isSelected", isSelected]);
                          });
                        }),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.activites),
    );
  }

  void onPressed() {}
}
