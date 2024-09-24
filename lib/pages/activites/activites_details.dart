// pages/activites/activites_details.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/widgets/component/other/star_rating_component.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/messagerie.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/commande/activite_item_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/other/info_box_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_regular_text.dart';

class ActivitesDetails extends StatefulWidget {
  var commande;
  ActivitesDetails({super.key, required this.commande});

  @override
  State<ActivitesDetails> createState() => ActivitesDetailsState();
}

class ActivitesDetailsState extends State<ActivitesDetails> {
  bool loading_commande = false;
  var commande_info = {};

  var total_repas = 0;
  var total_accomps = 0;
  var total_boissons = 0;

  var recap_repas = [];
  var recap_accomps = [];
  var recap_boissons = [];

  var commande_payment = {};

  var step_index = 0;

  FormGroup rating_form = FormGroup({
    'avis_client': FormControl<String>(validators: []),
    'note_livreur': FormControl<int>(validators: []),
    'note_commande': FormControl<int>(validators: []),
    'commande_id': FormControl<int>(validators: []),
  });

  var sending_rating = false;

  late Future<void> evaluation_commade = Future<void>(() {});

  late Future<void> detail_commande_get = Future<void>(() {});

  var commande_categories = [];
  @override
  void initState() {
    // TODO: implement initState
    initData();
    rating_form.control("commande_id").patchValue(widget.commande["id"]);

    super.initState();
  }

  @override
  void dispose() {
    if (evaluation_commade != null) evaluation_commade.ignore();
    if (detail_commande_get != null) detail_commande_get.ignore();
    super.dispose();
  }

  void initData() {
    Utils.log(widget.commande);
    if (mounted) {
      setState(() {
        loading_commande = true;
      });
    }
    commande_categories = Utils.big_data["typeCommande"]?.map((type) {
      switch (type["id"]) {
        case 1:
          type["code"] = "livraison";
          type["icon"] = Icons.delivery_dining_sharp;
          break;
        case 2:
          type["code"] = "restaurant";
          type["icon"] = Icons.restaurant;
          break;
        case 3:
          type["code"] = "taxi";
          type["icon"] = Icons.drive_eta_sharp;
          break;
        default:
      }
      return type;
    }).toList();
    detail_commande_get = get_request(
        "$API_BASE_URL/client/detail/commande/${widget.commande["id"]}", // API URL
        Utils.TOKEN,
        {}, // Query parameters (if any)
        (response) {
      Utils.log(response);
      if (mounted) {
        setState(() {
          commande_info = response["data"]["data"];
          commande_payment = response["data"]["operation"] ?? {};
          commande_info["id"] = widget.commande["id"];
          commande_info["deja_evaluer"] = response["data"]["deja_evaluer"];
          commande_info["cout_livraison"] =
              commande_info["nbreKm"] * commande_info["coutKm"];
          commande_info["totalReduction"] =
              int.parse(commande_info["tauxPromotion"]) +
                  commande_info["reductionParrainage"] +
                  commande_info["reductionFidelisation"];

          if (commande_info["type_commande_id"] ==
              Utils.TYPE_COMMANNDES["repas"]) {
            init_ui_for_repas_commande();
          }
          widget.commande["icon"] = get_categorie_by_code(
              widget.commande["type_commande_id"], "id")?["icon"];
          widget.commande["libelle"] = get_categorie_by_code(
              widget.commande["type_commande_id"], "id")?["libelle"];

          loading_commande = false;
        });
      }
    }, (error) {
Utils.show_toast(context, error);      if (mounted) {
        setState(() {
          loading_commande = false;
        });
      }
    });
  }

