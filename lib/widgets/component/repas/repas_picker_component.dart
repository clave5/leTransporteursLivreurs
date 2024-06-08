// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/commande_repas.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/repas/plat_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class RepasPickerComponent extends StatefulWidget {
  List<dynamic> repas_list = [];
  String widget_title = "Repas";
  RepasPickerComponent(
      {super.key, required this.repas_list, required this.widget_title});

  @override
  State<RepasPickerComponent> createState() => _RepasPickerComponentState();
}

class _RepasPickerComponentState extends State<RepasPickerComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight), // Adjust height as needed

        child: Padding(
          padding: EdgeInsets.only(bottom: 0), // Add bottom padding
          child: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Set the radius here
              ),
            ),
            title: Container(
              child: Row(
                children: [
                  LargeBoldText(
                      text: widget.widget_title,
                      color: Utils.colorToHex(AppColors.dark)),
                  Spacer(),
                  RouterButton(
                    destination: Notifications(),
                    child_type: "svgimage",
                    svg_image_size: "wx25",
                    svg_path: "assets/SVG/notif-unread.svg",
                  ),
                ],
              ),
            ),
            backgroundColor: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.only(top: 0),
        color: AppColors.gray7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 15,
            ),
            GroupButton(
              buttons: get_plats_categories(),
              onSelected: (value, index, isSelected) {
                
              },
              buttonBuilder: (selected, categorie, context) {
                return Container(
                  decoration: BoxDecoration(
                      color: selected == true
                          ? AppColors.primary
                          : Colors.transparent,
                      border: selected == true
                          ? null
                          : Border.all(width: 1.0, color: AppColors.primary),
                      borderRadius: BorderRadius.circular(100)),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: SmallBoldText(text: categorie as String),
                );
              },
            ),
            SizedBox(
              height: 15,
            ),
            Wrap(
              direction: Axis.horizontal,
              spacing: 15,
              runSpacing: 25,
              children: [
                PlatComponent(),
                PlatComponent(),
                PlatComponent(),
                PlatComponent(),
                PlatComponent(),
                PlatComponent(),
                PlatComponent(),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 15, left: 0, right: 0),
              child: Container(
                height: 1,
                width: double.infinity,
                color: AppColors.gray5,
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.accueil),
    );
  }

  get_plats_categories() {
    return ["Diner", "Européen", "Asiatique"];
  }
}
