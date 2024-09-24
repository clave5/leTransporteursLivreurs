// pages/repas.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/commande_livraison.dart';
import 'package:letransporteur_client/pages/commande_repas.dart';
import 'package:letransporteur_client/pages/commande_taxi.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_command_manage.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_no_command.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/other/repas_categorie_component.dart';
import 'package:letransporteur_client/widgets/component/repas/repas_search_component.dart';
import 'package:letransporteur_client/widgets/component/repas/single_repas_component.dart';
import 'package:letransporteur_client/widgets/component/repas/repas_list_component.dart';
import 'package:letransporteur_client/widgets/component/restaurant/single_restaurant_component.dart';
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
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_regular_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Repas extends StatefulWidget {
  final String? token;
  const Repas({super.key, this.token = ""});

  @override
  State<Repas> createState() => _RepasState();
}

class _RepasState extends State<Repas> {
  int step = 0;
  RangeValues current_prix_range_values = const RangeValues(1000, 2000);
  RangeValues current_note_range_values = const RangeValues(0, 5);

  var all_repas = [];
  var all_repas_filtered = [];
  var plat_display_ui = "prix";

  bool loading_repas_au_prix = false;
  bool loading_repas_au_note = false;

  late Future<void> repas_au_prix = Future<void>(() {});

  late Future<void> menu_restaurant = Future<void>(() {});

  @override
  void initState() {
    super.initState();
    initData();
    if (mounted) {
      setState(() {
        Utils.panier = {"repas": [], "boissons": [], "accomps": []};
      });
    }
  }

  void dispose() {
    if (repas_au_prix != null) repas_au_prix.ignore();
    if (menu_restaurant != null) menu_restaurant.ignore();
    super.dispose();
  }

