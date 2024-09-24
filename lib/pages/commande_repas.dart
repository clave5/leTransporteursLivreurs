// pages/commande_repas.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/activites/activites_details.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/page/map/map_picker_page.dart';
import 'package:letransporteur_client/widgets/page/repas/repas_picker_page.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_regular_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CommandeRepas extends StatefulWidget {
  const CommandeRepas({super.key});

  @override
  State<CommandeRepas> createState() => CommandeRepasState();
}

class CommandeRepasState extends State<CommandeRepas> {
  int step_index = 0;
  dynamic lieux_selected = {};
  bool boissons_expanded = false;
  bool accompagnement_expanded = false;
  FormGroup repas_livraison_form = FormGroup({
    /* 'lieu_recup': FormControl<String>(validators: [
      Validators.required,
    ]),
    'contact_recup': FormControl<String>(validators: [
      Validators.number(allowNegatives: false),
      Validators.required,
    ]), */
    'lieu_dest': FormControl<String>(validators: [
      Validators.required,
    ]),
    'message': FormControl<String>(validators: [
      Validators.required,
    ]),
    'contact_dest': FormControl<String>(validators: [
      Validators.number(allowNegatives: false),
      Validators.required,
    ]),
  });
  FormGroup store_commande_form = FormGroup({
    'mode_paiement': FormControl<String>(validators: [], value: "mobile money"),
  });
  var recap_repas = [];
  var recap_accomps = [];
  var recap_boissons = [];

  var accomps_dispos = [];
  var boissons_dispos = [];
  int total = 0;
  bool loading_directions = false;

  var repas_livraison_distance = 0.0;
  var repas_livraison_duree = 0.0;

  bool commande_loading = false;

  var commande_info = {};

  int total_repas = 0;
  int total_accomps = 0;
  int total_boissons = 0;

  late Future<void> tarification_commande_post = Future<void>(() {});

  late Future<void> store_commande_post = Future<void>(() {});

  @override
  void dispose() {
    if (tarification_commande_post != null) tarification_commande_post.ignore();
    if (store_commande_post != null) store_commande_post.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Utils.log(Utils.panier);
    if (Utils.panier["repas"] != null && Utils.panier["repas"]!.isEmpty) {
      Navigator.of(context).pop();
    } else {
      refresh_recaps();
    }
  }

  refresh_recaps() {
    recap_repas = [];
    Utils.panier["repas"]?.forEach((repas) {
      if (recap_repas.map((r) => r["repas_id"]).contains(repas["id"])) {
        for (var rec in recap_repas) {
          if (rec["repas_id"] == repas["id"]) {
            rec["count"] = rec["count"] + 1;
          }
        }
      } else {
        recap_repas.add({
          "count": 1,
          "restaurant_id": repas["restaurant_id"],
          "restaurant_lat": repas["restaurant"]["latitude"],
          "restaurant_long": repas["restaurant"]["longitude"],
          "repas_id": repas["id"],
          "price": repas["prix"],
          "name": repas["libelle"],
          "photo": repas["fullUrlPhoto"],
          "compositions": repas["compositions"].map((comp) => comp["libelle"]),
          "compositions_widgets": repas["compositions"].map((comp) {
            return Row(children: [
              Icon(
                Icons.circle,
                size: 8.0, // Bullet size
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: XSmallRegularText(
                  text: comp["libelle"],
                ),
              ),
            ]);
          }),
        });
      }
    });

    lieux_selected["lieu_recup"] = {
      "latitude": Utils.panier["repas"]?[0]?["restaurant"]["longitude"],

      ///interchanger car c'est erronné
      "longitude": Utils.panier["repas"]?[0]?["restaurant"]["latitude"]

      ///interchanger car c'est erronné
    };

    recap_accomps = [];
    Utils.panier["accomps"]?.forEach((accomp) {
      if (recap_accomps
          .map((r) => r["accomp_id"])
          .contains(accomp["accomp_id"])) {
        for (var rec in recap_accomps) {
          if (rec["accomp_id"] == accomp["accomp_id"]) {
            rec["count"] = rec["count"] + 1;
          }
        }
      } else {
        recap_accomps.add({
          "count": 1,
          "accomp_id": accomp["accomp_id"],
          "price": accomp["price"],
          "name": accomp["name"],
        });
      }
    });

    recap_boissons = [];
    Utils.panier["boissons"]?.forEach((boisson) {
      if (recap_boissons
          .map((r) => r["boisson_id"])
          .contains(boisson["boisson_id"])) {
        for (var rec in recap_boissons) {
          if (rec["boisson_id"] == boisson["boisson_id"]) {
            rec["count"] = rec["count"] + 1;
          }
        }
      } else {
        recap_boissons.add({
          "count": 1,
          "boisson_id": boisson["boisson_id"],
          "price": boisson["price"],
          "name": boisson["name"],
        });
      }
    });

    Utils.log(recap_repas);
    Utils.log(recap_accomps);
    Utils.log(recap_boissons);

    total = 0;
    total_repas = 0;
    total_boissons = 0;
    total_accomps = 0;
    recap_repas.forEach((element) {
      total += (element["price"] * element["count"] as int);
      total_repas += (element["price"] * element["count"] as int);
    });
    recap_accomps.forEach((element) {
      total += (element["price"] * element["count"] as int);
      total_boissons += (element["price"] * element["count"] as int);
    });
    recap_boissons.forEach((element) {
      total += (element["price"] * element["count"] as int);
      total_accomps += (element["price"] * element["count"] as int);
    });

    accomps_dispos = [];
    accomps_dispos =
        Utils.panier["repas"]?[0]?["accompagnements"].map((accomp) {
      return {
        "id": accomp["id"],
        "name": accomp["libelle"],
        "price": accomp["accompagnement_restaurant"]["prix"],
      };
    }).toList();

    boissons_dispos = [];
    boissons_dispos = Utils.panier["repas"]?[0]?["boissons"].map((boisson) {
      return {
        "id": boisson["id"],
        "name": boisson["libelle"],
        "price": boisson["boisson_restaurant"]["prix"],
      };
    }).toList();

    if (mounted) setState(() {});
  }

