// widgets/page/repas/repas_picker_page.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/commande_repas.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/repas/single_repas_component.dart';
import 'package:letransporteur_client/widgets/component/repas/repas_list_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rxdart/rxdart.dart';

class RepasPickerPage extends StatefulWidget {
  List<dynamic> repas_list = [];
  List<dynamic>? repas_categories = [];
  String widget_title = "Repas";
  bool? require_request_plats = false;
  int? restaurant_id;
  String? search;
  bool show_filters = false;
  RepasPickerPage(
      {super.key,
      required this.repas_list,
      required this.widget_title,
      required this.show_filters,
      this.restaurant_id,
      this.search,
      this.repas_categories,
      this.require_request_plats});

  @override
  State<RepasPickerPage> createState() => _RepasPickerPageState();
}

class _RepasPickerPageState extends State<RepasPickerPage> {
  bool plat_loading = false;

  var selected_category_id;
  FormGroup search_form = FormGroup({
    'search': FormControl<String>(validators: []),
  });

  late Future<void> repas_restaurant_get = Future<void>(() {});

  late Future<void> search_repas_get = Future<void>(() {});

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() {
    search_form
        .control('search')
        .valueChanges
        .debounceTime(Duration(milliseconds: 1000))
        .listen((value) {
      fetch_plats(value);
      // Perform your search operation here
    });
    if (widget.search != null) {
      search_form.patchValue({"search": widget.search});
    }

    /* Utils.log(
      widget.repas_list,
    ); */

    if (widget.require_request_plats == true) {
      if (widget.restaurant_id != null) {
        if (mounted) {
          setState(() {
            plat_loading = true;
          });
        }
        repas_restaurant_get = get_request(
          "${API_BASE_URL}/client/repas/restaurant/${widget.restaurant_id}", // API URL
          Utils.TOKEN,
          {}, // Query parameters (if any)
          (response) {
            Utils.log(response);
            if (mounted) {
              setState(() {
                plat_loading = true;
                widget.repas_categories = response?["categorieRepas"];
                widget.repas_list = response?["repasRestaurant"].map((repa) {
                  return {
                    "categorie_id": repa["categorie_id"],
                    "intitule": repa["restaurant"],
                    "id": repa["repas_id"],
                    "libelle": repa["libelle"],
                    "fullUrlPhoto": repa["fullUrlPhoto"],
                    "restaurant_fermer": repa["restaurant_fermer"],
                    "prix": repa["prix"],
                    "restaurant_id": repa["restaurant_id"],
                    "noteRepas": repa["moyenneNote"],
                  };
                }).toList();
              });
            }
          },
          (error) {
Utils.show_toast(context, error);            if (mounted) {
              setState(() {
                plat_loading = false;
              });
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils.log(widget.repas_categories);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight.sp), // Adjust height as needed

        child: Padding(
          padding: EdgeInsets.only(bottom: 0), // Add bottom padding
          child: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Set the radius here
              ),
            ),
            title: Container(
              child: Row(
                children: [
                  LargeBoldText(
                      text: widget.widget_title,
                      color: Utils.colorToHex(AppColors.dark)),
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
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.only(top: 0),
        color: AppColors.gray7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 15.sp,
            ),
            widget.restaurant_id != null
                ? SingleChildScrollView(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    child: GroupButton(
                      buttons: get_plats_categories(),
                      onSelected: (value, index, isSelected) {
                        update_repas_list_from_category(index);
                      },
                      buttonBuilder: (selected, categorie, context) {
                        return Container(
                          decoration: BoxDecoration(
                              color: selected == true
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: selected == true
                                  ? null
                                  : Border.all(
                                      width: 1.0, color: AppColors.primary),
                              borderRadius: BorderRadius.circular(100)),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.sp, horizontal: 20.sp),
                          child: SmallBoldText(text: categorie as String),
                        );
                      },
                    ))
                : Container(),
            widget.search != null ? search_widget() : Container(),
            SizedBox(
              height: 25.sp,
            ),
            RepasListComponent(
              plats: filtered_repas_list(widget.repas_list),
              restaurant_id: widget.restaurant_id,
              plat_loading: plat_loading,
              require_request_plats: widget.require_request_plats,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 15, left: 0, right: 0),
              child: Container(
                height: 1,
                width: double.infinity,
                color: AppColors.gray5,
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.accueil),
    );
  }

  search_widget() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 5, left: 25, right: 25),
      child: ReactiveForm(
          formGroup: search_form,
          child: Column(
            children: [
              ReactiveTextField(
                formControlName: 'search',
                decoration: Utils.get_default_input_decoration_normal(
                    search_form.control('search'),
                    false,
                    'Rechercher un plat...',
                    {"icon": Icons.search, "size": 24.sp},
                    null,
                    null),
              )
            ],
          )),
    );
  }

  get_plats_categories() {
    var plats_categories = ["Tout"];
    widget.repas_categories?.forEach((cat) {
      plats_categories.add(cat["categorieRepas"]);
    });
    if (mounted) {
      setState(() {
        // selected_category_id = widget.repas_categories?[0]?["categorie_id"];
      });
    }
    return plats_categories;
  }

  filtered_repas_list(var repas_list) {
    var filtered_repas = [];
    repas_list.forEach((repas) {
      Utils.log((selected_category_id, repas));
      if (selected_category_id != null) {
        if (repas["categorie_id"] == selected_category_id) {
          filtered_repas.add(repas);
        }
      } else {
        filtered_repas.add(repas);
      }
    });
    return filtered_repas;
  }

  update_repas_list_from_category(int category_index) {
    if (mounted) {
      setState(() {
        selected_category_id = category_index == 0
            ? null
            : widget.repas_categories?[category_index - 1]["categorie_id"];
      });
    }
  }

  void fetch_plats(value) {
    search_repas_get = get_request(
      "${API_BASE_URL}/client/search/repas/${value}/${Utils.get_current_location().toLowerCase()}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        if (mounted) {
          setState(() {
            plat_loading = true;
            widget.repas_categories = response?["categorieRepas"];
            widget.repas_list = response?["repasRestaurant"].map((repa) {
              return {
                "categorie_id": repa["categorie_id"],
                "intitule": repa["restaurant"],
                "id": repa["repas_id"],
                "libelle": repa["libelle"],
                "fullUrlPhoto": repa["fullUrlPhoto"],
                "prix": repa["prix"],
                "restaurant_id": repa["restaurant_id"],
                "noteRepas": repa["moyenneNote"],
              };
            }).toList();
          });
        }
      },
      (error) {
Utils.show_toast(context, error);        if (mounted) {
          setState(() {
            plat_loading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if (repas_restaurant_get != null) repas_restaurant_get.ignore();
    if (search_repas_get != null) search_repas_get.ignore();
    super.dispose();
  }

  Future<void> _refresh() async {
    initData();
  }
}
