// widgets/component/other/repas_categorie_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

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
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class RepasCategorieComponent extends StatefulWidget {
  var categorie = {};
  RepasCategorieComponent({super.key, required this.categorie});

  @override
  State<RepasCategorieComponent> createState() =>
      _RepasCategorieComponentState();
}

class _RepasCategorieComponentState extends State<RepasCategorieComponent> {
  var repas = [];

  late Future<void> repas_categorie_get = Future<void>(() {});

  @override
  void dispose() {
    if (repas_categorie_get != null) repas_categorie_get.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    repas_categorie_get = get_request(
      "${API_BASE_URL}/client/repas/categorie/${widget.categorie?["id"]}/${Utils.get_current_location().toLowerCase()}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        //Utils.log(response);
        if(mounted) {
          setState(() {
          repas = response?["repasByCategorie"].map((repa) {
            return {
              "intitule": repa["restaurant_name"],
              "id": repa["id"],
              "libelle": repa["libelle"],
              "fullUrlPhoto": repa["fullUrlPhoto"],
              "prix": repa["prix"],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RepasPickerPage(
                    repas_list: repas,
                    widget_title: widget.categorie?["libelle"],
                    show_filters: false,
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
                  width: 120.sp,
                  height: 120.sp,
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
                        topLeft: Radius.circular(15.sp),
                        topRight: Radius.circular(15.sp)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.categorie?["fullUrlPhoto"]),
                    ),
                  ),
                ),
                Container(
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: 120.sp,
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
                            bottomLeft: Radius.circular(20.sp),
                            bottomRight: Radius.circular(20.sp),
                            topLeft: Radius.elliptical(75.sp, 30.sp),
                            topRight: Radius.elliptical(75.sp, 30.sp))),
                    transform: Matrix4.translationValues(0.0, -40.0.sp, 0.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        MediumBoldText(text: widget.categorie?["libelle"]),
                        SizedBox(
                          height: 5.sp,
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
                              size: 15.sp,
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
