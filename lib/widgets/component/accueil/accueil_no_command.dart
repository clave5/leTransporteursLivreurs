// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/select/app_select.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/big/big_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_light_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';

class AccueilNoComandComponent extends StatefulWidget {
  const AccueilNoComandComponent({super.key});

  @override
  State<AccueilNoComandComponent> createState() => _AccueilNoComandComponentState();
}

class _AccueilNoComandComponentState extends State<AccueilNoComandComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          child: Padding(
              padding:
                  EdgeInsets.only(top: 60, bottom: 60, left: 25, right: 25),
              child: Column(
                children: [
                  SvgPicture.asset(
                    "assets/SVG/no-commandes.svg", // Path to your SVG asset
                    height: 80,
                    color: AppColors.gray5,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: MediumBoldText(
                              textAlign: TextAlign.center,
                              text: "Vous n'avez pas de commande en cours"))),
                  Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: SmallLightText(
                              textAlign: TextAlign.center,
                              text:
                                  "Dès qu’une commande vous sera affectée, vous verrez ses détails ici."))),
                ],
              )),
        ),
      ],
    );
  }
}