  Widget get_step_1() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        decoration: BoxDecoration(
            color: AppColors.gray7,
            border: Border.all(
                color: AppColors.gray5, style: BorderStyle.solid, width: 1)),
        child: Column(
          children: [
            ...recap_repas.map(
              (recap) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid,
                              width: 1)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 25.sp,
                          ),
                          MediumBoldText(text: "${recap["count"]}x"),
                          SizedBox(
                            width: 25.sp,
                          ),
                          Flexible(
                              flex: 4,
                              child: SmallRegularText(text: recap["name"])),
                          Spacer(
                            flex: 1,
                          ),
                          SmallBoldText(
                              text:
                                  "= ${Utils.nf(recap["count"] * recap["price"])} FCFA"),
                          Spacer(
                            flex: 1,
                          ),
                          AppButton(
                              onPressed: () {
                                var single_panier_element_to_re_add = Utils
                                    .panier["repas"]
                                    ?.firstWhere((element) =>
                                        element["id"] == recap["repas_id"]);
                                Utils.log(single_panier_element_to_re_add);
                                Utils.panier["repas"]
                                    ?.remove(single_panier_element_to_re_add);
                                refresh_recaps();
                              },
                              child_type: "icon",
                              icon_size: "22x22",
                              foreground_color: AppColors.dark,
                              icon: Icon(
                                Icons.remove,
                                size: 15,
                                color: AppColors.dark,
                              ),
                              background_color: AppColors.primary),
                          SizedBox(
                            width: 10.sp,
                          ),
                          AppButton(
                              onPressed: () {
                                var single_panier_element_to_re_add = Utils
                                    .panier["repas"]
                                    ?.firstWhere((element) =>
                                        element["id"] == recap["repas_id"]);
                                Utils.log(single_panier_element_to_re_add);
                                Utils.panier["repas"]
                                    ?.add(single_panier_element_to_re_add);
                                refresh_recaps();
                              },
                              child_type: "icon",
                              icon_size: "22x22",
                              foreground_color: AppColors.dark,
                              icon: Icon(
                                Icons.add,
                                size: 15,
                                color: AppColors.dark,
                              ),
                              background_color: AppColors.primary),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 25.sp,
                          ),
                          Container(
                            width: 150,
                            height: 110,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            clipBehavior: Clip.antiAlias,
                            child: Image(
                              image: NetworkImage(recap["photo"]),
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
                                SmallBoldText(text: 'Contenu du repas'),
                                SizedBox(height: 5.sp),
                                ...recap["compositions_widgets"],
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            recap_accomps.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    color: AppColors.gray5,
                    height: 1,
                  ),
            ...recap_accomps.map(
              (recap) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid,
                              width: 1)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 25.sp,
                          ),
                          MediumBoldText(text: "${recap["count"]}x"),
                          SizedBox(
                            width: 25.sp,
                          ),
                          Flexible(
                              flex: 4,
                              child: SmallRegularText(text: recap["name"])),
                          Spacer(
                            flex: 1,
                          ),
                          SmallBoldText(
                              text:
                                  "= ${Utils.nf(recap["count"] * recap["price"])} FCFA"),
                          Spacer(
                            flex: 1,
                          ),
                          AppButton(
                              onPressed: () {
                                var single_panier_element_to_re_add = Utils
                                    .panier["accomps"]
                                    ?.firstWhere((element) =>
                                        element["accomp_id"] ==
                                        recap["accomp_id"]);
                                Utils.log(single_panier_element_to_re_add);
                                Utils.panier["accomps"]
                                    ?.remove(single_panier_element_to_re_add);
                                refresh_recaps();
                              },
                              child_type: "icon",
                              icon_size: "22x22",
                              foreground_color: AppColors.dark,
                              icon: Icon(
                                Icons.remove,
                                size: 15,
                                color: AppColors.dark,
                              ),
                              background_color: AppColors.primary),
                          SizedBox(
                            width: 10.sp,
                          ),
                          AppButton(
                              onPressed: () {
                                var single_panier_element_to_re_add = Utils
                                    .panier["accomps"]
                                    ?.firstWhere((element) =>
                                        element["accomp_id"] ==
                                        recap["accomp_id"]);
                                Utils.log(single_panier_element_to_re_add);
                                Utils.panier["accomps"]
                                    ?.add(single_panier_element_to_re_add);
                                refresh_recaps();
                              },
                              child_type: "icon",
                              icon_size: "22x22",
                              foreground_color: AppColors.dark,
                              icon: Icon(
                                Icons.add,
                                size: 15,
                                color: AppColors.dark,
                              ),
                              background_color: AppColors.primary),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              },
            ),
            recap_boissons.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    color: AppColors.gray5,
                    height: 1,
                  ),
            ...recap_boissons.map(
              (recap) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid,
                              width: 1)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 25.sp,
                          ),
                          MediumBoldText(text: "${recap["count"]}x"),
                          SizedBox(
                            width: 25.sp,
                          ),
                          Flexible(
                              flex: 4,
                              child: SmallRegularText(text: recap["name"])),
                          Spacer(
                            flex: 1,
                          ),
                          SmallBoldText(
                              text:
                                  "= ${Utils.nf(recap["count"] * recap["price"])} FCFA"),
                          Spacer(
                            flex: 1,
                          ),
                          AppButton(
                              onPressed: () {
                                var single_panier_element_to_re_add = Utils
                                    .panier["boissons"]
                                    ?.firstWhere((element) =>
                                        element["boisson_id"] ==
                                        recap["boisson_id"]);
                                Utils.log(single_panier_element_to_re_add);
                                Utils.panier["boissons"]
                                    ?.remove(single_panier_element_to_re_add);
                                refresh_recaps();
                              },
                              child_type: "icon",
                              icon_size: "22x22",
                              foreground_color: AppColors.dark,
                              icon: Icon(
                                Icons.remove,
                                size: 15,
                                color: AppColors.dark,
                              ),
                              background_color: AppColors.primary),
                          SizedBox(
                            width: 10.sp,
                          ),
                          AppButton(
                              onPressed: () {
                                var single_panier_element_to_re_add = Utils
                                    .panier["boissons"]
                                    ?.firstWhere((element) =>
                                        element["boisson_id"] ==
                                        recap["boisson_id"]);
                                Utils.log(single_panier_element_to_re_add);
                                Utils.panier["boissons"]
                                    ?.add(single_panier_element_to_re_add);
                                refresh_recaps();
                              },
                              child_type: "icon",
                              icon_size: "22x22",
                              foreground_color: AppColors.dark,
                              icon: Icon(
                                Icons.add,
                                size: 15,
                                color: AppColors.dark,
                              ),
                              background_color: AppColors.primary),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 20.sp),
        child: RouterButton(
            destination: RepasPickerPage(
                show_filters: true,
                require_request_plats: true,
                restaurant_id: Utils.panier["repas"]?[0]?["restaurant_id"],
                widget_title: Utils.panier["repas"]?[0]?["intitule"],
                repas_list: []),
            child_type: "text",
            force_height: 55.sp,
            svg_image_size: "wx16",
            text: "+ Ajouter un repas",
            text_size: "small",
            padding: [10.sp, 20.sp, 10.sp, 20.sp],
            text_align: TextAlign.center,
            text_weight: "titre",
            foreground_color: AppColors.dark,
            border_radius_size: "normal",
            border: [AppColors.primary, 2.0, BorderStyle.solid],
            background_color: AppColors.transparent),
      ),
      Container(
        margin: EdgeInsets.symmetric(vertical: 10.sp),
        color: AppColors.gray5,
        height: 1,
      ),
      Container(
          child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          if (mounted) {
            setState(() {
              if (index == 0) {
                boissons_expanded = isExpanded;
              } else if (index == 1) {
                accompagnement_expanded = isExpanded;
              }
            });
          }
        },
        children: [
          ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: SmallRegularText(text: "Boissons optionnelles"),
                );
              },
              body: Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    ...boissons_dispos.map((boisson) {
                      return Column(
                        children: [
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.primary,
                                      style: BorderStyle.solid,
                                      width: 1)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(
                                    width: 25.sp,
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: SmallRegularText(
                                        text:
                                            "${boisson["name"]} : ${Utils.nf(boisson["price"])} FCFA"),
                                  ),
                                  Spacer(
                                    flex: 1,
                                  ),
                                  AppButton(
                                      onPressed: () {
                                        Utils.log("plus");
                                        Utils.panier["boissons"]?.add({
                                          "boisson_id": boisson["id"],
                                          "price": boisson["price"],
                                          "name": boisson["name"],
                                        });
                                        refresh_recaps();
                                      },
                                      child_type: "text",
                                      text: "Ajouter",
                                      text_size: "small",
                                      text_weight: "bold",
                                      foreground_color: AppColors.dark,
                                      background_color: AppColors.primary),
                                ],
                              )),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    })
                  ],
                ),
              ),
              isExpanded: boissons_expanded),
          ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title:
                      SmallRegularText(text: "Accompagnements supplémentaires"),
                );
              },
              body: Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    ...accomps_dispos.map((accomp) {
                      return Column(
                        children: [
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.primary,
                                      style: BorderStyle.solid,
                                      width: 1)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(
                                    width: 25.sp,
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: SmallRegularText(
                                        text:
                                            "${accomp["name"]} : ${Utils.nf(accomp["price"])} FCFA"),
                                  ),
                                  Spacer(
                                    flex: 1,
                                  ),
                                  AppButton(
                                      onPressed: () {
                                        Utils.log("plus");
                                        Utils.panier["accomps"]?.add({
                                          "accomp_id": accomp["id"],
                                          "price": accomp["price"],
                                          "name": accomp["name"],
                                        });
                                        refresh_recaps();
                                      },
                                      child_type: "text",
                                      text: "Ajouter",
                                      text_size: "small",
                                      text_weight: "bold",
                                      foreground_color: AppColors.dark,
                                      background_color: AppColors.primary),
                                ],
                              )),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    })
                  ],
                ),
              ),
              isExpanded: accompagnement_expanded)
        ],
      )),
      SizedBox(
        height: 50.sp,
      )
    ]);
  }

  Widget get_step_2() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ReactiveForm(
        formGroup: repas_livraison_form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10.sp),
            IntlPhoneField(
              decoration: Utils.get_default_input_decoration_normal(
                  repas_livraison_form.control('contact_dest'),
                  true,
                  'Contact de livraison',
                  null,
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
              initialCountryCode: 'BJ',
              onChanged: (phone) {
                Utils.log(phone);
                if (mounted) {
                  setState(() {
                    repas_livraison_form
                        .patchValue({"contact_dest": phone.completeNumber});
                    try {
                      if (phone.isValidNumber()) {
                        repas_livraison_form
                            .control("contact_dest")
                            .setErrors({});
                      }
                    } on Exception catch (e) {}
                  });
                }
              },
            ),
            SizedBox(height: 15.sp),
            ReactiveTextField(
              formControlName: 'lieu_dest',
              onTap: (control) {
                launch_map_for_result("lieu de destination", "lieu_dest", null);
              },
              decoration: Utils.get_default_input_decoration_normal(
                  repas_livraison_form.control('lieu_dest'),
                  false,
                  'Lieu de livraison',
                  {"icon": Icons.my_location, "size": 24.sp},
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 15.sp),
            ReactiveTextField(
              formControlName: 'message',
              maxLines: 5,
              decoration: Utils.get_default_input_decoration_multi_lines(
                  repas_livraison_form.control('message'),
                  false,
                  'Message au livreur',
                  null,
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 5.sp),
          ],
        ),
      ),
      SizedBox(
        height: 50.sp,
      )
    ]);
  }

  Widget get_step_3() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15.sp),
        decoration: BoxDecoration(
            color: AppColors.gray7,
            border: Border.all(
                color: AppColors.gray5, style: BorderStyle.solid, width: 1)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: 20.sp, right: 20.sp, top: 5.sp, bottom: 15.sp),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: AppColors.primary,
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  MediumBoldText(text: "Total repas :"),
                  Spacer(),
                  MediumBoldText(text: "${Utils.nf(total_repas)} FCFA")
                ],
              ),
            ),
            ...recap_repas.map(
              (recap) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.sp),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 10.sp),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid,
                              width: 1)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 25.sp,
                          ),
                          MediumRegularText(text: "${recap["count"]}x"),
                          SizedBox(
                            width: 25.sp,
                          ),
                          Flexible(
                              flex: 2,
                              child: SmallRegularText(text: recap["name"])),
                          Spacer(),
                          SmallRegularText(
                              text:
                                  "= ${Utils.nf(recap["count"] * recap["price"])} FCFA"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5.sp,
                    ),
                  ],
                );
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.sp),
              color: AppColors.gray5,
              height: 1,
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 20.sp, right: 20.sp, top: 5.sp, bottom: 15.sp),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: AppColors.primary,
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  MediumBoldText(text: "Total accompagnements :"),
                  Spacer(),
                  MediumBoldText(text: "${Utils.nf(total_accomps)} FCFA")
                ],
              ),
            ),
            ...recap_accomps.map(
              (recap) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.sp),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 10.sp),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid,
                              width: 1)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 25.sp,
                          ),
                          MediumRegularText(text: "${recap["count"]}x"),
                          SizedBox(
                            width: 25.sp,
                          ),
                          Flexible(
                              flex: 4,
                              child: SmallRegularText(text: recap["name"])),
                          Spacer(
                            flex: 1,
                          ),
                          SmallRegularText(
                              text:
                                  "= ${Utils.nf(recap["count"] * recap["price"])} FCFA"),
                          Spacer(
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5.sp,
                    ),
                  ],
                );
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.sp),
              color: AppColors.gray5,
              height: 1,
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 20.sp, right: 20.sp, top: 5.sp, bottom: 15.sp),
              child: Row(
                children: [
                  Icon(
                    Icons.local_drink_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  MediumBoldText(text: "Total boissons :"),
                  Spacer(),
                  MediumBoldText(text: "${Utils.nf(total_boissons)} FCFA")
                ],
              ),
            ),
            ...recap_boissons.map(
              (recap) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.sp),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 10.sp),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid,
                              width: 1)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 25.sp,
                          ),
                          MediumRegularText(text: "${recap["count"]}x"),
                          SizedBox(
                            width: 25.sp,
                          ),
                          Flexible(
                              flex: 4,
                              child: SmallRegularText(text: recap["name"])),
                          Spacer(
                            flex: 1,
                          ),
                          SmallRegularText(
                              text:
                                  "= ${Utils.nf(recap["count"] * recap["price"])} FCFA"),
                          Spacer(
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20.sp,
      ),
      commande_info["cout_livraison"] != null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              decoration: BoxDecoration(
                  color: AppColors.gray7,
                  border: Border.all(
                      color: AppColors.gray5,
                      style: BorderStyle.solid,
                      width: 1)),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.delivery_dining_sharp,
                          color: AppColors.primary,
                        ),
                        SizedBox(
                          width: 10.sp,
                        ),
                        Row(
                          children: [
                            MediumBoldText(text: "Livraison :"),
                            SizedBox(
                              width: 25.sp,
                            ),
                            XSmallRegularText(
                                text:
                                    "${commande_info["nbreKm"]}km x ${Utils.nf(commande_info["coutKm"])} FCFA"),
                          ],
                        ),
                        Spacer(),
                        MediumBoldText(
                            text:
                                "${Utils.nf(commande_info["cout_livraison"])} FCFA")
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(),
      SizedBox(
        height: 25.sp,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15.sp),
        decoration: BoxDecoration(
            color: AppColors.gray7,
            border: Border.all(
                color: AppColors.gray5, style: BorderStyle.solid, width: 1)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.percent,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediumBoldText(
                        text: "Réductions :",
                        color: Utils.colorToHex(
                          Colors.red,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      XSmallRegularText(
                          text:
                              "Réduction promotionelle : -${Utils.nf(commande_info["tauxPromotion"]) ?? "0"} FCFA"),
                      SizedBox(
                        height: 3.sp,
                      ),
                      XSmallRegularText(
                          text:
                              "Réduction parrainage -${Utils.nf(commande_info["reductionParrainage"]) ?? "0"} FCFA"),
                      SizedBox(
                        height: 3.sp,
                      ),
                      XSmallRegularText(
                          text:
                              "Réduction de fidélisation -${Utils.nf(commande_info["reductionFidelisation"]) ?? "0"} FCFA"),
                    ],
                  ),
                  Spacer(),
                  MediumBoldText(
                      color: Utils.colorToHex(
                        Colors.red,
                      ),
                      text:
                          "-${Utils.nf(commande_info["totalReduction"]) ?? "0"} FCFA")
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 25.sp,
      ),
      commande_info["cout_livraison"] != null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LargeBoldText(
                    text:
                        "TOTAL : ${Utils.nf(total + commande_info["cout_livraison"])} FCFA",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          : Container(),
      SizedBox(
        height: 30.sp,
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.sp),
        child: ReactiveForm(
            formGroup: store_commande_form,
            child: Column(children: [
              ReactiveDropdownField<String>(
                formControlName: 'mode_paiement',
                isExpanded: true,
                decoration: Utils.get_default_input_decoration_normal(
                    store_commande_form.control('mode_paiement'),
                    true,
                    'Selectionnez',
                    null,
                    null,
                    null),
                hint: Text('Mode de paiement'),
                items: [
                  DropdownMenuItem(
                      value: "espece",
                      child: SmallBoldText(
                        text: "Payer en espèce",
                      )),
                  DropdownMenuItem(
                    value: "mobile money",
                    child: SmallBoldText(
                      text: "Payer par MoMo",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.sp,
              ),
              AppButton(
                onPressed: () {
                  store_commande(store_commande_form.rawValue["mode_paiement"]);
                },
                child_type: "text",
                force_height: 55.sp,
                loading: commande_loading,
                svg_image_size: "wx16",
                text: "Commander maintenant",
                text_size: "small",
                padding: [10.sp, 20.sp, 10.sp, 20.sp],
                text_align: TextAlign.center,
                text_weight: "titre",
                foreground_color: AppColors.dark,
                border_radius_size: "normal",
                background_color: AppColors.primary,
              ),
            ])),
      ),
      SizedBox(
        height: 15.sp,
      ),
    ]);
  }

  createTransaction(commande_obj) async {
    if (mounted) {
      setState(() {
        commande_loading = true;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
            heightFactor: 0.9,
            child: FedaWebview(
              id_commande: commande_obj?["data"]?["commande_id"],
              montant_total: commande_obj?["data"]?["montantNet"],
              montant_livraison: commande_info["cout_livraison"],
              montant_repas: total_repas,
            ));
      },
    ).then((value) {
      if (mounted) {
        setState(() {
          commande_loading = false;
        });
      }

      if (value["reason"] == "CHECKOUT COMPLETE") {
        after_store_commande(commande_obj);
      }
      Utils.log(value);
    });
  }

  after_store_commande(commande_obj) {
    commande_obj?["data"]["id"] = commande_obj?["data"]["commande_id"];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Activites()),
    );
  }

  void store_commande(mode_paiement) {
    Utils.log("commander");
    Utils.log(Utils.big_data["infoClient"]);
    Utils.client = Utils.big_data["infoClient"];

    if (mounted) {
      setState(() {
        commande_loading = true;
      });
    }

    var store_commande_obj = {
      "articles": [
        ...recap_repas.map((repa) {
          return {
            "repas_id": repa["repas_id"],
            "prix": repa["price"],
            "nbrePlat": repa["count"]
          };
        })
      ],
      "boissons": [
        ...recap_boissons.map((boisson) {
          return {
            "boisson_id": boisson["boisson_id"],
            "prix": boisson["price"],
            "nbre": boisson["count"]
          };
        })
      ],
      "accompagnements": [
        ...recap_accomps.map((acc) {
          return {
            "accompagnement_id": acc["accomp_id"],
            "prix": acc["price"],
            "nbre": acc["count"]
          };
        })
      ],
      "modePaiement": mode_paiement,
      "tempsEstimatif": repas_livraison_duree / 60,
      "nbreKm": commande_info["nbreKm"],
      "type_commande_id": Utils.TYPE_COMMANNDES["repas"],
      "tauxPromotion": commande_info["tauxPromotion"],
      "client_id": Utils.client["client_id"],
      "coutKm": commande_info["coutKm"],
      "restaurant_id": recap_repas[0]?["restaurant_id"],
      "lieuLivraison": repas_livraison_form.rawValue["lieu_dest"],
      "longitudeLivraison": lieux_selected["lieu_dest"]["longitude"],
      "latitudeLivraison": lieux_selected["lieu_dest"]["latitude"],
      "lieuRecuperation": Utils.panier["repas"]?[0]?["restaurant"]
          ["lieuRecuperation"],
      "longitudeRecuperation": Utils.panier["repas"]?[0]?["restaurant"]
          ["longitude"],
      "latitudeRecuperation": Utils.panier["repas"]?[0]?["restaurant"]
          ["latitude"],
      "contactLivraison": repas_livraison_form.rawValue["contact_dest"],
      "contactRecuperation": Utils.panier["repas"]?[0]?["restaurant"]
              ["contactRecuperation"] ??
          "+22900000000",
      "messageAuLivreur": repas_livraison_form.rawValue["message"],
      "moyen_deplacement_id": commande_info["moyen_deplacement_id"],
      "prixKm": commande_info["prixKm"],
      "reductionParrainage": commande_info["reductionParrainage"],
      "reductionFidelisation": commande_info["reductionFidelisation"]
    };

    Utils.log(store_commande_obj);
    store_commande_post = post_request(
        "$API_BASE_URL/client/store/commande", // API URL
        Utils.TOKEN,
        store_commande_obj, // Query parameters (if any)
        (response) {
      // Success callback
      Utils.log(response);
      if (mode_paiement == "mobile money") {
        createTransaction(response);
      } else {
        after_store_commande(response);
      }
      if (mounted) {
        setState(() {
          commande_loading = false;
        });
      }
    }, (error) {
Utils.show_toast(context, error);      // Error callback
      if (mounted) {
        setState(() {
          commande_loading = false;
        });
      }
    }, null, context);
  }

  Future<void> launch_map_for_result(
      String lieu_label, String contol_to_update, String? longlat) async {
    final map_result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapPickerScreen(
                intent_data: {
                  "lieu_label": lieu_label,
                  "long": longlat?.split(",")?[0],
                  "lat": longlat?.split(",")?[1],
                  "zoom": 15.0
                },
              )),
    );
    // If a result is returned, update the state.
    if (map_result != null) {
      Utils.log(map_result);
      Utils.log(lieux_selected);
      repas_livraison_form
          .control(contol_to_update)
          ?.patchValue(map_result["title"]);
      lieux_selected[contol_to_update] = map_result;
      if (lieux_selected.length == 2) {
        get_directions(
          "${lieux_selected["lieu_recup"]["longitude"]},${lieux_selected["lieu_recup"]["latitude"]}",
          "${lieux_selected["lieu_dest"]["longitude"]},${lieux_selected["lieu_dest"]["latitude"]}",
        );
      } else {
        Utils.log_error(lieux_selected);
      }
      if (mounted) setState(() {});
    }
  }

  // Method to consume the OpenRouteService API
  get_directions(String start, String end) {
    // Requesting for openrouteservice api
    if (mounted) {
      setState(() {
        loading_directions = true;
      });
    }

    try {
      Utils.log(get_route_url(start, end).toString());
      Clipboard.setData(ClipboardData(
          text: json.encode({
        "geolocalisation_url": get_route_url(start, end).toString(),
      }))).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.primary_light,
            content: SmallBoldText(
              text: "Payload localisation copié !",
            )));
      });

      http.get(get_route_url(start, end)).then((response) {
        Clipboard.setData(ClipboardData(
            text: json.encode({
          "geolocalisation_url": get_route_url(start, end).toString(),
          "url": "$API_BASE_URL/client/tarification/commande", //
          "token": Utils.TOKEN,
          "payload": {
            "nbreKm": (repas_livraison_distance / 1000).floor(),
            "type_commande_id": Utils.TYPE_COMMANNDES["repas"],
            "client_id": Utils.client["client_id"],
          }, // Q
        }))).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppColors.primary_light,
              content: SmallBoldText(
                text: "Payload tarification copié !",
              )));
        });
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (mounted) {
            setState(() {
              commande_loading = false;
            });
          }
          repas_livraison_distance =
              data["features"]?[0]?["properties"]?["segments"]?[0]?["distance"];
          repas_livraison_duree =
              data["features"]?[0]?["properties"]?["segments"]?[0]?["duration"];
          Utils.log(data);
          Utils.log(data["features"]?[0]?["properties"]?["segments"]?[0]
              ?["distance"]);
          /* repas_livraison_form.control("lieu_dest")?.patchValue(
            "${repas_livraison_form.rawValue["lieu_dest"]} - ${repas_livraison_distance / 1000}km"); */
          if (mounted) setState(() {});

          tarification_commande_post = post_request(
              "$API_BASE_URL/client/tarification/commande", // API URL
              Utils.TOKEN,
              {
                "nbreKm": (repas_livraison_distance / 1000).floor(),
                "type_commande_id": Utils.TYPE_COMMANNDES["repas"],
                "client_id": Utils.client["client_id"],
              }, // Query parameters (if any)
              (response) {
            // Success callback
            Utils.log(("response", response));
            commande_info = response["data"][0];
            var cout_livraison = 0;
            if (commande_info["nbreKm"] != null) {
              cout_livraison =
                  commande_info["nbreKm"] * commande_info["coutKm"];
            }

            commande_info["cout_livraison"] = cout_livraison;

            commande_info["totalReduction"] = commande_info["tauxPromotion"] +
                commande_info["reductionParrainage"] +
                commande_info["reductionFidelisation"];
            Utils.log(("commande_info", commande_info));
            if (mounted) {
              setState(() {
                loading_directions = false;
              });
            }
          }, (error) {
Utils.show_toast(context, error);            // Error callback
            if (mounted) {
              setState(() {
                loading_directions = false;
              });
            }
            //print(error);
          }, repas_livraison_form, context);
          //listOfPoints = data['features'][0]['geometry']['coordinates'];
        } else {
          Utils.log_error(response.body);
          show_repick_dialog(end);

          if (json.decode(response.body)?["error"]?["code"] == 2010) {}
        }
      });
    } on Exception catch (e) {
      Utils.log_error(e.toString());
      show_repick_dialog(end);
      if (mounted) {
        setState(() {
          loading_directions = false;
        });
      }
    }
  }

  void show_repick_dialog(String end) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Emplacement géographique invalide"),
            content: SmallBoldText(
                text: "Veuillez selectionner un emplacement plus précis."),
            actions: <Widget>[
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Rééessayer →'),
                onPressed: () {
                  Navigator.of(context).pop();
                  launch_map_for_result(
                      "lieu de destination", "lieu_dest", end);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            (kToolbarHeight + 20).sp), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 10), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Commande Repas",
                      color: Utils.colorToHex(AppColors.dark)),
                  Image(
                    image: AssetImage('assets/img/repas-image.png'),
                    height: 40.sp,
                  )
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
      body: Container(
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: step_index,
                onStepTapped: (int step) {
                  if (mounted) {
                    setState(() {
                      step_index = step;
                    });
                  }
                },
                onStepContinue: step_index < 3
                    ? () {
                        if (mounted) {
                          setState(() {
                            step_index += 1;
                          });
                        }
                      }
                    : null,
                onStepCancel: step_index > 0
                    ? () {
                        if (mounted) {
                          setState(() {
                            step_index -= 1;
                          });
                        }
                      }
                    : null,
                steps: <Step>[
                  Step(
                    title: SmallTitreText(
                        text: step_index == 0 ? "Récapitulatif" : ""),
                    content: get_step_1(),
                    isActive: step_index >= 0,
                    state: step_index >= 0
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: SmallTitreText(
                        text: step_index == 1 ? "Livraison" : ""),
                    content: get_step_2(),
                    isActive: step_index >= 1,
                    state: step_index >= 1
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title:
                        SmallTitreText(text: step_index == 2 ? "Paiement" : ""),
                    content: get_step_3(),
                    isActive: step_index >= 2,
                    state: step_index >= 2
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                ],
                controlsBuilder:
                    (BuildContext context, ControlsDetails controlsDetails) {
                  if (step_index == 0) {
                    return Row(
                      children: [
                        MediumLightText(text: "Total :"),
                        SizedBox(
                          width: 15.sp,
                        ),
                        MediumBoldText(text: "${Utils.nf(total)} FCFA"),
                        Spacer(),
                        AppButton(
                          onPressed: () {
                            controlsDetails.onStepContinue?.call();
                          },
                          child_type: "text",
                          force_height: 55.sp,
                          svg_image_size: "wx16",
                          text: "Livraison →",
                          text_size: "small",
                          padding: [10.sp, 20.sp, 10.sp, 20.sp],
                          text_align: TextAlign.center,
                          text_weight: "titre",
                          foreground_color: AppColors.dark,
                          border_radius_size: "normal",
                          background_color: AppColors.primary,
                        ),
                      ],
                    );
                  } else if (step_index == 1) {
                    return Row(
                      children: [
                        Spacer(),
                        AppButton(
                          onPressed: () {
                            controlsDetails.onStepContinue?.call();
                          },
                          child_type: "text",
                          force_height: 55.sp,
                          disabled: loading_directions == true ||
                              commande_info["cout_livraison"] == null,
                          svg_image_size: "wx16",
                          text: loading_directions == true
                              ? "Veuillez patienter..."
                              : "Paiement →",
                          text_size: "small",
                          padding: [10.sp, 20.sp, 10.sp, 20.sp],
                          text_align: TextAlign.center,
                          text_weight: "titre",
                          foreground_color: AppColors.dark,
                          border_radius_size: "normal",
                          background_color: AppColors.primary,
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBarComponent(active: BottomNavPage.none),
    );
  }

  void onPressed() {}
}

class FedaWebview extends StatefulWidget {
  final int montant_total;
  final int montant_repas;
  final int montant_livraison;
  final int id_commande;

  FedaWebview(
      {super.key,
      required this.montant_total,
      required this.montant_repas,
      required this.montant_livraison,
      required this.id_commande});

  @override
  _FedaWebviewState createState() => _FedaWebviewState();
}

class _FedaWebviewState extends State<FedaWebview> {
  InAppWebViewController? webViewController;
  var _url = "";
  @override
  void initState() {
    super.initState();
    // Ensure that the platform-specific WebView implementation is initialized
    /*  if (WebView.platform == null) {
      WebView.platform = SurfaceAndroidWebView();
    } */
  }

  @override
  Widget build(BuildContext context) {
    //log(htmlContent);

    var feda_url =
        "https://onsecoinx.com/otherfiles/letransporteur/fedapay-view.php?montant_total=${widget.montant_total}&montant_repas=${widget.montant_repas}&montant_livraison=${widget.montant_livraison}&montant_total=${widget.montant_total}&id_commande=${widget.id_commande}&last_name=${Utils.client["nom"]}&first_name=${Utils.client["prenoms"]}&pk=${Utils.YOUR_API_PUBLIC_KEY}";
    Utils.log(feda_url);

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (webViewController != null) {
                webViewController!.reload();
              }
            },
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(feda_url),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useOnLoadResource: true,
            javaScriptEnabled: true,
          ),
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onConsoleMessage: (controller, consoleMessage) {
          try {
            var log_obj = json.decode(consoleMessage.message);
            if (log_obj["reason"] != null) {
              Navigator.pop(context, log_obj);
            }
          } on Exception catch (e) {}
        },
        onLoadStart: (controller, url) {
          if (mounted) {
            setState(() {
              _url = url.toString();
            });
          }
        },
        onLoadStop: (controller, url) async {
          if (mounted) {
            setState(() {
              _url = url.toString();
            });
          }
        },
      ),
    );
  }
}