  get_categorie_by_code(categorie, dynamic? field) {
    var firstWhere = commande_categories.firstWhere(
        (element) =>
            categorie == (field != null ? element[field] : element?["code"]),
        orElse: () => {});
    //Utils.log((categorie, field, firstWhere));
    return firstWhere;
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
                      text: "Détail d'activité",
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(0),
                color: AppColors.gray7,
                child: loading_commande == true
                    ? Column(
                        children: [
                          Center(
                            child: loading_commandes_component(),
                          ),
                        ],
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ActiviteItemComponent(
                                commande: widget.commande, mode: "compact"),
                            SizedBox(
                              height: 40.sp,
                            ),
                            commande_content(),
                            SizedBox(
                              height: 25.sp,
                            ),
                            livreur_component(),
                            SizedBox(
                              height: 25.sp,
                            ),
                            evaluation_component(),
                            SizedBox(
                              height: 15.sp,
                            ),
                            historique_component(),
                            SizedBox(
                              height: 25.sp,
                            ),
                          ],
                        ),
                      ))),
      ),
      bottomNavigationBar: AppBottomNavBarComponent(active: BottomNavPage.none),
    );
  }

  livreur_component() {
    widget.commande["livreur"] = {
      "name":
          "${commande_info["livreur_nom"]} ${commande_info["livreur_prenoms"]}",
      "moto_marque": "SUZUKI XXXXXX",
      "moto_immat": "CA568540",
      "phone": "${commande_info["livreur_telephone"]}",
      "photo": "${STORAGE_BASE_URL}/${commande_info["livreur_photo"]}"
    };
    Utils.log(widget.commande["livreur"]);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15.sp),
          decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                  width: 1)),
          child: Center(
            child: SmallTitreText(
              text: widget.commande["type_commande_id"] ==
                      Utils.TYPE_COMMANNDES["taxi"]
                  ? "Votre chauffeur"
                  : "Votre livreur",
            ),
          ),
        ),
        widget.commande["livreur"] == null
            ? Container(
                width: double.infinity,
                height: 200.sp,
                padding:
                    EdgeInsets.symmetric(horizontal: 70.sp, vertical: 15.sp),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.primary,
                        style: BorderStyle.solid,
                        width: 1)),
                child: Center(
                  child: SmallLightText(
                    textAlign: TextAlign.center,
                    color: Utils.colorToHex(AppColors.gray3),
                    text:
                        "Les informations de votre ${(widget.commande["type_commande_id"] == Utils.TYPE_COMMANNDES["taxi"] ? "chauffeur" : "livreur")} s'afficheront ici une fois qu'il vous sera affecté.",
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 25.sp, vertical: 25.sp),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(
                        color: AppColors.transparent,
                        style: BorderStyle.solid,
                        width: 1)),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 75.sp,
                            height: 75.sp,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.sp)),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        widget.commande["livreur"]["photo"]))),
                          ),
                          SizedBox(
                            width: 15.sp,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MediumBoldText(
                                  text: widget.commande["livreur"]["name"]),
                              /* Row(
                                children: [
                                  Icon(widget.commande["type_commande_id"] ==
                                          Utils.TYPE_COMMANNDES["taxi"]
                                      ? Icons.directions_car_rounded
                                      : Icons.delivery_dining),
                                  SmallBoldText(
                                      text: widget.commande["livreur"]
                                          ["moto_marque"])
                                ],
                              ), */
                              SmallRegularText(
                                  text:
                                      "Tel : ${widget.commande["livreur"]["phone"]}")
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15.sp,
                      ),
                      Row(
                        children: [
                          RouterButton(
                            destination: Messagerie(
                              client_commande: commande_info,
                            ),
                            child_type: "icon",
                            icon: Icon(
                              Icons.message,
                              color: AppColors.dark,
                              size: 25.sp,
                            ),
                            icon_size: "normal",
                            text: "Discuter",
                            text_weight: "bold",
                            with_text: true,
                            background_color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 15.sp,
                          ),
                          AppButton(
                            onPressed: () {
                              launch_livreur_phone();
                            },
                            child_type: "icon",
                            icon: Icon(
                              Icons.phone,
                              size: 25.sp,
                              color: Colors.white,
                            ),
                            icon_size: "normal",
                            text: "Appeler",
                            with_text: true,
                            foreground_color: Colors.white,
                            background_color: AppColors.dark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  evaluation_component() {
    return widget.commande["cloturer"] == 1 && commande_info["deja_evaluer"] != true
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
            width: double.infinity,
            height: 300.sp,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1)),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: step_index,
              elevation: 0,
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
                  title: Container(),
                  content: get_evaluation_step_1(),
                  isActive: step_index >= 0,
                  state:
                      step_index >= 0 ? StepState.complete : StepState.disabled,
                ),
                Step(
                  title: Container(),
                  content: get_evaluation_step_2(),
                  isActive: step_index >= 1,
                  state:
                      step_index >= 1 ? StepState.complete : StepState.disabled,
                ),
                Step(
                  title: Container(),
                  content: get_evaluation_step_3(),
                  isActive: step_index >= 2,
                  state:
                      step_index >= 2 ? StepState.complete : StepState.disabled,
                ),
              ],
              controlsBuilder:
                  (BuildContext context, ControlsDetails controlsDetails) {
                return Row(
                  children: [],
                );
              },
            ),
          )
        : Container();
  }

  get_evaluation_step_1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SmallTitreText(text: "Donnez une note au service"),
        SizedBox(
          height: 10.sp,
        ),
        StarRatingComponent(onRated: (int rate) {
          Utils.log(rate);
          if (mounted) {
            setState(() {
              step_index++;
              rating_form.control("note_commande").patchValue(rate);
            });
          }
        })
      ],
    );
  }

  get_evaluation_step_2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SmallTitreText(
            text:
                "Donnez une notre au ${widget.commande["type_commande_id"] == Utils.TYPE_COMMANNDES["taxi"] ? "chauffeur" : "livreur"}"),
        SizedBox(
          height: 10,
        ),
        StarRatingComponent(onRated: (int rate) {
          Utils.log(rate);
          if (mounted) {
            setState(() {
              step_index++;
              rating_form.control("note_livreur").patchValue(rate);
            });
          }
        })
      ],
    );
  }

  get_evaluation_step_3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallLightText(
          text: "Et pour finir...",
          color: Utils.colorToHex(AppColors.gray2),
        ),
        SizedBox(
          height: 10,
        ),
        ReactiveForm(
            formGroup: rating_form,
            child: Column(
              children: [
                ReactiveTextField(
                  formControlName: 'avis_client',
                  decoration: Utils.get_default_input_decoration_normal(
                      rating_form.control('avis_client'),
                      false,
                      'Laissez nous un mot',
                      null,
                      null,
                      null),
                )
              ],
            )),
        SizedBox(
          height: 10,
        ),
        AppButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  sending_rating = true;
                });
              }
              //send request
              evaluation_commade = post_request(
                  "${API_BASE_URL}/client/evaluation/commande", // API URL
                  Utils.TOKEN,
                  rating_form.rawValue, // Query parameters (if any)
                  (response) {
                // Success callback
                if (mounted) {
                  setState(() {
                    sending_rating = false;
                  });
                }
                if(response["status"]){
                  initData();
                }
              }, (error) {
Utils.show_toast(context, error);                // Error callback
                if (mounted) {
                  setState(() {
                    sending_rating = false;
                  });
                }
                //print(error);
              }, rating_form, context);
            },
            background_color: AppColors.primary,
            loading: sending_rating,
            text: "Envoyer",
            text_weight: "bold"),
      ],
    );
  }

  historique_component() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.sp),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppColors.dark,
              ),
              SizedBox(
                width: 10.sp,
              ),
              SmallLightText(text: "Historique de la commande"),
            ],
          ),
          SizedBox(
            height: 5.sp,
          ),
          widget.commande["suivies"] != null
              ? Column(
                  children: [
                    ...widget.commande["suivies"].map((suivi) {
                      Duration difference = DateTime.now().difference(DateTime.parse(suivi["created_at"]));
                      double hoursSince = difference.inHours.toDouble() +
                          (difference.inMinutes.remainder(60) / 60);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              XSmallBoldText(text: suivi["message"]),
                              Spacer(),
                              XSmallLightText(
                                  text: hoursSince > 24 ? "il y a ${Utils.ta(suivi["created_at"])}": suivi["created_at"].split(" ")[1])
                            ],
                          ),
                          SizedBox(
                            height: 5.sp,
                          ),
                          Container(
                            height: 1,
                            color: AppColors.gray5,
                          )
                        ],
                      );
                    })
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    initData();
  }

  repas_commande_content() {
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
              margin: EdgeInsets.symmetric(vertical: 20),
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
      Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15.sp),
        decoration: BoxDecoration(
            color: AppColors.gray7,
            border: Border.all(
                color: AppColors.gray5, style: BorderStyle.solid, width: 1)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
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
                      text: "${Utils.nf(commande_info["cout_livraison"])} FCFA")
                ],
              ),
            ),
          ],
        ),
      ),
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
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
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
                              "Réduction promotionelle : -${Utils.nf(commande_info["tauxPromotion"])} FCFA"),
                      SizedBox(
                        height: 3.sp,
                      ),
                      XSmallRegularText(
                          text:
                              "Réduction parrainage -${Utils.nf(commande_info["reductionParrainage"])} FCFA"),
                      SizedBox(
                        height: 3.sp,
                      ),
                      XSmallRegularText(
                          text:
                              "Réduction de fidélisation -${Utils.nf(commande_info["reductionFidelisation"])} FCFA"),
                    ],
                  ),
                  Spacer(),
                  MediumBoldText(
                      color: Utils.colorToHex(
                        Colors.red,
                      ),
                      text:
                          "-${Utils.nf(commande_info["totalReduction"])} FCFA")
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 30.sp,
      ),
      SizedBox(
        height: 15.sp,
      ),
    ]);
  }

  livraison_commande_content() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Column(
        children: [
          InfoBoxComponent(
            button_widget: {},
            title: "Lieu de récupération",
            content: commande_info["lieuRecuperation"],
            icon: Icon(Icons.location_pin),
          ),
          SizedBox(
            height: 5.sp,
          ),
          InfoBoxComponent(
            button_widget: {},
            title: "Contact de récupération",
            content: commande_info["contactRecuperation"],
            icon: Icon(Icons.phone),
          ),
          SizedBox(
            height: 5.sp,
          ),
          InfoBoxComponent(
            button_widget: {},
            title: "Lieu de livraison",
            content: commande_info["lieuLivraison"],
            icon: Icon(Icons.location_pin),
          ),
          SizedBox(
            height: 5.sp,
          ),
          InfoBoxComponent(
            button_widget: {},
            title: "Contact de livraison",
            content: commande_info["contactLivraison"],
            icon: Icon(Icons.phone),
          ),
          SizedBox(
            height: 25.sp,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15.sp),
            decoration: BoxDecoration(
                color: AppColors.gray7,
                border: Border.all(
                    color: AppColors.gray5,
                    style: BorderStyle.solid,
                    width: 1)),
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
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
                                  "Réduction promotionelle : -${Utils.nf(commande_info["tauxPromotion"])} FCFA"),
                          SizedBox(
                            height: 3.sp,
                          ),
                          XSmallRegularText(
                              text:
                                  "Réduction parrainage -${Utils.nf(commande_info["reductionParrainage"])} FCFA"),
                          SizedBox(
                            height: 3.sp,
                          ),
                          XSmallRegularText(
                              text:
                                  "Réduction de fidélisation -${Utils.nf(commande_info["reductionFidelisation"])} FCFA"),
                        ],
                      ),
                      Spacer(),
                      MediumBoldText(
                          color: Utils.colorToHex(
                            Colors.red,
                          ),
                          text:
                              "-${Utils.nf(commande_info["totalReduction"])} FCFA")
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  taxi_commande_content() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Column(
        children: [
          InfoBoxComponent(
            button_widget: {},
            title: "Lieu de départ",
            content: commande_info["lieuRecuperation"],
            icon: Icon(Icons.location_pin),
          ),
          SizedBox(
            height: 5.sp,
          ),
          InfoBoxComponent(
            button_widget: {},
            title: "Lieu de destination",
            content: commande_info["lieuLivraison"],
            icon: Icon(Icons.location_pin),
          ),
          SizedBox(
            height: 5.sp,
          ),
          InfoBoxComponent(
            button_widget: {},
            title: "Contact à appeler",
            content: commande_info["contactLivraison"],
            icon: Icon(Icons.phone),
          ),
          SizedBox(
            height: 25.sp,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15.sp),
            decoration: BoxDecoration(
                color: AppColors.gray7,
                border: Border.all(
                    color: AppColors.gray5,
                    style: BorderStyle.solid,
                    width: 1)),
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
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
                                  "Réduction promotionelle : -${Utils.nf(commande_info["tauxPromotion"])} FCFA"),
                          SizedBox(
                            height: 3.sp,
                          ),
                          XSmallRegularText(
                              text:
                                  "Réduction parrainage -${Utils.nf(commande_info["reductionParrainage"])} FCFA"),
                          SizedBox(
                            height: 3.sp,
                          ),
                          XSmallRegularText(
                              text:
                                  "Réduction de fidélisation -${Utils.nf(commande_info["reductionFidelisation"])} FCFA"),
                        ],
                      ),
                      Spacer(),
                      MediumBoldText(
                          color: Utils.colorToHex(
                            Colors.red,
                          ),
                          text:
                              "-${Utils.nf(commande_info["totalReduction"])} FCFA")
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  commande_content() {
    if (commande_info["type_commande_id"] == Utils.TYPE_COMMANNDES["repas"]) {
      return repas_commande_content();
    } else if (commande_info["type_commande_id"] ==
        Utils.TYPE_COMMANNDES["livraison"]) {
      return livraison_commande_content();
    } else if (commande_info["type_commande_id"] ==
        Utils.TYPE_COMMANNDES["taxi"]) {
      return taxi_commande_content();
    }
  }

  loading_commandes_component() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 40.sp,
          ),
          SvgPicture.asset(
            "assets/SVG/activite-menu-stroke-icon.svg",
            height: 100.sp,
            width: 100.sp,
            fit: BoxFit.contain,
            color: AppColors.gray5,
          ),
          SizedBox(
            height: 10,
          ),
          SmallLightText(
            text: "Chargement",
            color: Utils.colorToHex(AppColors.gray3),
          )
        ],
      ),
    );
  }

  void onPressed() {}

  void init_ui_for_repas_commande() {
    total_repas = 0;
    total_accomps = 0;
    total_boissons = 0;
    Utils.log(commande_info);
    recap_repas = commande_info["articles"].map((article) {
      int prix = article["pivot"]["prix"];
      int nbre = article["pivot"]["nbrePlat"];
      total_repas += prix * nbre;

      return {
        "count": article["pivot"]["nbrePlat"],
        "name": article["libelle"],
        "price": article["pivot"]["prix"],
      };
    }).toList();
    recap_accomps = commande_info["accompagnements"].map((accomp) {
      int prix = accomp["pivot"]["prix"];
      int nbre = accomp["pivot"]["nbre"];
      total_accomps += prix * nbre;

      return {
        "count": accomp["pivot"]["nbre"],
        "name": accomp["libelle"],
        "price": accomp["pivot"]["prix"],
      };
    }).toList();
    recap_boissons = commande_info["boissons"].map((boisson) {
      int prix = boisson["pivot"]["prix"];
      int nbre = boisson["pivot"]["nbre"];
      total_boissons += prix * nbre;

      return {
        "count": boisson["pivot"]["nbre"],
        "name": boisson["libelle"],
        "price": boisson["pivot"]["prix"],
      };
    }).toList();
  }

  Future<void> launch_livreur_phone() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: widget.commande["livreur"]["phone"],
    );
    try {
      UrlLauncher.launchUrl(launchUri);
    } on Exception catch (e) {
      // TODO
    }
  }
}
