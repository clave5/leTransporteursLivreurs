// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/commande_livraison.dart';
import 'package:letransporteur_client/pages/commande_repas.dart';
import 'package:letransporteur_client/pages/commande_taxi.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_command_manage.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_no_command.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/other/categorie_component.dart';
import 'package:letransporteur_client/widgets/component/repas/plat_component.dart';
import 'package:letransporteur_client/widgets/component/repas/restaurant_component.dart';
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
  RangeValues current_range_values = const RangeValues(40, 80);
  FormGroup search_form = FormGroup({
    'search': FormControl<String>(validators: []),
  });

  @override
  void initState() {
    Utils.log(widget.token);
    if (widget.token != null) {
      get_request(
        "${API_BASE_URL}/client/menu/restaurant", // API URL
        widget.token!,
        {}, // Query parameters (if any)
        (response) {
          Utils.log(response);
          setState(() {});
        },
        (error) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight), // Adjust height as needed
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Set the radius here
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [search_widget()],
              ),
            ),
          ),
          Expanded(
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
                    padding:
                        EdgeInsets.only(top: 20, bottom: 15, left: 0, right: 0),
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
      ),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.accueil),
    );
  }

  void onPressed() {}

  categories_repas() {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 0, left: 35, right: 35),
      width: double.infinity,
      child: Column(
        children: [
          MediumTitreText(text: "Catégories"),
          SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategorieComponent(),
                SizedBox(
                  width: 20,
                ),
                CategorieComponent(),
                SizedBox(
                  width: 20,
                ),
                CategorieComponent(),
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
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 35, right: 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MediumTitreText(
            text: "Les restaurants",
            color: Utils.colorToHex(AppColors.dark),
          ),
          SizedBox(
            height: 15,
          ),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  children: [
                    RestaurantComponent(),
                    SizedBox(
                      height: 10,
                    ),
                    RestaurantComponent(),
                  ],
                ),
                SizedBox(
                  width: 1,
                ),
                Column(
                  children: [
                    RestaurantComponent(),
                    SizedBox(
                      height: 10,
                    ),
                    RestaurantComponent(),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  les_plats() {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
      width: double.infinity,
      child: Column(
        children: [
          MediumTitreText(text: "Les plats"),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AppButton(
                  onPressed: () {},
                  child_type: "icon",
                  with_text: true,
                  icon: Icon(
                    Icons.star,
                    color: AppColors.gray3,
                  ),
                  icon_size: "wx14",
                  text: "Mieux notés",
                  text_size: "small",
                  text_align: TextAlign.center,
                  text_weight: "titre",
                  foreground_color: AppColors.dark,
                  border_radius_size: "large",
                  border: [AppColors.gray4, 1.0, BorderStyle.solid],
                  background_color: AppColors.transparent),
              AppButton(
                  onPressed: () {},
                  child_type: "icon",
                  with_text: true,
                  icon: Icon(
                    Icons.monetization_on_sharp,
                    color: AppColors.primary,
                  ),
                  icon_size: "wx14",
                  text: "Filtrer au prix",
                  text_size: "small",
                  text_align: TextAlign.center,
                  text_weight: "titre",
                  foreground_color: AppColors.dark,
                  border_radius_size: "large",
                  border: [AppColors.primary, 1.0, BorderStyle.solid],
                  background_color: AppColors.transparent)
            ],
          ),
          SizedBox(
            height: 15,
          ),
          RangeSlider(
            values: current_range_values,
            max: 100,
            divisions: 5,
            labels: RangeLabels(
              current_range_values.start.round().toString(),
              current_range_values.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                current_range_values = values;
              });
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmallRegularText(
                    text: "min: ${current_range_values.start.toInt()}F"),
                SmallRegularText(
                    text: "max: ${current_range_values.end.toInt()}F"),
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Wrap(
            direction: Axis.horizontal,
            spacing: 15,
            runSpacing: 25,
            children: [
              PlatComponent(),
              PlatComponent(),
              PlatComponent(),
              PlatComponent(),
              PlatComponent(),
              PlatComponent(),
              PlatComponent(),
            ],
          )
        ],
      ),
    );
  }

  search_widget() {
    return Padding(
      padding: EdgeInsets.only(top: 0, bottom: 12, left: 25, right: 25),
      child: ReactiveForm(
          formGroup: search_form,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: ReactiveTextField(
                  formControlName: 'search',
                  decoration: Utils.get_default_input_decoration(
                      'Rechercher un restaurant, plat, etc.',
                      Icons.search,
                      Colors.white,
                      null),
                ),
              )
            ],
          )),
    );
  }
}
