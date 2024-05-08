// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_livreur/misc/colors.dart';
import 'package:letransporteur_livreur/misc/utils.dart';
import 'package:letransporteur_livreur/pages/activites.dart';
import 'package:letransporteur_livreur/pages/notifications.dart';
import 'package:letransporteur_livreur/widgets/component/accueil/accueil_command_manage.dart';
import 'package:letransporteur_livreur/widgets/component/accueil/accueil_no_command.dart';
import 'package:letransporteur_livreur/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_livreur/widgets/select/app_select.dart';
import 'package:letransporteur_livreur/widgets/button/router_button.dart';
import 'package:letransporteur_livreur/widgets/texts/big/big_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_light_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_livreur/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_titre_text.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int step = 0;

  get_command_component() {
    Widget command_component;
    switch (step) {
      case 0:
        command_component = AccueilNoComandComponent();
        break;
      default:
        command_component = AccueilComandManageComponent(step: step);
        break;
    }
    return command_component;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 20), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 10), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Le Transporteur",
                      color: Utils.colorToHex(AppColors.dark)),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Set the radius here
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmallBoldText(text: "Commandes effectuées"),
                  AppSelect<String>(
                    options: ['Aujourd\'hui', 'Une semaine', 'Un mois'],
                    selectedOption: 'Aujourd\'hui',
                    onChanged: (String value) {
                      // Handle selection change here
                      print('Selected: $value');
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15, bottom: 15, left: 0, right: 0),
              child: Container(
                height: 1,
                width: double.infinity,
                color: AppColors.gray5,
              ),
            ),
            GestureDetector(
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 25, right: 25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BigBoldText(
                              text: "5.250", textAlign: TextAlign.center),
                          Padding(
                            padding: EdgeInsets.only(top: 15, left: 5),
                            child: SmallRegularText(
                                text: "F CFA", textAlign: TextAlign.center),
                          )
                        ],
                      ),
                      Container(
                        transform: Matrix4.translationValues(0, -10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SmallRegularText(
                              text: "16 commandes",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
              onTap: () {
                setState(() {
                  if (step == 1) {
                    step = 0;
                  } else {
                    step++;
                  }
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 15, bottom: 0, left: 0, right: 0),
              child: Container(
                height: 1,
                width: double.infinity,
                color: AppColors.gray5,
              ),
            ),
            get_command_component(),
            Padding(
              padding: EdgeInsets.only(top: 0, bottom: 15, left: 0, right: 0),
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

  void onPressed() {}
}
