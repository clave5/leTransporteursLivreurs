// widgets/component/repas/repas_search_component.dart
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
import 'package:letransporteur_client/widgets/component/input/custom_reactive_text_filed_component.dart';
import 'package:letransporteur_client/widgets/component/repas/single_repas_component.dart';
import 'package:letransporteur_client/widgets/page/repas/repas_picker_page.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rxdart/rxdart.dart';

class RepasSearchComponent extends StatefulWidget {
  String? parent;
  RepasSearchComponent({super.key, this.parent});

  @override
  State<RepasSearchComponent> createState() => _RepasSearchComponentState();
}

class _RepasSearchComponentState extends State<RepasSearchComponent> {
  FormGroup search_form = FormGroup({
    'search': FormControl<String>(validators: []),
  });

  bool plat_loading = false;

  late Future<void> search_repas = Future<void>(() {});

  @override
  void dispose() {
    if (search_repas != null) search_repas.ignore();
    super.dispose();
  }

  @override
  void initState() {
    search_form
        .control('search')
        .valueChanges
        .debounceTime(Duration(milliseconds: 1000))
        .listen((value) {
      if ((value as String).length < 3) return;
      search_repas = get_request(
        "${API_BASE_URL}/client/search/repas/${value}/${Utils.get_current_location().toLowerCase()}", // API URL
        Utils.TOKEN,
        {}, // Query parameters (if any)
        (response) {
          Utils.log(response);
          if (mounted) {
            setState(() {
              plat_loading = true;
              var repas_map = response?["repas"];
              repas_map ??= response["repasRestaurant"];
              var repas_list = repas_map.map((repa) {
                return {
                  "categorie_id": repa["categorie_id"],
                  "intitule": repa["restaurant"],
                  "id": repa["repas_id"],
                  "libelle": repa["libelle"],
                  "fullUrlPhoto": repa["fullUrlPhoto"] ?? repa["photo"],
                  "prix": repa["prix"],
                  "restaurant_id": repa["restaurant_id"],
                  "noteRepas": repa["moyenneNote"],
                };
              }).toList();

              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RepasPickerPage(
                      repas_list: repas_list,
                      widget_title: "Recherche",
                      show_filters: true,
                      search: value)));
            });
          }
        },
        (error) {
Utils.show_toast(context, error);          if (mounted) {
            setState(() {
              plat_loading = false;
            });
          }
        },
      );

      // Perform your search operation here
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Utils.log(widget.fullUrlPhoto);

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 25, right: 25),
      child: ReactiveForm(
          formGroup: search_form,
          child: Column(
            children: [
              Container(
                child: ReactiveTextField(
                  formControlName: 'search',
                  style: TextStyle(fontSize: 10),
                  decoration: Utils.get_default_input_decoration_normal(
                      search_form.control('search'),
                      false,
                      'Rechercher un plat...',
                      {"icon": Icons.search, "size": 24.sp},
                      null,
                      null),
                ),
              )
            ],
          )),
    );
  }
}
