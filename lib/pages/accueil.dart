// pages/accueil.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/commande_livraison.dart';
import 'package:letransporteur_client/pages/commande_taxi.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/pages/profile/parrainages.dart';
import 'package:letransporteur_client/pages/repas.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_command_manage.dart';
import 'package:letransporteur_client/widgets/component/accueil/accueil_no_command.dart';
import 'package:letransporteur_client/widgets/component/accueil/parrainage_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/repas/repas_search_component.dart';
import 'package:letransporteur_client/widgets/component/repas/single_repas_component.dart';
import 'package:letransporteur_client/widgets/page/repas/repas_picker_page.dart';
import 'package:letransporteur_client/widgets/select/app_select.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/big/big_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_light_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class Accueil extends StatefulWidget {
  final String? token;
  const Accueil({super.key, this.token = ""});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int step = 0;

  List all_repas = [];

  var big_data = {};

  bool loading_repas = false;

  bool plat_loading = false;

  late Future<void> client_index_get = Future<void>(() {});

  late Future<void> repas_au_prix_post = Future<void>(() {});

  var meilleurs_repas = [];

  get_command_component() {
    Widget command_component;
    switch (step) {
      case 0:
        command_component = AccueilNoComandComponent();
        break;
      default:
        command_component = AccueilComandManageComponent(step: step);
        break;
    }
    return command_component;
  }

  @override
  void dispose() {
    if (client_index_get != null) client_index_get.ignore();
    if (repas_au_prix_post != null) repas_au_prix_post.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
  }

  Future<void> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      showSnackBarMessage('Les autorisations de localisation sont refusées');
      showLocatePermissionDialog();
    } else if (permission == LocationPermission.deniedForever) {
      showSnackBarMessage(
          "Les autorisations de localisation sont définitivement refusées.");
      showLocatePermissionDialog();
    } else {
      proceedGetCurrentLocation();
    }
  }

  Future<void> proceedGetCurrentLocation() async {
    setState(() {
      loading_repas = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showSnackBarMessage('Les autorisations de localisation sont refusées');
        showLocatePermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showSnackBarMessage(
          "Les autorisations de localisation sont définitivement refusées.");
      showLocatePermissionDialog();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      Utils.log(position);
      fetch_geo_data_from_latlong(position.latitude, position.longitude);
    } catch (e) {
      showLocatePermissionDialog();
    } finally {
      if (mounted) {
        setState(() {
          loading_repas = false;
        });
      }
    }
  }

  void showLocatePermissionDialog() {
    setState(() {
      loading_repas = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_pin, size: 50, color: Colors.green.shade700),
              SizedBox(width: 10),
              MediumBoldText(
                text: "Permission de localisation",
                color: Utils.colorToHex(Colors.green.shade700),
              ),
            ],
          ),
          content: SmallRegularText(
            text:
                "L'application utilise les données de géolocalisation pour déterminer les emplacements de vos restaurants et vous permettre de suivre vos courses.",
          ),
          actions: <Widget>[
            TextButton(
              child: SmallRegularText(text: "Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: SmallBoldText(
                text: "Oui, autoriser →",
                color: Utils.colorToHex(Colors.green.shade700),
              ),
              onPressed: () {
                setState(() {
                  loading_repas = true;
                });
                Navigator.of(context).pop();
                proceedGetCurrentLocation();
              },
            ),
          ],
        );
      },
    );
  }

  void showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary_light,
        content: SmallBoldText(text: message),
      ),
    );
  }

  Future<void> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      showSnackBarMessage(
          'Les services de localisation sont désactivés. Veuillez activer les services.');
      showLocatePermissionDialog();
    }
  }

  void fetch_geo_data_from_latlong(double latitude, double longitude) {
    if (mounted) {
      setState(() {
        loading_repas = true;
      });
    }
    String url = get_latlong_to_geodata_url(latitude, longitude);
    //Utils.log('fetching $url');
    try {
      http.get(Uri.parse(url)).then((response) {
        if (mounted) {
          setState(() {
            loading_repas = true;
          });
        }
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          Utils.log('retrieved data');
          Utils.log(data);
          setState(() {
            loading_repas = false;
            Utils.current_location = data["features"][0]["properties"]["name"];
          });
          initData();
        } else {
          if (mounted) {
            setState(() {
              loading_repas = false;
            });
          }
          //Utils.log_error(json.decode(response.body));
        }
      });
    } on Exception catch (e) {
      //Utils.log(e.toString());
      if (mounted) {
        setState(() {
          loading_repas = false;
        });
      }
    }
  }

  void initData() {
    Utils.log(Utils.TOKEN);
    if (mounted) {
      setState(() {
        Utils.panier = {"repas": [], "boissons": [], "accomps": []};
        loading_repas = true;
      });
    }

    client_index_get = get_request(
      "$API_BASE_URL/client/index/${Utils.get_current_location().toLowerCase()}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        //Utils.log(response);

        if (mounted) {
          setState(() {
            Utils.big_data = response;
            Utils.client = Utils.big_data?["infoClient"];
            meilleurs_repas = Utils.big_data?["meilleureRepas"];
          });
        }
        if (mounted) {
          setState(() {
            loading_repas = false;
          });
        }
      },
      (error) {
        Utils.show_toast(context, error); //Utils.log(error);

        if (mounted) {
          setState(() {
            loading_repas = false;
          });
        }
      },
    );

    client_index_get = get_request(
      "$API_BASE_URL/auth/app/authorize/${Utils.get_current_location().toLowerCase()}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        // Utils.log(response);

        if (mounted) {
          setState(() {
            Utils.location_good = response["status"];
          });
        }
      },
      (error) {
        Utils.show_toast(context, error);
        Utils.removeAccessToken().then((value) {
          SystemNavigator.pop();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading_repas && Utils.big_data?["nbreCommandeEncour"] == null
        ? interstitial_loading_component()
        : Scaffold(
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
                            text: "Le Transporteur",
                            color: Utils.colorToHex(AppColors.dark)),
                        Spacer(),
                        RouterButton(
                          destination: Activites(),
                          child_type: "svgimage",
                          svg_image_size: "wx16",
                          border: [AppColors.primary, 1.5, BorderStyle.solid],
                          force_height: 40.sp,
                          padding: [0, 0, 0, 0],
                          text:
                              "${Utils.big_data?["nbreCommandeEncour"] ?? "0"}",
                          svg_path: "assets/SVG/encours-activite-icon-dark.svg",
                          foreground_color: AppColors.dark,
                          with_text: true,
                          text_size: "normal",
                          text_weight: "bold",
                          border_radius_size: "normal",
                          background_color: AppColors.primary.withOpacity(0.5),
                        ),
                        RouterButton(
                          destination: Notifications(),
                          child_type: "svgimage",
                          svg_image_size: "wx25",
                          svg_path: "assets/SVG/notif-unread.svg",
                        ),
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
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                  child: Container(
                padding: EdgeInsets.all(0),
                color: AppColors.gray7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RepasSearchComponent(),
                    que_desirez_vous_widget(),
                    repeter_dernieres_commandes(),
                    flash_news(),
                    parrainage(),
                    recommandation_repas(),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.sp, bottom: 15.sp, left: 0, right: 0),
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
            bottomNavigationBar:
                AppBottomNavBarComponent(active: BottomNavPage.accueil),
          );
  }

  interstitial_loading_component() {
    return Container(
        color: Colors.white,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2 - 70,
              ),
              SvgPicture.asset(
                "assets/SVG/logo-lt-horizontal-dark.svg",
                height: 70,
                width: 70,
                fit: BoxFit.contain,
              ),
              SizedBox(
                height: 30.sp,
              ),
              MediumLightText(
                text: "Chargement...",
              )
            ],
          ),
        ));
  }

  void onPressed() {}

  que_desirez_vous_widget() {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 25, left: 35, right: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LargeTitreText(
              text: "Que désirez-vous aujourdhui ?",
              color: Utils.colorToHex(AppColors.dark),
            ),
            SizedBox(
              height: 15.sp,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    RouterButton(
                      destination: CommandeLivraison(),
                      child_type: "image",
                      image_size: "wx35",
                      force_height: 60,
                      text: "Livraison",
                      image_path: "assets/img/livraison-image.png",
                      foreground_color: AppColors.dark,
                      with_text: true,
                      text_size: "normal",
                      text_weight: "bold",
                      border: [AppColors.primary, 1.5, BorderStyle.solid],
                      border_radius_size: "normal",
                      background_color: Colors.white,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RouterButton(
                      destination: CommandeTaxi(),
                      child_type: "image",
                      image_size: "wx35",
                      force_height: 60,
                      text: "Taxi privé",
                      image_path: "assets/img/taxi-image.png",
                      foreground_color: AppColors.dark,
                      with_text: true,
                      text_size: "normal",
                      text_weight: "bold",
                      border: [AppColors.primary, 1.5, BorderStyle.solid],
                      border_radius_size: "normal",
                      background_color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(
                  width: 10.sp,
                ),
                RouterButton(
                  destination: Repas(
                    token: Utils.TOKEN,
                  ),
                  child_type: "image",
                  image_size: "wx65",
                  orientation: "vertical",
                  force_height: 130,
                  text: "Restaurants",
                  image_path: "assets/img/repas-image.png",
                  foreground_color: AppColors.dark,
                  with_text: true,
                  text_size: "normal",
                  text_weight: "bold",
                  border: [AppColors.primary, 1.5, BorderStyle.solid],
                  border_radius_size: "normal",
                  background_color: Colors.white,
                ),
              ],
            ),
          ],
        ));
  }

  repeter_dernieres_commandes() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.only(top: 20, bottom: 20, left: 35, right: 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LargeTitreText(
            text: "Répéter vos dernières commandes",
            color: Utils.colorToHex(AppColors.dark),
          ),
          SizedBox(
            height: 15.sp,
          ),
          Utils.big_data?["derniereCommande"] == null ||
                  (Utils.big_data?["derniereCommande"] != null &&
                      (Utils.big_data["derniereCommande"] as List).isEmpty)
              ? SmallRegularText(
                  text: "Vous n'avez pas encore effectué de commande.")
              : SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...Utils.big_data?["derniereCommande"].map((commande) {
                        return Row(
                          children: [
                            Container(
                              width: 220.sp,
                              decoration: BoxDecoration(
                                boxShadow: [],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.sp),
                                            topRight: Radius.circular(10.sp))),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.sp, horizontal: 20.sp),
                                    child: SmallBoldText(
                                      text: commande["typecommande"] ==
                                              "Restaurant"
                                          ? "Repas"
                                          : commande["typecommande"],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.sp, vertical: 15.sp),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: AppColors.primary),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15.sp),
                                            bottomRight:
                                                Radius.circular(10.sp))),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          commande["typecommande"] ==
                                                  "Restaurant"
                                              ? Icons.restaurant_outlined
                                              : Icons.location_pin,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(
                                          width: 25.sp,
                                        ),
                                        Flexible(
                                          child: SmallBoldText(
                                            text: commande["typecommande"] ==
                                                    "Restaurant"
                                                ? (commande["repas_liste"]
                                                                as String)
                                                            .length >
                                                        30
                                                    ? "${(commande["repas_liste"] as String).substring(0, 30)}..."
                                                    : commande["repas_liste"]
                                                : (commande["lieuLivraison"]
                                                                as String)
                                                            .length >
                                                        30
                                                    ? "${(commande["lieuLivraison"] as String).substring(0, 30)}..."
                                                    : commande["lieuLivraison"],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
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

  flash_news() {
    return Utils.big_data?["falshNew"] == null ||
            (Utils.big_data?["falshNew"] != null &&
                (Utils.big_data["falshNew"] as List).isEmpty)
        ? Container()
        : Container(
            constraints: BoxConstraints(maxHeight: 220.sp),
            padding: EdgeInsets.only(
                top: 20.sp, bottom: 20.sp, left: 35.sp, right: 35.sp),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  ...(Utils.big_data["falshNew"] as List).map((flash) {
                    return Row(
                      children: [
                        Container(
                          width: 280.sp,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.sp, horizontal: 25.sp),
                          decoration: BoxDecoration(
                            boxShadow: [],
                            color: Colors.black,
                            image: DecorationImage(
                              opacity: 0.4,
                              image: NetworkImage(flash[
                                  "fullUrlbanniere"]), // Replace with your image URL
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(20.sp),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MediumTitreText(
                                  text: flash["titre"],
                                  color: Utils.colorToHex(Colors.white)),
                              XSmallBoldText(
                                  color: Utils.colorToHex(Colors.white),
                                  text: flash["miniDescription"]),
                              SizedBox(
                                height: 10.sp,
                              ),
                              IntrinsicWidth(
                                child: RouterButton(
                                    destination: get_flash_destination(
                                        flash["destination"]),
                                    child_type: "svgimage",
                                    svg_image_size: "wx16",
                                    force_height: 55.sp,
                                    with_text: true,
                                    flex_reverse: true,
                                    text: flash["textButton"],
                                    text_size: "small",
                                    text_align: TextAlign.left,
                                    text_weight: "bold",
                                    padding: [0, 0, 0, 0],
                                    svg_path:
                                        "assets/SVG/caret-yellow-white.svg",
                                    foreground_color: Colors.white,
                                    border_radius_size: "normal",
                                    background_color: Colors.transparent),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20.sp,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ));
  }

  parrainage() {
    return Utils.big_data?["infoClient"] == null
        ? Container()
        : ParrainageComponent(info_client: Utils.big_data?["infoClient"]);
  }

  recommandation_repas() {
    return Container(
      padding:
          EdgeInsets.only(top: 20.sp, bottom: 20.sp, left: 35.sp, right: 35.sp),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MediumTitreText(text: "Recommandations de repas"),
              RouterButton(
                  destination: Repas(),
                  child_type: "svgimage",
                  svg_image_size: "wx16",
                  force_height: 55.sp,
                  with_text: true,
                  flex_reverse: true,
                  text: "voir plus",
                  text_size: "small",
                  text_align: TextAlign.left,
                  text_weight: "bold",
                  padding: [0, 0, 0, 0],
                  conserve_svg_image_color: true,
                  svg_path: "assets/SVG/caret-yellow-dark.svg",
                  foreground_color: AppColors.dark,
                  border_radius_size: "normal",
                  background_color: Colors.transparent)
            ],
          ),
          SizedBox(
            height: 15.sp,
          ),
          meilleurs_repas.isEmpty
              ? loading_repas
                  ? loading_repas_component()
                  : no_repas_component()
              : SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...meilleurs_repas.take(5).map(
                        (e) {
                          return SingleRepasComponent(
                            intitule: e["intitule"],
                            id: e["id"],
                            libelle: e["libelle"],
                            fullUrlPhoto: e["fullUrlPhoto"],
                            restaurant_fermer: e["restaurant_fermer"],
                            prix: e["prix"] ?? 0,
                            restaurant_id: e["restaurant_id"] ?? 0,
                            noteRepas: e["moyenneNote"],
                          );
                        },
                      )
                    ],
                  ),
                )
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
            height: 100,
            width: 100,
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
    return AnimatedOpacity(
      opacity: 1,
      duration: Duration(seconds: 1),
      curve: standardEasing,
      child: Center(
        child: Column(
          children: [
            SvgPicture.asset(
              "assets/SVG/repas-icon-black.svg",
              height: 100,
              width: 100,
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
      ),
    );
  }

  Future<void> _refresh() async {
    initData();
  }

  get_flash_destination(flash) {
    Widget destination = Accueil(
      token: Utils.TOKEN,
    );
    switch (flash) {
      case "restautant":
        destination = Repas();
        break;
      case "taxi":
        destination = CommandeTaxi();
        break;
      case "livraison":
        destination = CommandeLivraison();
        break;
      case "new":
        destination = Notifications();
        break;
      default:
    }
    return destination;
  }
}
