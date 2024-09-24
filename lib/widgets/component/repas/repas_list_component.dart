// widgets/component/repas/repas_list_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:letransporteur_client/widgets/component/repas/single_repas_component.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class RepasListComponent extends StatefulWidget {
  var plats = [];
  bool? require_request_plats = false;
  int? restaurant_id;
  bool? plat_loading = false;
  RepasListComponent(
      {super.key,
      required this.plats,
      this.require_request_plats,
      this.plat_loading,
      this.restaurant_id});

  @override
  State<RepasListComponent> createState() => _RepasListComponentState();
}

class _RepasListComponentState extends State<RepasListComponent> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Utils.log((widget.require_request_plats, widget.restaurant_id));
  }

  loading_repas_component() {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/SVG/repas-icon-black.svg",
            height: 100.sp,
            width: 100.sp,
            fit: BoxFit.contain,
            color: AppColors.gray5,
          ),
          SizedBox(
            height: 10,
          ),
          SmallLightText(
            text: "Chargement...",
            color: Utils.colorToHex(AppColors.gray3),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Utils.log(widget.fullUrlPhoto);

    return widget.plats.isEmpty
        ? (widget.plat_loading == true
            ? loading_repas_component()
            : no_repas_component())
        : Wrap(
            direction: Axis.horizontal,
            spacing: 15,
            runSpacing: 25,
            children: [
              //SingleRepasComponent(),
              ...widget.plats.map(
                (e) {
                  return SingleRepasComponent(
                    restaurant_fermer: e["restaurant_fermer"]?? false,
                    intitule: e["intitule"]?? ".",
                    id: e["id"]?? 0,
                    libelle: e["libelle"],
                    fullUrlPhoto: e["fullUrlPhoto"]?? "",
                    prix: e["prix"],
                    restaurant_id: e["restaurant_id"],
                    noteRepas: e["noteRepas"]?? "0",
                  );
                },
              )
            ],
          );
  }

  no_repas_component() {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/SVG/repas-icon-black.svg",
            height: 100.sp,
            width: 100.sp,
            fit: BoxFit.contain,
            color: AppColors.gray5,
          ),
          SizedBox(
            height: 10,
          ),
          SmallLightText(
            text: "Pas de repas à afficher pour le moment.",
            color: Utils.colorToHex(AppColors.gray3),
          )
        ],
      ),
    );
  }
}
