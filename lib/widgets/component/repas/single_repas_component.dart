// widgets/component/repas/single_repas_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'dart:ffi';

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
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class SingleRepasComponent extends StatefulWidget {
  String noteRepas;
  String intitule;
  int id;
  String libelle;
  String fullUrlPhoto;
  int restaurant_id;
  int prix;
  bool? restaurant_fermer = false;

  SingleRepasComponent({
    super.key,
    this.intitule = "",
    this.id = 0,
    this.libelle = "",
    this.fullUrlPhoto = "",
    this.restaurant_id = 0,
    this.noteRepas = "",
    this.prix = 0,
    this.restaurant_fermer,
  });

  @override
  State<SingleRepasComponent> createState() => _SingleRepasComponentState();
}

class _SingleRepasComponentState extends State<SingleRepasComponent> {
  bool plat_loading = false;

  late Future<void> info_repas = Future<void>(() {});

  @override
  void dispose() {
    if (info_repas != null) info_repas.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Utils.log(widget.fullUrlPhoto);

    return Container(
      margin: EdgeInsets.all(10.sp),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(15.sp)),
            clipBehavior: Clip.none,
            child: Column(
              children: [
                Container(
                  width: Utils.REPAS_WIDGET_DEFAULT_WIDTH.sp,
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
                      image: NetworkImage(widget.fullUrlPhoto),
                    ),
                  ),
                  child: IntrinsicWidth(
                    child: AppButton(
                        onPressed: () {},
                        child_type: "icon",
                        icon_size: "small",
                        force_height: 30.sp,
                        icon: Icon(
                          Icons.star,
                          size: 15.sp,
                          color: AppColors.dark,
                        ),
                        with_text: true,
                        text: widget.noteRepas,
                        text_size: "small",
                        text_align: TextAlign.left,
                        text_weight: "bold",
                        padding: [0, 0, 0, 0],
                        foreground_color: AppColors.dark,
                        border_radius_size: "normal",
                        border_radius_only: BorderRadius.only(
                            bottomLeft: Radius.circular(15.sp),
                            bottomRight: Radius.circular(15.sp)),
                        border: [AppColors.primary, 2.0.sp, BorderStyle.solid],
                        background_color: Colors.white.withOpacity(0.8)),
                  ),
                ),
                Container(
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.symmetric(vertical: 30.sp),
                    width: Utils.REPAS_WIDGET_DEFAULT_WIDTH.sp,
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
                            topLeft: Radius.elliptical(95.sp, 30.sp),
                            topRight: Radius.elliptical(95.sp, 30.sp))),
                    transform: Matrix4.translationValues(0.0, -30.0.sp, 0.0),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MediumBoldText(
                          text: widget.libelle,
                          textAlign: TextAlign.center,
                        ),
                        XSmallLightText(
                          text: widget.intitule,
                          textAlign: TextAlign.center,
                        ),
                        widget.restaurant_fermer == false
                            ? Container()
                            : Column(
                                children: [
                                  SizedBox(
                                    height: 5.sp,
                                  ),
                                  SmallBoldText(
                                    text: "Fermé",
                                    color: Utils.colorToHex(Colors.red),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 5.sp,
                        ),
                        SmallBoldText(text: "${widget.prix} FCFA"),
                        
                      ],
                    ))
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 5,
              child: widget.restaurant_fermer == false
                  ? FractionallySizedBox(
                      widthFactor: 0.8,
                      child: AppButton(
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                plat_loading = true;
                              });
                            }
                            info_repas = get_request(
                              "$API_BASE_URL/client/info/repas/${widget.id}/${widget.restaurant_id}", // API URL
                              Utils.TOKEN,
                              {}, // Query parameters (if any)
                              (response) {
                                if (mounted) {
                                  setState(() {
                                    plat_loading = false;
                                  });
                                }
                                Utils.log(response);
                                Utils.panier["repas"]?.add({
                                  "intitule": widget.intitule,
                                  "id": widget.id,
                                  "libelle": widget.libelle,
                                  "fullUrlPhoto": widget.fullUrlPhoto,
                                  "restaurant_id": widget.restaurant_id,
                                  "noteRepas": widget.noteRepas,
                                  "prix": widget.prix,
                                  "restaurant": response["infoRestaurant"],
                                  "compositions": response["compositions"],
                                  "accompagnements":
                                      response["accompagnements"],
                                  "boissons": response["boissons"],
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommandeRepas(),
                                    ));
                                if (mounted) setState(() {});
                              },
                              (error) {
Utils.show_toast(context, error);                                if (mounted) {
                                  setState(() {
                                    plat_loading = false;
                                  });
                                }
                              },
                            );
                          },
                          child_type: "text",
                          force_height: 55.sp,
                          svg_image_size: "wx16",
                          text: "+ Ajouter",
                          text_size: "small",
                          loading: plat_loading,
                          padding: [0, 0, 0, 0],
                          text_align: TextAlign.center,
                          text_weight: "titre",
                          foreground_color: AppColors.dark,
                          border_radius_size: "large",
                          background_color: AppColors.primary))
                  : Container())
        ],
      ),
    );
  }
}
