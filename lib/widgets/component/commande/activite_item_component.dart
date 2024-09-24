// widgets/component/commande/activite_item_component.dart
// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites_details.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/commande/commande_status_evolution_component.dart';
import 'package:letransporteur_client/widgets/component/other/info_box_component.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_regular_text.dart';

class ActiviteItemComponent extends StatefulWidget {
  var commande;
  var mode = "full";
  ActiviteItemComponent(
      {super.key, required this.commande, required this.mode});

  @override
  State<ActiviteItemComponent> createState() => _ActiviteItemComponentState();
}

class _ActiviteItemComponentState extends State<ActiviteItemComponent> {
  bool canceling_commande = false;
  bool canceled_commande = false;

  late Future<void> activites_canceld_get = Future<void>(() {});

  @override
  void dispose() {
    if (activites_canceld_get != null) activites_canceld_get.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Utils.log(widget.commande);
  }

  @override
  Widget build(BuildContext context) {
    return canceled_commande
        ? Container()
        : Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: 20.sp,
                    bottom: (20 + 30).sp,
                    right: 20.sp,
                    left: 20.sp),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.sp),
                        topRight: Radius.circular(20.sp),
                        bottomLeft: Radius.circular(5.sp),
                        bottomRight: Radius.circular(5.sp)),
                    border: widget.mode == "compact"
                        ? Border.all(width: 0, color: Colors.transparent)
                        : Border.all(
                            color: AppColors.gray4,
                          )),
                child: Column(
                  children: [
                    commande_header(),
                    widget.mode == "compact"
                        ? Container()
                        : comande_box_infos(),
                    SizedBox(
                      height: 20.sp,
                    ),
                    widget.mode == "compact" ? Container() : commande_actions(),
                  ],
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0, -30.sp, 0),
                child: CommandeStatusEvolutionComponent(
                    commande: widget.commande, mode: widget.mode),
              )
            ],
          );
  }

  commande_header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          widget.commande["icon"],
          size: 50.sp,
          color: AppColors.primary,
        ),
        SizedBox(
          width: 10.sp,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmallTitreText(text: widget.commande["libelle"] ?? ""),
            SizedBox(
              height: 2.sp,
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18.sp,
                  color: AppColors.gray3,
                ),
                SizedBox(
                  width: 2.sp,
                ),
                MediumRegularText(
                  text: "${widget.commande["nbreKm"]}km",
                  color: Utils.colorToHex(AppColors.gray3),
                )
              ],
            )
          ],
        ),
        Spacer(),
        MediumBoldText(text: "${Utils.nf(widget.commande["montantNet"])} FCFA")
      ],
    );
  }

  comande_box_infos() {
    return Column(
      children: [
        InfoBoxComponent(
          content: widget.commande["lieuLivraison"],
          title: "Destination",
          icon: Icon(
            Icons.my_location,
            color: AppColors.gray3,
          ),
          button_widget: {},
        )
      ],
    );
  }

  commande_actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          onPressed: () {
            var parent_context = context;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(""),
                    content: SmallBoldText(
                        text:
                            "Êtes-vous sûr.e de vouloir annuler cette commande ?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Annuler'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text('Oui, annuler'),
                        onPressed: () {
                          if (mounted)
                            setState(() {
                              canceling_commande = true;
                            });
                          Navigator.pop(context);

                          activites_canceld_get = get_request(
                              "$API_BASE_URL/client/activites/canceld/${widget.commande["id"]}", // API URL
                              Utils.TOKEN,
                              {}, // Query parameters (if any)
                              (response) {
                            Utils.log(response);
                            if (mounted)
                              setState(() {
                                canceling_commande = false;
                                canceled_commande = true;
                              });
                            ScaffoldMessenger.of(parent_context)
                                .showSnackBar(SnackBar(
                                    backgroundColor: AppColors.primary_light,
                                    content: SmallBoldText(
                                      text: response["message"],
                                    )));
                          }, (error) {
Utils.show_toast(context, error);                            if (mounted)
                              setState(() {
                                canceling_commande = false;
                              });
                          });
                        },
                      ),
                    ],
                  );
                });
            Utils.log("delete");
          },
          loading: canceling_commande,
          child_type: "text",
          border: [Colors.red, 1.0, BorderStyle.solid],
          background_color: Colors.transparent,
          foreground_color: Colors.red,
          disabled: widget.commande["suivies"].length > 1,
          border_radius_size: "normal",
          text: "Annuler commande",
          text_weight: "bold",
          text_size: "small",
        )
        /* : RouterButton(
                destination: ActivitesDetails(
                  commande: widget.commande,
                ),
                child_type: "icon",
                with_text: true,
                icon: Icon(
                  Icons.star_half,
                  color: AppColors.dark,
                ),
                icon_size: "normal",
                background_color: AppColors.primary,
                foreground_color: AppColors.dark,
                border_radius_size: "normal",
                text: "Noter le service",
                text_weight: "bold",
                text_size: "small",
              ) */
        ,
        RouterButton(
          destination: ActivitesDetails(commande: widget.commande),
          child_type: "text",
          background_color: AppColors.gray2,
          foreground_color: Colors.white,
          border_radius_size: "normal",
          text: "Voir détails →",
          text_weight: "bold",
          text_size: "small",
        )
      ],
    );
  }

  get_box_title_for_categorie(type_commande_id) {
    if (get_categorie_by_id(type_commande_id) != null) {
      return get_categorie_by_id(type_commande_id)["libelle"];
    }
    return "";
  }

  get_categorie_by_id(type_commande_id) {
    Utils.big_data?["typeCommande"].forEach((type) {
      if (type["id"] == type_commande_id) {
        return type;
      }
    });
    return null;
  }

  show_spinner_dialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(""),
            content: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.gray2),
            ),
          );
        });
  }
}
