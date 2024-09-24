// pages/activites/activites.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/commande/activite_item_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Activites extends StatefulWidget {
  const Activites({super.key});

  @override
  State<Activites> createState() => _ActivitesState();
}

class _ActivitesState extends State<Activites> {
  List commande_categories = [];
  List commandes = [];

  var selected_category_id;

  FormGroup periode_form = FormGroup({
    'dateDebut': FormControl<String>(validators: []),
    'dateFin': FormControl<String>(validators: []),
  });

  bool loading_commandes = false;

  late Future<void> activite_periode_post = Future<void>(() {});

  late Future<void> type_commande_post = Future<void>(() {});

  late Future<void> client_activites_get = Future<void>(() {});

  @override
  void initState() {
    initData();
  }

  @override
  void dispose() {
    if (activite_periode_post != null) activite_periode_post.ignore();
    if (type_commande_post != null) type_commande_post.ignore();
    if (client_activites_get != null) client_activites_get.ignore();
    super.dispose();
  }

  Future<void> _refresh() async {
    initData();
  }

  void initData() {
    Utils.log(Utils.TOKEN);
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
    update_commande_list("all");

    periode_form.valueChanges.listen((element) {
      Utils.log(periode_form.rawValue);
      if (periode_form.rawValue["dateDebut"] != null &&
          periode_form.rawValue["dateFin"] != null) {
        if (mounted) {
          setState(() {
            loading_commandes = true;
          });
        }
        activite_periode_post = post_request(
            "$API_BASE_URL/client/activites/periode", // API URL
            Utils.TOKEN,
            {
              "client_id": Utils.client["client_id"],
              "dateDebut": periode_form.rawValue["dateDebut"],
              "dateFin": periode_form.rawValue["dateFin"],
            }, // Query parameters (if any)
            (response) {
          Utils.log(response);
          if (mounted) {
            setState(() {
              commandes = response["data"];
              loading_commandes = false;
            });
          }
        }, (error) {
Utils.show_toast(context, error);          if (mounted) {
            setState(() {
              loading_commandes = false;
            });
          }
        }, null, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var isSelected = [false, false, false, false, false];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight.sp), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 0), // Add bottom padding
          child: AppBar(
            title: Container(
                child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LargeBoldText(
                        text: "Activités",
                        color: Utils.colorToHex(AppColors.dark)),
                    RouterButton(
                      destination: Notifications(),
                      child_type: "svgimage",
                      svg_image_size: "wx25",
                      svg_path: "assets/SVG/notif-unread.svg",
                    ),
                  ],
                ),
              ],
            )),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(0), // Set the radius here
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
            child: Container(
          width: double.infinity,
          transform: Matrix4.translationValues(0, -10.sp, 0),
          padding: EdgeInsets.all(0),
          color: AppColors.gray7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 10.sp),
                      child: commandes_filters()),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              loading_commandes ? Container() : date_filter(),
              SizedBox(
                height: 5.sp,
              ),
              Container(
                  child: loading_commandes
                      ? loading_commandes_component()
                      : (filtered_commandes_list(commandes)!.isEmpty
                          ? no_commandes_component()
                          : commandes_widgets_list(
                              filtered_commandes_list(commandes))))
            ],
          ),
        )),
      ),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.activites),
    );
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
            height: 100,
            width: 100,
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

  no_commandes_component() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 40.sp,
          ),
          SvgPicture.asset(
            "assets/SVG/activite-menu-stroke-icon.svg",
            height: 100,
            width: 100,
            fit: BoxFit.contain,
            color: AppColors.gray5,
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.sp),
            child: SmallLightText(
              textAlign: TextAlign.center,
              text:
                  "Vous n'avez encore effectué aucune activité pour le moment.",
              color: Utils.colorToHex(AppColors.gray3),
            ),
          )
        ],
      ),
    );
  }

  commandes_widgets_list(List filtered_commandes_list) {
    return Column(
      children: [
        ...filtered_commandes_list.map((c) => Column(
              children: [
                SizedBox(
                  height: 20.sp,
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: ActiviteItemComponent(commande: c, mode: "full")),
                SizedBox(
                  height: 30.sp,
                ),
                Container(
                  color: AppColors.gray5,
                  height: 1,
                )
              ],
            ))
      ],
    );
  }

  date_filter() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmallBoldText(text: "Sélectionnez une période"),
          SizedBox(
            height: 10,
          ),
          ReactiveForm(
              formGroup: periode_form,
              child: Row(
                children: [
                  SizedBox(
                    height: 50.sp,
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: ReactiveDatePicker(
                      formControlName: 'dateDebut',
                      builder: (context, picker, child) {
                        return ReactiveTextField(
                          readOnly: true,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                'La date de début est requise',
                            'field_validation': (error) => error as String,
                          },
                          onTap: (control) => {picker.showPicker()},
                          formControlName: 'dateDebut',
                          decoration: Utils.get_default_input_decoration_normal(
                                  periode_form.control('dateDebut'),
                                  false,
                                  'Date de début',
                                  {
                                    "icon": Icons.calendar_today_rounded,
                                    "size": 24.sp
                                  },
                                  null,
                                  AppColors.gray5)
                              .copyWith(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10.sp)),
                          style: Utils.small_bold_text_style,
                        );
                      },
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    ),
                  ),
                  SizedBox(
                    width: 10.sp,
                  ),
                  SizedBox(
                    height: 50.sp,
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: ReactiveDatePicker(
                      formControlName: 'dateFin',
                      builder: (context, picker, child) {
                        return ReactiveTextField(
                          readOnly: true,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                'La date de fin est requise',
                            'field_validation': (error) => error as String,
                          },
                          onTap: (control) => {picker.showPicker()},
                          formControlName: 'dateFin',
                          decoration: Utils.get_default_input_decoration_normal(
                                  periode_form.control('dateDebut'),
                                  false,
                                  'Date de fin',
                                  {
                                    "icon": Icons.calendar_today_rounded,
                                    "size": 24.sp
                                  },
                                  null,
                                  AppColors.gray5)
                              .copyWith(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10.sp)),
                          style: Utils.small_bold_text_style,
                        );
                      },
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  commandes_filters() {
    return GroupButton(
      buttons: get_comande_categories_labels(),
      onSelected: (value, index, isSelected) {
        update_commandes_list_from_category(value);
      },
      buttonBuilder: (selected, categorie, context) {
        return Container(
          decoration: BoxDecoration(
              color: selected == true ? Colors.white : AppColors.primary_light,
              border: selected == true
                  ? null
                  : Border.all(width: 1.0, color: AppColors.primary_light),
              borderRadius: BorderRadius.circular(100.sp)),
          padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 20.sp),
          child: Row(
            children: [
              categorie == "all"
                  ? Container(
                      height: 40.sp,
                    )
                  : Row(
                      children: [
                        Icon(get_categorie_by_code(categorie, null)?["icon"]),
                      ],
                    ),
              SizedBox(
                width: 10.sp,
              ),
              SmallTitreText(
                  text: categorie == "all"
                      ? "Tout"
                      : (commande_categories.isEmpty
                          ? categorie
                          : get_categorie_by_code(
                              categorie, null)?["libelle"])),
            ],
          ),
        );
      },
    );
  }

  get_categorie_by_code(categorie, dynamic? field) {
    var firstWhere = commande_categories.firstWhere(
        (element) =>
            categorie == (field != null ? element[field] : element?["code"]),
        orElse: () => {});
    //Utils.log((categorie, field, firstWhere));
    return firstWhere;
  }

  get_comande_categories_labels() {
    return ["all", ...commande_categories.map((c) => c["code"])];
  }

  List filtered_commandes_list(var commandes_list) {
    var filtered_commandes = [];
    commandes_list.forEach((commande) {
      commande["icon"] =
          get_categorie_by_code(commande["type_commande_id"], "id")?["icon"];
      if (selected_category_id != null) {
        if (commande["type_commande_id"] == selected_category_id) {
          filtered_commandes.add(commande);
        }
      } else {
        filtered_commandes.add(commande);
      }
    });
    return filtered_commandes;
  }

  update_commandes_list_from_category(categorie) {
    if (mounted) {
      setState(() {
        selected_category_id = categorie == "all"
            ? null
            : get_categorie_by_code(categorie, null)?["id"];
      });
    }
    update_commande_list(selected_category_id);
  }

  update_commande_list(selected_category_id) {
    if (mounted) {
      setState(() {
        loading_commandes = true;
      });
    }
    Utils.log(selected_category_id);
    if (selected_category_id == "all" || selected_category_id == null) {
      client_activites_get = get_request(
        "$API_BASE_URL/client/activites/${Utils.client["client_id"]}", // API URL
        Utils.TOKEN,
        {}, // Query parameters (if any)
        (response) {
          Utils.log(response);
          if (mounted) {
            setState(() {
              loading_commandes = false;
              commandes = response["data"];
            });
          }
        },
        (error) {
Utils.show_toast(context, error);          if (mounted) if (mounted) {
            setState(() {
              loading_commandes = false;
            });
          }
        },
      );
    } else {
      type_commande_post = post_request(
          "$API_BASE_URL/client/activites/type/commande", // API URL
          Utils.TOKEN,
          {
            "client_id": Utils.client["client_id"],
            "type": get_categorie_by_code(selected_category_id, "id")?["code"]
          }, // Query parameters (if any)
          (response) {
        Utils.log(response);
        if (mounted) {
          setState(() {
            commandes = response["data"];
            loading_commandes = false;
          });
        }
      }, (error) {
Utils.show_toast(context, error);        if (mounted) {
          setState(() {
            loading_commandes = false;
          });
        }
      }, null, context);
    }
  }

  void onPressed() {}
}
