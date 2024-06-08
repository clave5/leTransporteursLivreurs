// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/input/input_box_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/other/info_box_component.dart';
import 'package:letransporteur_client/widgets/map/map_picker_screen.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
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
  FormGroup form = FormGroup({
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
    'contact_dest': FormControl<String>(validators: [
      Validators.number(allowNegatives: false),
      Validators.required,
    ]),
  });

  bool loading_directions = false;

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
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    width: 5,
                  ),
                  MediumBoldText(text: "1x"),
                  SizedBox(
                    width: 5,
                  ),
                  SmallRegularText(text: "Assiette Burger"),
                  SizedBox(
                    width: 5,
                  ),
                  SmallBoldText(text: "= 4.500 F CFA"),
                  Spacer(),
                  AppButton(
                      onPressed: () {
                        Utils.log("minus");
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
                    width: 10,
                  ),
                  AppButton(
                      onPressed: () {
                        Utils.log("plus");
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
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 150,
                    height: 110,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    clipBehavior: Clip.antiAlias,
                    child: Image(
                      image: AssetImage("assets/img/plat-image-1.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        SmallBoldText(text: 'Contenu du repas'),
                        SizedBox(height: 5),
                        Row(children: [
                          Icon(
                            Icons.circle,
                            size: 8.0, // Bullet size
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: XSmallRegularText(
                              text: "Hamburger",
                            ),
                          ),
                        ]),
                        Row(children: [
                          Icon(
                            Icons.circle,
                            size: 8.0, // Bullet size
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: XSmallRegularText(
                              text: "Viande hachée",
                            ),
                          ),
                        ]),
                        Row(children: [
                          Icon(
                            Icons.circle,
                            size: 8.0, // Bullet size
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: XSmallRegularText(
                              text: "Portion de frites",
                            ),
                          ),
                        ])
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              color: AppColors.gray5,
              height: 1,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    width: 5,
                  ),
                  MediumBoldText(text: "2x"),
                  SizedBox(
                    width: 5,
                  ),
                  SmallRegularText(text: "Cannette Sprite"),
                  SizedBox(
                    width: 5,
                  ),
                  SmallBoldText(text: "= 1.000 F CFA"),
                  Spacer(),
                  AppButton(
                      onPressed: () {
                        Utils.log("minus");
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
                    width: 10,
                  ),
                  AppButton(
                      onPressed: () {
                        Utils.log("plus");
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
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Row(
          children: [
            RouterButton(
                destination: Accueil(),
                child_type: "text",
                force_height: 40,
                svg_image_size: "wx16",
                text: "+ Ajouter un repas",
                text_size: "small",
                padding: [10, 20, 10, 20],
                text_align: TextAlign.center,
                text_weight: "titre",
                foreground_color: AppColors.dark,
                border_radius_size: "normal",
                background_color: AppColors.primary),
            Spacer(),
            MediumLightText(text: "Total :"),
            SizedBox(
              width: 5,
            ),
            MediumBoldText(text: "5.000 F CFA")
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        color: AppColors.gray5,
        height: 1,
      ),
      Container(
          child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            if (index == 0) {
              boissons_expanded = isExpanded;
            } else if (index == 1) {
              accompagnement_expanded = isExpanded;
            }
          });
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
                              width: 5,
                            ),
                            SmallRegularText(text: "Cannette Coca : 500 F CFA"),
                            Spacer(),
                            AppButton(
                                onPressed: () {
                                  Utils.log("minus");
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
                              width: 10,
                            ),
                            AppButton(
                                onPressed: () {
                                  Utils.log("plus");
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
                        )),
                    SizedBox(
                      height: 10,
                    ),
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
                              width: 5,
                            ),
                            SmallRegularText(
                                text: "Cannette Guiness : 500 F CFA"),
                            Spacer(),
                            AppButton(
                                onPressed: () {
                                  Utils.log("minus");
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
                              width: 10,
                            ),
                            AppButton(
                                onPressed: () {
                                  Utils.log("plus");
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
                        )),
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
                              width: 5,
                            ),
                            SmallRegularText(text: "Akassa : 500 F CFA"),
                            Spacer(),
                            AppButton(
                                onPressed: () {
                                  Utils.log("minus");
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
                              width: 10,
                            ),
                            AppButton(
                                onPressed: () {
                                  Utils.log("plus");
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
                        )),
                    SizedBox(
                      height: 10,
                    ),
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
                              width: 5,
                            ),
                            SmallRegularText(text: "Ablo : 500 F CFA"),
                            Spacer(),
                            AppButton(
                                onPressed: () {
                                  Utils.log("minus");
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
                              width: 10,
                            ),
                            AppButton(
                                onPressed: () {
                                  Utils.log("plus");
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
                        )),
                  ],
                ),
              ),
              isExpanded: accompagnement_expanded)
        ],
      )),
      SizedBox(
        height: 50,
      )
    ]);
  }

  Widget get_step_2() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ReactiveForm(
        formGroup: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            ReactiveTextField(
              formControlName: 'lieu_recup',
              onTap: (control) {
                launch_map_for_result("lieu de récupération", "lieu_recup");
              },
              decoration: Utils.get_default_input_decoration(
                  'Lieu de récupération',
                  Icons.my_location,
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 15),
            ReactiveTextField(
              formControlName: 'contact_recup',
              keyboardType: TextInputType.phone,
              decoration: Utils.get_default_input_decoration(
                  'Contact de récupération',
                  Icons.phone,
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 25),
            ReactiveTextField(
              formControlName: 'lieu_dest',
              onTap: (control) {
                launch_map_for_result("lieu de destination", "lieu_dest");
              },
              decoration: Utils.get_default_input_decoration(
                  'Lieu de livraison',
                  Icons.my_location,
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 15),
            ReactiveTextField(
              formControlName: 'contact_dest',
              keyboardType: TextInputType.phone,
              decoration: Utils.get_default_input_decoration(
                  'Contact de livraison',
                  Icons.phone,
                  Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
      SizedBox(
        height: 50,
      )
    ]);
  }

  Future<void> launch_map_for_result(
      String lieu_label, String contol_to_update) async {
    final map_result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapPickerScreen(
                intent_data: {"lieu_label": lieu_label},
              )),
    );
    // If a result is returned, update the state.
    if (map_result != null) {
      Utils.log(map_result);
      form.control(contol_to_update)?.patchValue(map_result["title"]);
      lieux_selected[contol_to_update] = map_result;
      if (lieux_selected.length == 2) {
        get_directions(
          "${lieux_selected["lieu_recup"]["longitude"]},${lieux_selected["lieu_recup"]["latitude"]}",
          "${lieux_selected["lieu_dest"]["longitude"]},${lieux_selected["lieu_dest"]["latitude"]}",
        );
      } else {
        Utils.log_error(lieux_selected);
      }
      setState(() {});
    }
  }

  // Method to consume the OpenRouteService API
  get_directions(String start, String end) async {
    // Requesting for openrouteservice api
    setState(() {
      loading_directions = true;
    });

    try {
      Utils.log(get_route_url(start, end).toString());
      var response = await http.get(get_route_url(start, end));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Utils.log(data);
        Utils.log(data["features"]?[0]?["properties"]?["segments"]?[0]?["distance"]);
        //listOfPoints = data['features'][0]['geometry']['coordinates'];
      } else {
        Utils.log_error(response.reasonPhrase);
      }
      setState(() {
        loading_directions = false;
      });
    } on Exception catch (e) {
      Utils.log_error(e.toString());
      setState(() {
        loading_directions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 20), // Adjust height as needed
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
                    height: 40,
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
                  setState(() {
                    step_index = step;
                  });
                },
                onStepContinue: step_index < 3
                    ? () {
                        setState(() {
                          step_index += 1;
                        });
                      }
                    : null,
                onStepCancel: step_index > 0
                    ? () {
                        setState(() {
                          step_index -= 1;
                        });
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
                    content: Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Content for Step 3')),
                    isActive: step_index >= 2,
                    state: step_index >= 2
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                ],
                controlsBuilder:
                    (BuildContext context, ControlsDetails controlsDetails) {
                  return Row(
                    children: [
                      Spacer(),
                      if (step_index == 0)
                        AppButton(
                          onPressed: () {
                            controlsDetails.onStepContinue?.call();
                          },
                          child_type: "text",
                          force_height: 40,
                          svg_image_size: "wx16",
                          text: "Livraison →",
                          text_size: "small",
                          padding: [10, 20, 10, 20],
                          text_align: TextAlign.center,
                          text_weight: "titre",
                          foreground_color: AppColors.dark,
                          border_radius_size: "normal",
                          background_color: AppColors.primary,
                        )
                      else if (step_index == 1)
                        AppButton(
                          onPressed: () {
                            controlsDetails.onStepContinue?.call();
                          },
                          child_type: "text",
                          force_height: 40,
                          disabled: loading_directions == true,
                          svg_image_size: "wx16",
                          text: "Paiement →",
                          text_size: "small",
                          padding: [10, 20, 10, 20],
                          text_align: TextAlign.center,
                          text_weight: "titre",
                          foreground_color: AppColors.dark,
                          border_radius_size: "normal",
                          background_color: AppColors.primary,
                        )
                      else if (step_index == 2)
                        AppButton(
                          onPressed: () {
                            Utils.log("commander");
                          },
                          child_type: "text",
                          force_height: 40,
                          svg_image_size: "wx16",
                          text: "Commander maintenant",
                          text_size: "small",
                          padding: [10, 20, 10, 20],
                          text_align: TextAlign.center,
                          text_weight: "titre",
                          foreground_color: AppColors.dark,
                          border_radius_size: "normal",
                          background_color: AppColors.primary,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.profile),
    );
  }

  void onPressed() {}
}
