// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/component/accueil/client_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/other/info_box_component.dart';
import 'package:letransporteur_client/widgets/component/other/livreur_progress_bar_component.dart';
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

class AccueilComandManageComponent extends StatefulWidget {
  int step = 1;
  AccueilComandManageComponent({super.key, required int step});

  @override
  State<AccueilComandManageComponent> createState() =>
      _AccueilComandManageComponentState();
}

class _AccueilComandManageComponentState
    extends State<AccueilComandManageComponent> {
  @override
  Widget build(BuildContext context) {
    setStep(int step) {
      setState(() {
        print('setting step ${step}');
        widget.step = step;
      });
    }

    var livreurProgressBarComponent = LivreurProgressBarComponent(
      step: widget.step,
      stepChanged: (int newStep) {
        setStep(newStep); // Update child width
      },
    );

    get_livreur_cta() {
      var cta_buttom;
      switch (widget.step) {
        case 1:
          cta_buttom = AppButton(
              background_color: AppColors.gray2,
              child_type: "svgimage",
              text: "JE SUIS LÀ !",
              with_text: true,
              text_size: "normal",
              svg_path: "assets/SVG/circle_check.svg",
              foreground_color: Colors.white,
              text_weight: "bold",
              onPressed: () {
                print("JE SUIS LÀ !");
              });
          break;
        case 2:
          cta_buttom = AppButton(
              background_color: AppColors.orange,
              child_type: "svgimage",
              text: "DEMARRER",
              with_text: true,
              text_size: "normal",
              svg_path: "assets/SVG/circle_check.svg",
              foreground_color: Colors.white,
              text_weight: "bold",
              onPressed: () {
                print("DEMARRER");
              });
          break;
        case 3:
          cta_buttom = AppButton(
              background_color: Colors.green,
              child_type: "svgimage",
              text: "TERMINER",
              with_text: true,
              text_size: "normal",
              svg_path: "assets/SVG/circle_check.svg",
              foreground_color: Colors.white,
              text_weight: "bold",
              onPressed: () {
                print("TERMINER");
              });
          break;
        case 4:
          cta_buttom = AppButton(
              background_color: AppColors.gray2,
              child_type: "svgimage",
              text: "VOIR DÉTAILS →",
              with_text: true,
              text_size: "normal",
              svg_path: "assets/SVG/circle_check.svg",
              foreground_color: Colors.white,
              text_weight: "bold",
              onPressed: () {
                print("VOIR DÉTAILS →");
              });
          break;
        default:
          break;
      }
      return cta_buttom;
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          child: Padding(
              padding:
                  EdgeInsets.only(top: 30, bottom: 60, left: 25, right: 25),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.gray2),
                    width: double.infinity,
                    height: 50,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MediumBoldText(
                            text: "Livraison • 600 F CFA",
                            color: Utils.colorToHex(Colors.white),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: ClientComponent()),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: InfoBoxComponent(
                        title: "Lieu de récupération",
                        content: "Ganhi, Rue 12457",
                        button_widget: {
                          "destination": Accueil(),
                          "svg_path": "assets/SVG/map-marker--icon-dark.svg",
                          "text": "ITINÉRAIRE →",
                        }),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: InfoBoxComponent(
                        title: "Contact de récupération",
                        content: "+229 65 65 65 65",
                        button_widget: {
                          "destination": Accueil(),
                          "svg_path": "assets/SVG/phone-icon-gray.svg",
                          "text": "APPELER",
                        }),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: livreurProgressBarComponent,
                  ),
                ],
              )),
        ),
        Padding(
          padding: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
          child: Container(
            height: 1,
            width: double.infinity,
            color: AppColors.gray5,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Row(
                  children: [Spacer(), get_livreur_cta()],
                ))),
        Padding(
          padding: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
          child: Container(
            height: 1,
            width: double.infinity,
            color: AppColors.gray5,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: SmallLightText(
                    color: Utils.colorToHex(AppColors.gray3),
                    textAlign: TextAlign.center,
                    text: "2 autres commandes en attente")))
      ],
    );
  }
}
