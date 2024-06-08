// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/commande_livraison.dart';
import 'package:letransporteur_client/pages/commande_taxi.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/pages/repas.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_command_manage.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_no_command.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/repas/plat_component.dart';
import 'package:letransporteur_client/widgets/select/app_select.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/big/big_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_light_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Accueil extends StatefulWidget {
  final String? token;
  const Accueil({super.key, this.token = ""});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int step = 0;
  FormGroup search_form = FormGroup({
    'search': FormControl<String>(validators: []),
  });

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
  void initState() {
    Utils.log(widget.token);
    if (widget.token != null) {
      get_request(
        "${API_BASE_URL}/client/index", // API URL
        widget.token!,
        {}, // Query parameters (if any)
        (response) {
          Utils.log(response);
          setState(() {});
        },
        (error) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 0), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                children: [
                  LargeBoldText(
                      text: "Le Transporteur",
                      color: Utils.colorToHex(AppColors.dark)),
                  Spacer(),
                  RouterButton(
                    destination: Activites(),
                    child_type: "svgimage",
                    svg_image_size: "wx16",
                    border: [AppColors.primary, 1.5, BorderStyle.solid],
                    force_height: 30,
                    padding: [0, 0, 0, 0],
                    text: "2",
                    svg_path: "assets/SVG/encours-activite-icon-dark.svg",
                    foreground_color: AppColors.dark,
                    with_text: true,
                    text_size: "normal",
                    text_weight: "bold",
                    border_radius_size: "normal",
                    background_color: AppColors.primary.withOpacity(0.5),
                  ),
                  RouterButton(
                    destination: Notifications(),
                    child_type: "svgimage",
                    svg_image_size: "wx25",
                    svg_path: "assets/SVG/notif-unread.svg",
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            search_widget(),
            que_desirez_vous_widget(),
            repeter_dernieres_commandes(),
            flash_news(),
            parrainage(),
            recommandation_repas(),
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

  void onPressed() {}

  que_desirez_vous_widget() {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 25, left: 35, right: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MediumTitreText(
              text: "Que désirez-vous aujourdhui ?",
              color: Utils.colorToHex(AppColors.dark),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    RouterButton(
                      destination: CommandeLivraison(),
                      child_type: "image",
                      image_size: "wx35",
                      force_height: 60,
                      text: "Livraison",
                      image_path: "assets/img/livraison-image.png",
                      foreground_color: AppColors.dark,
                      with_text: true,
                      text_size: "normal",
                      text_weight: "bold",
                      border: [AppColors.primary, 1.5, BorderStyle.solid],
                      border_radius_size: "normal",
                      background_color: Colors.white,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RouterButton(
                      destination: CommandeTaxi(),
                      child_type: "image",
                      image_size: "wx35",
                      force_height: 60,
                      text: "Taxi privé",
                      image_path: "assets/img/taxi-image.png",
                      foreground_color: AppColors.dark,
                      with_text: true,
                      text_size: "normal",
                      text_weight: "bold",
                      border: [AppColors.primary, 1.5, BorderStyle.solid],
                      border_radius_size: "normal",
                      background_color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                RouterButton(
                  destination: Repas(
                    token: widget.token,
                  ),
                  child_type: "image",
                  image_size: "wx65",
                  orientation: "vertical",
                  force_height: 130,
                  text: "Restaurants",
                  image_path: "assets/img/repas-image.png",
                  foreground_color: AppColors.dark,
                  with_text: true,
                  text_size: "normal",
                  text_weight: "bold",
                  border: [AppColors.primary, 1.5, BorderStyle.solid],
                  border_radius_size: "normal",
                  background_color: Colors.white,
                ),
              ],
            ),
          ],
        ));
  }

  search_widget() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 25, right: 25),
      child: ReactiveForm(
          formGroup: search_form,
          child: Column(
            children: [
              ReactiveTextField(
                formControlName: 'search',
                decoration: Utils.get_default_input_decoration(
                    'Rechercher un restaurant, plat, etc.',
                    Icons.search,
                    null,
                    null),
              )
            ],
          )),
    );
  }

  repeter_dernieres_commandes() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 35, right: 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MediumTitreText(
            text: "Répéter vos dernières commandes",
            color: Utils.colorToHex(AppColors.dark),
          ),
          SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  width: 220,
                  decoration: BoxDecoration(
                    boxShadow: [],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: XSmallBoldText(
                          text: "Livraison récente",
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(10))),
                        child: Row(
                          children: [
                            Icon(Icons.pin_drop),
                            SizedBox(
                              width: 5,
                            ),
                            XSmallBoldText(
                              text: "Rue 152 près de Kindonou",
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  width: 220,
                  decoration: BoxDecoration(
                    boxShadow: [],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: XSmallBoldText(
                          text: "Livraison récente",
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(10))),
                        child: Row(
                          children: [
                            Icon(Icons.pin_drop),
                            SizedBox(
                              width: 5,
                            ),
                            XSmallBoldText(
                              text: "Rue 152 près de Kindonou",
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  flash_news() {
    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 35, right: 35),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              Container(
                width: 280,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                decoration: BoxDecoration(
                  boxShadow: [],
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/img/flash-news-1.jpg"), // Replace with your image URL
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediumTitreText(
                        text: "Commandez un repas",
                        color: Utils.colorToHex(Colors.white)),
                    XSmallBoldText(
                        color: Utils.colorToHex(Colors.white),
                        text:
                            "Choisissez parmi une variété de restaurants et soyez livré.e dans les plus brefs délais."),
                    SizedBox(
                      height: 10,
                    ),
                    IntrinsicWidth(
                      child: RouterButton(
                          destination: Activites(),
                          child_type: "svgimage",
                          svg_image_size: "wx16",
                          force_height: 30,
                          with_text: true,
                          flex_reverse: true,
                          text: "Parcourir",
                          text_size: "small",
                          text_align: TextAlign.left,
                          text_weight: "bold",
                          padding: [0, 0, 0, 0],
                          svg_path: "assets/SVG/caret-yellow-white.svg",
                          foreground_color: Colors.white,
                          border_radius_size: "normal",
                          background_color: Colors.transparent),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                width: 280,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                decoration: BoxDecoration(
                  boxShadow: [],
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/img/flash-news-1.jpg"), // Replace with your image URL
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediumTitreText(
                        text: "Commandez un repas",
                        color: Utils.colorToHex(Colors.white)),
                    XSmallBoldText(
                        color: Utils.colorToHex(Colors.white),
                        text:
                            "Choisissez parmi une variété de restaurants et soyez livré.e dans les plus brefs délais."),
                    SizedBox(
                      height: 10,
                    ),
                    IntrinsicWidth(
                      child: RouterButton(
                          destination: Activites(),
                          child_type: "svgimage",
                          svg_image_size: "wx16",
                          force_height: 30,
                          with_text: true,
                          flex_reverse: true,
                          text: "Parcourir",
                          text_size: "small",
                          text_align: TextAlign.left,
                          text_weight: "bold",
                          padding: [0, 0, 0, 0],
                          conserve_svg_image_color: true,
                          svg_path: "assets/SVG/caret-yellow-white.svg",
                          foreground_color: Colors.white,
                          border_radius_size: "normal",
                          background_color: Colors.transparent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  parrainage() {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 35, right: 35),
      child: Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          decoration: BoxDecoration(
            boxShadow: [],
            image: DecorationImage(
              image: AssetImage(
                  "assets/img/parrainage-back.png"), // Replace with your image URL
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallTitreText(text: "PARRAINEZ & GAGNEZ"),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: LargeTitreText(
                            textAlign: TextAlign.center, text: "PROSPER75"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AppButton(
                          onPressed: () {
                            Utils.log("copy");
                          },
                          force_height: 30,
                          text: "Copier mon code",
                          text_size: "small",
                          text_align: TextAlign.left,
                          text_weight: "bold",
                          padding: [0, 0, 0, 0],
                          foreground_color: AppColors.dark,
                          border_radius_size: "normal",
                          background_color: AppColors.primary_light),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  recommandation_repas() {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 35, right: 35),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MediumTitreText(text: "Recommandations de repas"),
              RouterButton(
                  destination: Activites(),
                  child_type: "svgimage",
                  svg_image_size: "wx16",
                  force_height: 30,
                  with_text: true,
                  flex_reverse: true,
                  text: "voir plus",
                  text_size: "small",
                  text_align: TextAlign.left,
                  text_weight: "bold",
                  padding: [0, 0, 0, 0],
                  conserve_svg_image_color: true,
                  svg_path: "assets/SVG/caret-yellow-dark.svg",
                  foreground_color: AppColors.dark,
                  border_radius_size: "normal",
                  background_color: Colors.transparent)
            ],
          ),
          SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PlatComponent(),
                SizedBox(
                  width: 20,
                ),
                PlatComponent(),
                SizedBox(
                  width: 20,
                ),
                PlatComponent(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
