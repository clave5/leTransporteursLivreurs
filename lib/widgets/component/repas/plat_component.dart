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
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class PlatComponent extends StatefulWidget {
  PlatComponent({
    super.key,
  });

  @override
  State<PlatComponent> createState() => _PlatComponentState();
}

class _PlatComponentState extends State<PlatComponent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.none,
          child: Column(
            children: [
              Container(
                width: Utils.REPAS_WIDGET_DEFAULT_WIDTH,
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
                    image: AssetImage("assets/img/plat-image-1.jpg"),
                  ),
                ),
                child: IntrinsicWidth(
                  child: AppButton(
                      onPressed: () {},
                      child_type: "icon",
                      icon_size: "small",
                      force_height: 30,
                      icon: Icon(
                        Icons.star,
                        size: 15,
                        color: AppColors.dark,
                      ),
                      with_text: true,
                      text: "4.8",
                      text_size: "small",
                      text_align: TextAlign.left,
                      text_weight: "bold",
                      padding: [0, 0, 0, 0],
                      foreground_color: AppColors.dark,
                      border_radius_size: "normal",
                      border_radius_only: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      border: [AppColors.primary, 2.0, BorderStyle.solid],
                      background_color: Colors.white.withOpacity(0.8)),
                ),
              ),
              Container(
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: Utils.REPAS_WIDGET_DEFAULT_WIDTH,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // Shadow color
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
                  transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      MediumBoldText(text: "Assiette Burger"),
                      XSmallLightText(text: "Festival des glaces"),
                      SizedBox(
                        height: 5,
                      ),
                      SmallBoldText(text: "4.500 F CFA")
                    ],
                  ))
            ],
          ),
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 5,
            child: FractionallySizedBox(
                widthFactor: 0.8,
                child: RouterButton(
                    destination: CommandeRepas(),
                    child_type: "text",
                    force_height: 35,
                    svg_image_size: "wx16",
                    text: "+ Ajouter",
                    text_size: "small",
                    padding: [0, 0, 0, 0],
                    text_align: TextAlign.center,
                    text_weight: "titre",
                    foreground_color: AppColors.dark,
                    border_radius_size: "large",
                    background_color: AppColors.primary)))
      ],
    );
  }
}
