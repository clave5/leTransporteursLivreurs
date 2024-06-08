// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/commande_repas.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/repas/repas_picker_component.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class CategorieComponent extends StatefulWidget {
  CategorieComponent({
    super.key,
  });

  @override
  State<CategorieComponent> createState() => _CategorieComponentState();
}

class _CategorieComponentState extends State<CategorieComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RepasPickerComponent(
                    repas_list: [],
                    widget_title: "Catégorie",
                  )),
        );
        // If a result is returned, update the state.
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            clipBehavior: Clip.none,
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/img/categorie-diner-back.png"),
                    ),
                  ),
                ),
                Container(
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: 120,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.05), // Shadow color
                            spreadRadius: 2, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset: Offset(0, 3), // Shadow position
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.elliptical(75, 30),
                            topRight: Radius.elliptical(75, 30))),
                    transform: Matrix4.translationValues(0.0, -40.0, 0.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        MediumBoldText(text: "Diner"),
                        SizedBox(
                          height: 5,
                        ),
                        AppButton(
                            onPressed: () {
                              Utils.log("caret");
                            },
                            child_type: "icon",
                            icon_size: "22x22",
                            foreground_color: AppColors.dark,
                            icon: Icon(
                              Icons.keyboard_arrow_right,
                              size: 15,
                              color: Colors.white,
                            ),
                            background_color: AppColors.primary),
                      ],
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
