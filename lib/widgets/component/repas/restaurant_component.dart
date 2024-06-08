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
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class RestaurantComponent extends StatefulWidget {
  RestaurantComponent({
    super.key,
  });

  @override
  State<RestaurantComponent> createState() => _RestaurantComponentState();
}

class _RestaurantComponentState extends State<RestaurantComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      clipBehavior: Clip.none,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary, style: BorderStyle.solid, width: 1)),
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 5,
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Shadow color
                spreadRadius: 4, // Spread radius
                blurRadius: 5, // Blur radius
                offset: Offset(0, 3), // Shadow position
              ),
            ], borderRadius: BorderRadius.circular(100)),
            clipBehavior: Clip.antiAlias,
            child: Image(
              image: AssetImage("assets/img/logo-restau-1.png"),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                MediumTitreText(text: 'Festival des glaces'),
                SizedBox(height: 5),
                SmallRegularText(text: 'Lun au Dim. 08h à 23h'),
                XSmallLightText(
                    text: 'Mets Européen • Africain • Fast food • Chawarma'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
