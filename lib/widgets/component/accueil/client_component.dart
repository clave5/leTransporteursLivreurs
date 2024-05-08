// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_livreur/misc/colors.dart';
import 'package:letransporteur_livreur/misc/utils.dart';
import 'package:letransporteur_livreur/pages/activites.dart';
import 'package:letransporteur_livreur/pages/messagerie.dart';
import 'package:letransporteur_livreur/pages/notifications.dart';
import 'package:letransporteur_livreur/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_livreur/widgets/select/app_select.dart';
import 'package:letransporteur_livreur/widgets/button/router_button.dart';
import 'package:letransporteur_livreur/widgets/texts/big/big_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_light_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_livreur/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_titre_text.dart';

class ClientComponent extends StatefulWidget {
  const ClientComponent({super.key});

  @override
  State<ClientComponent> createState() => _ClientComponentState();
}

class _ClientComponentState extends State<ClientComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary, width: 1), // Set border color and width
            ),
            child: ClipOval(
              child: Image(image: AssetImage("assets/img/client_avatar.jpg")),
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MediumBoldText(text: "Dossou ASSOGBA"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.star), MediumTitreText(text: "4.8")],
              )
            ],
          ),
          Spacer(),
          RouterButton(
            destination: Messagerie(),
            background_color: AppColors.primary,
            child_type: "svgimage",
            padding: [0, 5, 0, 5],
            svg_path: "assets/SVG/message-icon-dark.svg",
          )
        ],
      ),
    );
  }
}
