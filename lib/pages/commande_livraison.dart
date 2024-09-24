// pages/commande_livraison.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/activites/activites_details.dart';
import 'package:letransporteur_client/pages/commande_repas.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/page/map/map_picker_page.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CommandeLivraison extends StatefulWidget {
  const CommandeLivraison({super.key});

  @override
  State<CommandeLivraison> createState() => CommandeLivraisonState();
}

class CommandeLivraisonState extends State<CommandeLivraison> {
  int step_index = 0;
  dynamic lieux_selected = {};
  bool boissons_expanded = false;
  bool accompagnement_expanded = false;
  FormGroup livraison_form = FormGroup({
    'lieu_recup': FormControl<String>(validators: [
      Validators.required,
    ]),
    'contact_recup': FormControl<String>(validators: [
      Validators.number(allowNegatives: false),
      Validators.required,
    ]),
    'lieu_dest': FormControl<String>(validators: [
      Validators.required,
    ]),
    'message': FormControl<String>(validators: []),
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
  var livraison_duree = 0.0;

  bool commande_loading = false;

  var commande_info = {};

  int total_repas = 0;
  int total_accomps = 0;
  int total_boissons = 0;

  var tarifications = [];

  late Future<void> tarification_commande_post = Future<void>(() {});

  late Future<void> store_commande_post = Future<void>(() {});

  @override
  void initState() {
    super.initState();

    Utils.log(Utils.panier);
  }

  @override
  void dispose() {
    if (tarification_commande_post != null) tarification_commande_post.ignore();
    if (store_commande_post != null) store_commande_post.ignore();
    super.dispose();
  }

  Widget get_step_1() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ReactiveForm(
        formGroup: livraison_form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10.sp),
            ReactiveTextField(
              formControlName: 'lieu_recup',
              onTap: (control) {
                launch_map_for_result(
                    "lieu de récupération", "lieu_recup", null);
              },
              decoration: Utils.get_default_input_decoration_normal(
                  livraison_form.control('lieu_recup'),
                  false,
                  'Lieu de récupération',
                  {"icon": Icons.my_location, "size": 24.sp},
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 15.sp),
            IntlPhoneField(
              decoration: Utils.get_default_input_decoration_normal(
                  livraison_form.control('contact_recup'),
                  true,
                  'Contact de récupération',
                  null,
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
              initialCountryCode: 'BJ',
              onChanged: (phone) {
                if (mounted) {
                  setState(() {
                    livraison_form
                        .patchValue({"contact_recup": phone.completeNumber});
                    try {
                      if (phone.isValidNumber()) {
                        livraison_form.control("contact_recup").setErrors({});
                      }
                    } on Exception catch (e) {}
                  });
                }
              },
            ),
            SizedBox(height: 25.sp),
            ReactiveTextField(
              formControlName: 'lieu_dest',
              onTap: (control) {
                launch_map_for_result("lieu de livraison", "lieu_dest", null);
              },
              decoration: Utils.get_default_input_decoration_normal(
                  livraison_form.control('lieu_dest'),
                  false,
                  'Lieu de livraison',
                  {"icon": Icons.my_location, "size": 24.sp},
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 15.sp),
            IntlPhoneField(
              decoration: Utils.get_default_input_decoration_normal(
                  livraison_form.control('contact_dest'),
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
                    livraison_form
                        .patchValue({"contact_dest": phone.completeNumber});
                    try {
                      if (phone.isValidNumber()) {
                        livraison_form.control("contact_dest").setErrors({});
                      }
                    } on Exception catch (e) {}
                  });
                }
              },
            ),
            SizedBox(height: 15.sp),
            ReactiveTextField(
              formControlName: 'message',
              maxLines: 5,
              decoration: Utils.get_default_input_decoration_multi_lines(
                  livraison_form.control('message'),
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

  Widget get_step_2() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          if (mounted) {
            setState(() {
              tarifications[index]["expanded"] = isExpanded;
            });
          }
        },
        children: [
          ...tarifications.map((tarif) {
            return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Container(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            get_moyen_deplacement_icon(
                                tarif["moyen_deplacement_id"]),
                            color: AppColors.dark,
                            size: 35.sp,
                          ),
                          SizedBox(
                            width: 5.sp,
                          ),
                          Row(
                            children: [
                              MediumBoldText(text: tarif["moyen_deplacement"]),
                              SizedBox(
                                width: 5.sp,
                              ),
                              XSmallBoldText(
                                  text:
                                      "${(livraison_duree / 60).floor()}min • ${tarif["nbreKm"]}km"),
                            ],
                          ),
                          SizedBox(
                            width: 5.sp,
                          ),
                          MediumBoldText(
                              text: "${Utils.nf(tarif["cout_livraison"])} FCFA")
                        ],
                      ),
                    ),
                  );
                },
                body: Container(
                  margin: EdgeInsets.only(bottom: 30.sp, top: 10.sp),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: ReactiveForm(
                        formGroup: store_commande_form,
                        child: Column(children: [
                          ReactiveDropdownField<String>(
                            formControlName: 'mode_paiement',
                            isExpanded: true,
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    store_commande_form
                                        .control('mode_paiement'),
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
                              store_commande(
                                  store_commande_form.rawValue["mode_paiement"],
                                  tarif);
                            },
                            child_type: "text",
                            force_height: 55.sp,
                            loading: commande_loading,
                            svg_image_size: "wx16",
                            text:
                                "Commander pour ${Utils.nf(tarif["cout_livraison"])} FCFA",
                            text_size: "small",
                            padding: [10, 20, 10, 20],
                            text_align: TextAlign.center,
                            text_weight: "titre",
                            foreground_color: AppColors.dark,
                            border_radius_size: "normal",
                            background_color: AppColors.primary,
                          ),
                        ])),
                  ),
                ),
                isExpanded: tarif["expanded"]);
          })
        ],
      ),
    ]);
  }

  createTransaction(commande_obj, commande_info) async {
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

  void store_commande(mode_paiement, commande_info) {
    Utils.log("commander");
    Utils.log(Utils.big_data["infoClient"]);
    Utils.client = Utils.big_data["infoClient"];

    if (mounted) {
      setState(() {
        commande_loading = true;
      });
    }

    var store_commande_obj = {
      "articles": [],
      "boissons": [],
      "accompagnements": [],
      "modePaiement": mode_paiement,
      "tempsEstimatif": livraison_duree / 60,
      "nbreKm": commande_info["nbreKm"],
      "type_commande_id": Utils.TYPE_COMMANNDES["livraison"],
      "tauxPromotion": commande_info["tauxPromotion"],
      "client_id": Utils.client["client_id"],
      "coutKm": commande_info["coutKm"],
      "restaurant_id": null,
      "lieuLivraison": livraison_form.rawValue["lieu_dest"],
      "longitudeLivraison": lieux_selected["lieu_dest"]["longitude"],
      "latitudeLivraison": lieux_selected["lieu_dest"]["latitude"],
      "lieuRecuperation": livraison_form.rawValue["lieu_recup"],
      "longitudeRecuperation": lieux_selected["lieu_recup"]["longitude"],
      "latitudeRecuperation": lieux_selected["lieu_recup"]["latitude"],
      "contactLivraison": livraison_form.rawValue["contact_dest"],
      "contactRecuperation": livraison_form.rawValue["contact_recup"],
      "messageAuLivreur": livraison_form.rawValue["message"],
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
      if (mounted) {
        setState(() {
          commande_loading = false;
        });
      }
      if (mode_paiement == "mobile money") {
        createTransaction(response, commande_info);
      } else {
        after_store_commande(response);
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
      livraison_form.control(contol_to_update)?.patchValue(map_result["title"]);
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
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (mounted) {
            setState(() {
              commande_loading = false;
            });
          }
          repas_livraison_distance =
              data["features"]?[0]?["properties"]?["segments"]?[0]?["distance"];
          livraison_duree =
              data["features"]?[0]?["properties"]?["segments"]?[0]?["duration"];
          Utils.log(data);
          Utils.log(data["features"]?[0]?["properties"]?["segments"]?[0]
              ?["distance"]);
          /* livraison_form.control("lieu_dest")?.patchValue(
            "${livraison_form.rawValue["lieu_dest"]} - ${repas_livraison_distance / 1000}km"); */
          if (mounted) setState(() {});

          Clipboard.setData(ClipboardData(
              text: json.encode({
            "geolocalisation_url": get_route_url(start, end).toString(),
            "url": "$API_BASE_URL/client/tarification/commande",
            "token": Utils.TOKEN,
            "payload": {
              "nbreKm": (repas_livraison_distance / 1000).floor(),
              "type_commande_id": Utils.TYPE_COMMANNDES["livraison"],
              "client_id": Utils.client["client_id"],
            },
          }))).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: AppColors.primary_light,
                content: SmallBoldText(
                  text: "Payload tarification copié !",
                )));
          });

          tarification_commande_post = post_request(
              "$API_BASE_URL/client/tarification/commande", // API URL
              Utils.TOKEN,
              {
                "nbreKm": (repas_livraison_distance / 1000).floor(),
                "type_commande_id": Utils.TYPE_COMMANNDES["livraison"],
                "client_id": Utils.client["client_id"],
              }, // Query parameters (if any)
              (response) {
            // Success callback
            Utils.log(["response", response]);
            int map_index = 0;
            tarifications = (response["data"] as List).map((tarif) {
              var cout_livraison = 0;
              map_index++;
              if (tarif["nbreKm"] != null) {
                cout_livraison = tarif["nbreKm"] * tarif["coutKm"];
              }

              var totalReduction = tarif["tauxPromotion"] +
                  tarif["reductionParrainage"] +
                  tarif["reductionFidelisation"];

              return {
                "expanded": map_index == 1 ? true : false,
                "cout_livraison": cout_livraison,
                "totalReduction": totalReduction,
                ...tarif
              };
            }).toList();
            Utils.log(["tarifications", tarifications]);
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
          }, livraison_form, context);
          //listOfPoints = data['features'][0]['geometry']['coordinates'];
        } else {
          Utils.log_error(response.body);
          if (json.decode(response.body)?["error"]?["code"] == 2010) {}
          show_repick_dialog(end);
        }
      }).catchError((e) {
        show_repick_dialog(end);
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
          padding: EdgeInsets.only(bottom: 10.sp), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Commande Livraison",
                      color: Utils.colorToHex(AppColors.dark)),
                  Image(
                    image: AssetImage('assets/img/livraison-image.png'),
                    height: 40.sp,
                  )
                ],
              ),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.sp), // Set the radius here
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Utils.location_good
            ? Column(
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
                      onStepContinue: step_index < 2
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
                              text:
                                  step_index == 0 ? "Infos de livraison" : ""),
                          content: get_step_1(),
                          isActive: step_index >= 0,
                          state: step_index >= 0
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                        Step(
                          title: SmallTitreText(
                              text: step_index == 1 ? "Tarification" : ""),
                          content: get_step_2(),
                          isActive: step_index >= 1,
                          state: step_index >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                      ],
                      controlsBuilder: (BuildContext context,
                          ControlsDetails controlsDetails) {
                        return Row(
                          children: [
                            Spacer(),
                            if (step_index == 0)
                              AppButton(
                                onPressed: () {
                                  controlsDetails.onStepContinue?.call();
                                },
                                disabled: !livraison_form.valid,
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
                              )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              )
            : no_service_here_component(),
      ),
      bottomNavigationBar: AppBottomNavBarComponent(active: BottomNavPage.none),
    );
  }

  no_service_here_component() {
    return Container(
      padding: EdgeInsets.all(40.sp),
      child: Column(
        children: [
          Icon(
            Icons.delivery_dining,
            color: AppColors.gray5,
            size: 100.sp,
          ),
          SizedBox(
            height: 10,
          ),
          SmallLightText(
            textAlign: TextAlign.center,
            text:
                "Désolé, les services de livraison ne sont pas disponibles dans votre localité.",
            color: Utils.colorToHex(AppColors.gray3),
          ),
          SizedBox(
            height: 50.sp,
          ),
          RouterButton(
            destination: Accueil(
              token: Utils.TOKEN,
            ),
            no_back_button: true,
            child_type: "text",
            force_height: 55.sp,
            loading: commande_loading,
            svg_image_size: "wx16",
            text: "← Retour à l'accueil",
            text_size: "small",
            padding: [10, 20, 10, 20],
            text_align: TextAlign.center,
            text_weight: "titre",
            foreground_color: AppColors.dark,
            border_radius_size: "normal",
            background_color: AppColors.primary,
          )
        ],
      ),
    );
  }

  void onPressed() {}

  IconData? get_moyen_deplacement_icon(m_id) {
    switch (m_id) {
      case 1:
        return Icons.motorcycle;
      case 2:
        return Icons.directions_car_filled;
      default:
    }
    return null;
  }
}