  void initData() {
    Utils.log(widget.token);
    if (widget.token != null) {
      menu_restaurant = get_request(
        "${API_BASE_URL}/client/menu/restaurant/${Utils.get_current_location().toLowerCase()}", // API URL
        widget.token!,
        {}, // Query parameters (if any)
        (response) {
          Utils.log(response);
          if (mounted) {
            setState(() {
              Utils.repas_categories = response?["categories"];
              Utils.repas_restaurants = response?["restaurants"];
            });
          }
        },
        (error) {},
      );

      filter_repas_au_prix(
          current_prix_range_values.start, current_prix_range_values.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight.sp), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 0), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                children: [
                  LargeBoldText(
                      text: "Repas", color: Utils.colorToHex(AppColors.dark)),
                  Spacer(),
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
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Utils.location_good
            ? Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20.sp), // Set the radius here
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 10.sp),
                      child: Column(
                        children: [
                          RepasSearchComponent(),
                        ],
                      ),
                    ),
                  ),
                  Utils.repas_categories.isEmpty ||
                          loading_repas_au_note ||
                          loading_repas_au_prix
                      ? Column(
                          children: [
                            SizedBox(
                              height: 20.sp,
                            ),
                            loading_repas_component()
                          ],
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                              child: Container(
                            padding: EdgeInsets.all(0),
                            color: AppColors.gray7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                categories_repas(),
                                les_restaurants(),
                                les_plats(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 20.sp,
                                      bottom: 15.sp,
                                      left: 0,
                                      right: 0),
                                  child: Container(
                                    height: 1,
                                    width: double.infinity,
                                    color: AppColors.gray5,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                ],
              )
            : no_service_here_component(),
      ),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.accueil),
    );
  }

  void onPressed() {}

  categories_repas() {
    return Container(
      padding:
          EdgeInsets.only(top: 20.sp, bottom: 0, left: 35.sp, right: 35.sp),
      width: double.infinity,
      child: Column(
        children: [
          MediumTitreText(text: "Catégories"),
          SizedBox(
            height: 15.sp,
          ),
          Utils.repas_categories.isEmpty
              ? CircularProgressIndicator(
                  color: AppColors.primary,
                )
              : SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...Utils.repas_categories!.map((categorie) {
                        return Row(
                          children: [
                            RepasCategorieComponent(categorie: categorie),
                            SizedBox(
                              width: 20.sp,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  les_restaurants() {
    return Container(
      color: Colors.white,
      padding:
          EdgeInsets.only(top: 20.sp, bottom: 20.sp, left: 35.sp, right: 35.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MediumTitreText(
            text: "Les restaurants",
            color: Utils.colorToHex(AppColors.dark),
          ),
          SizedBox(
            height: 15.sp,
          ),
          Utils.repas_restaurants.isEmpty
              ? CircularProgressIndicator(
                  color: AppColors.primary,
                )
              : SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...Utils.repas_restaurants!.map((restaurant) {
                        int index = Utils.repas_restaurants.indexOf(restaurant);
                        if (index % 2 == 0) {
                          return Row(
                            children: [
                              Column(
                                children: [
                                  SingleRestaurantComponent(
                                      restaurant:
                                          Utils.repas_restaurants[index]),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Utils.repas_restaurants.length > index + 1
                                      ? SingleRestaurantComponent(
                                          restaurant: Utils
                                              .repas_restaurants[index + 1])
                                      : Container()
                                ],
                              ),
                              SizedBox(
                                width: 1.sp,
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      })
                    ],
                  ),
                )
        ],
      ),
    );
  }

  les_plats() {
    return Container(
      padding:
          EdgeInsets.only(top: 20.sp, bottom: 20.sp, left: 15.sp, right: 15.sp),
      width: double.infinity,
      child: Column(
        children: [
          MediumTitreText(text: "Les plats"),
          SizedBox(
            height: 15.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AppButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        plat_display_ui = "note";
                      });
                    }
                  },
                  child_type: "icon",
                  with_text: true,
                  icon: Icon(
                    Icons.star,
                    color: plat_display_ui == "note"
                        ? AppColors.primary
                        : AppColors.gray3,
                  ),
                  icon_size: "wx14",
                  text: "Mieux notés",
                  text_size: "small",
                  text_align: TextAlign.center,
                  text_weight: "titre",
                  foreground_color: AppColors.dark,
                  border_radius_size: "large",
                  border: [
                    plat_display_ui == "note"
                        ? AppColors.primary
                        : AppColors.gray3,
                    1.0,
                    BorderStyle.solid
                  ],
                  background_color: AppColors.transparent),
              AppButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        plat_display_ui = "prix";
                      });
                    }
                    filter_repas_au_prix(current_prix_range_values.start,
                        current_prix_range_values.end);
                  },
                  child_type: "icon",
                  with_text: true,
                  icon: Icon(
                    Icons.monetization_on_sharp,
                    color: plat_display_ui == "prix"
                        ? AppColors.primary
                        : AppColors.gray3,
                  ),
                  icon_size: "wx14",
                  text: "Filtrer au prix",
                  text_size: "small",
                  text_align: TextAlign.center,
                  text_weight: "titre",
                  foreground_color: AppColors.dark,
                  border_radius_size: "large",
                  border: [
                    plat_display_ui == "prix"
                        ? AppColors.primary
                        : AppColors.gray3,
                    1.0,
                    BorderStyle.solid
                  ],
                  background_color: AppColors.transparent)
            ],
          ),
          SizedBox(
            height: 15.sp,
          ),
          get_plat_display_ui()
        ],
      ),
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

  no_service_here_component() {
    return Container(
      padding: EdgeInsets.all(40.sp),
      child: Column(
        children: [
          Icon(
            Icons.restaurant,
            color: AppColors.gray5,
            size: 100.sp,
          ),
          SizedBox(
            height: 10,
          ),
          SmallLightText(
            textAlign: TextAlign.center,
            text:
                "Désolé, les services de livraison de repas ne sont pas disponibles dans votre localité.",
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

  filter_repas_au_prix(double start, double end) {
    if (mounted) {
      setState(() {
        loading_repas_au_prix = true;
      });
    }
    repas_au_prix = post_request(
        "$API_BASE_URL/client/repas/au/prix/${Utils.get_current_location().toLowerCase()}", // API URL
        Utils.TOKEN,
        {
          "prixA": start.floor(),
          "prixB": end.floor()
        }, // Query parameters (if any)
        (response) {
      Utils.log(response);
      if (mounted) {
        setState(() {
          all_repas_filtered = response["repasAuprix"];
          loading_repas_au_prix = false;
        });
      }
    }, (error) {}, null, context);
  }

  get_plat_display_ui() {
    switch (plat_display_ui) {
      case "note":
        return note_repas_display();
      case "prix":
        return prix_repas_display();
      default:
    }
  }

  prix_repas_display() {
    return Column(
      children: [
        RangeSlider(
          values: current_prix_range_values,
          max: 30000,
          divisions: 20,
          labels: RangeLabels(
            current_prix_range_values.start.round().toString(),
            current_prix_range_values.end.round().toString(),
          ),
          onChangeEnd: (RangeValues values) {
            if (mounted) {
              setState(() {
                current_prix_range_values = values;
                Utils.log(current_prix_range_values);
                filter_repas_au_prix(current_prix_range_values.start,
                    current_prix_range_values.end);
                /* all_repas_filtered = all_repas.where((repas) =>
                    repas["prix"] <= current_prix_range_values.end &&
                    repas["prix"] >= current_prix_range_values.start).toList(); */
              });
            }
          },
          onChanged: (RangeValues value) {},
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallRegularText(
                  text: "min: ${current_prix_range_values.start.toInt()}F"),
              SmallRegularText(
                  text: "max: ${current_prix_range_values.end.toInt()}F"),
            ],
          ),
        ),
        SizedBox(
          height: 25.sp,
        ),
        loading_repas_au_prix == true
            ? loading_repas_component()
            : (all_repas_filtered.isEmpty
                ? no_repas_component()
                : RepasListComponent(plats: all_repas_filtered))
      ],
    );
  }

  note_repas_display() {
    return Column(
      children: [
        RangeSlider(
          values: current_note_range_values,
          max: 5,
          min: 0,
          divisions: 10,
          labels: RangeLabels(
            current_note_range_values.start.toString(),
            current_note_range_values.end.toString(),
          ),
          onChanged: (RangeValues values) {
            if (mounted) {
              setState(() {
                current_note_range_values = values;
                Utils.log(current_note_range_values);
                /* filter_repas_au_note(
                  current_note_range_values.start, current_note_range_values.end); */
                all_repas_filtered = all_repas
                    .where((repas) =>
                        double.parse(repas["noteRepas"]) <=
                            current_note_range_values.end &&
                        double.parse(repas["noteRepas"]) >=
                            current_note_range_values.start)
                    .toList();
              });
            }
          },
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SmallRegularText(
                      text: current_note_range_values.start.toString()),
                  Icon(
                    Icons.star,
                    color: AppColors.gray2,
                    size: 18.sp,
                  )
                ],
              ),
              Row(
                children: [
                  SmallRegularText(
                      text: current_note_range_values.end.toString()),
                  Icon(
                    Icons.star,
                    color: AppColors.gray2,
                    size: 18.sp,
                  )
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 25.sp,
        ),
        loading_repas_au_note == true
            ? loading_repas_component()
            : (all_repas_filtered.isEmpty
                ? no_repas_component()
                : RepasListComponent(plats: all_repas_filtered))
      ],
    );
  }

  Future<void> _refresh() async {
    initData();
  }
}
