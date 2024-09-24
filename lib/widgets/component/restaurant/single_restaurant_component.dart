// widgets/component/restaurant/single_restaurant_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, prefer_interpolation_to_compose_strings// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/commande_repas.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/page/repas/repas_picker_page.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class SingleRestaurantComponent extends StatefulWidget {
  var restaurant = {};
  SingleRestaurantComponent({super.key, required this.restaurant});

  @override
  State<SingleRestaurantComponent> createState() =>
      _SingleRestaurantComponentState();
}

class _SingleRestaurantComponentState extends State<SingleRestaurantComponent> {
  var repas = [];

  late Future<void> repas_restaurant_get = Future<void>(() {});

  @override
  void dispose() {
    if (repas_restaurant_get != null) repas_restaurant_get.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    repas_restaurant_get = get_request(
      "${API_BASE_URL}/client/repas/restaurant/${widget.restaurant?["id"]}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        if (mounted) {
          setState(() {
            repas = response?["repasRestaurant"].map((repa) {
              return {
                "intitule": repa["restaurant"],
                "categorie_id": repa["categorie_id"],
                "id": repa["repas_id"],
                "libelle": repa["libelle"],
                "fullUrlPhoto": repa["fullUrlPhoto"],
                "prix": repa["prix"],
                "restaurant_fermer": widget.restaurant["restaurant_fermer"],
                "restaurant_id": repa["restaurant_id"],
                "noteRepas": repa["moyenneNote"],
              };
            }).toList();
          });
        }
      },
      (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    Utils.log((80.sp, 80.sp));
    return GestureDetector(
      onTap: () {
        Utils.log(widget.restaurant);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RepasPickerPage(
                    repas_list: repas,
                    repas_categories: widget.restaurant["categories"],
                    widget_title: widget.restaurant["intitule"],
                    restaurant_id: widget.restaurant["id"],
                    show_filters: false,
                  )),
        );
        // If a result is returned, update the state.
      },
      child: Container(
        width: 330.sp,
        height: 160.sp,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.sp),
            border: Border.all(
                color: AppColors.primary, style: BorderStyle.solid, width: 1)),
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 25.sp,
            ),
            Container(
              width: 80.sp,
              height: 80.sp,
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
                image: NetworkImage(widget.restaurant["fullUrlPhoto"]),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10.sp,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.sp),
                  MediumTitreText(text: widget.restaurant["intitule"]),
                  SizedBox(height: 5.sp),
                  SmallRegularText(
                      text:
                          "${widget.restaurant["plageJourDebut"]} au ${widget.restaurant["plageJourFin"]}. ${widget.restaurant["plageHeureDebut"]} à ${widget.restaurant["plageHeureFin"]}"),
                  widget.restaurant["restaurant_fermer"] == true
                      ? SmallBoldText(
                          color: Utils.colorToHex(Colors.red), text: "(Fermé)")
                      : SmallBoldText(
                          color: Utils.colorToHex(Colors.green.shade700), text: "(Ouvert)"),
                  XSmallLightText(
                      text: 'Mets ' +
                          (widget.restaurant["categories"]?.map((cat) {
                            return cat?["categorieRepas"];
                          })).join(" - ")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
