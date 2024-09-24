// widgets/page/map/map_picker_page.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, prefer_interpolation_to_compose_strings// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/component/other/info_box_component.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:reactive_forms/reactive_forms.dart';

class MapPickerScreen extends StatefulWidget {
  dynamic intent_data;
  MapPickerScreen({super.key, this.intent_data});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen>
    with TickerProviderStateMixin {
  // Raw coordinates got from  OpenRouteService
  List listOfPoints = [];

  // Conversion of listOfPoints into LatLng(Latitude, Longitude) list of points
  List<LatLng> points = [];

  FormGroup map_search_form = FormGroup({
    'search': FormControl<String>(),
  });

  List<dynamic>? auto_compl_suggestions;
  bool autocomplete_searching = false;
  bool from_inner = false;
  LatLng global_marker_position = LatLng(9.3220475, 2.313137999999981);
  dynamic selected_geo_point;
  late final AnimatedMapController animated_map_controller =
      AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  var zoom_level = 8.0;

  var global_place_name = "";

  @override
  initState() {
    super.initState();

    if (widget.intent_data["long"] != null) {
      global_marker_position = LatLng(double.parse(widget.intent_data["lat"]),
          double.parse(widget.intent_data["long"]));
      zoom_level = widget.intent_data["zoom"];
    }

    getCurrentPosition();

    map_search_form
        .control('search')
        .valueChanges
        .debounceTime(Duration(milliseconds: 1000))
        .listen((value) {
      Utils.log(["from_inner", from_inner]);
      if (value.length > 2 && from_inner == false) {
        print('Debounced search value: $value');
        fetch_suggestions(value);
      }
      if (mounted) {
        setState(() {
          from_inner = false;
        });
      }
      // Perform your search operation here
    });
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      Utils.log(position);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.primary_light,
          content: SmallBoldText(
            text: 'Affichage de votre position géographique...',
          )));
      update_marker_position(LatLng(position.latitude, position.longitude));
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.primary_light,
          content: SmallBoldText(
            text:
                'Les services de localisation sont désactivés. Veuillez activer les services',
          )));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: AppColors.primary_light,
            content: SmallBoldText(
                text: 'Les autorisations de localisation sont refusées')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.primary_light,
          content: SmallBoldText(
              text:
                  "Les autorisations de localisation sont définitivement refusées, nous ne pouvons pas demander d'autorisations.")));
      return false;
    }
    return true;
  }

  void update_marker_position(LatLng newPosition) {
    Utils.log(animated_map_controller.animateTo(dest: newPosition, zoom: 15.0));
    if (mounted) {
      setState(() {
        // zoom_level = 15;
        // global_marker_position = newPosition;
      });
    }
    Utils.log(newPosition);
    fetch_geo_data_from_latlong(newPosition.latitude, newPosition.longitude);
  }

  @override
  void dispose() {
    // Clean up any resources here if necessary
    super.dispose();
  }

  void fetch_suggestions(String input) async {
    if (mounted) {
      setState(() {
        autocomplete_searching = true;
        selected_geo_point = null;
      });
    }
    String url = get_auto_complete_url(input);
    Utils.log('fetching $url');
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Utils.log('retrieved data');
        Utils.log(data);
        if (mounted) {
          setState(() {
            autocomplete_searching = false;
            auto_compl_suggestions =
                List<dynamic>.from(data['features'].map((e) {
              return {
                "title": e['properties']['name'],
                "subtitle":
                    e['properties']['county'] + " " + e['properties']['region'],
                "latitude": e["geometry"]["coordinates"][1],
                "longitude": e["geometry"]["coordinates"][0]
              };
            }));
          });
        }
      } else {
        Utils.log_error(json.decode(response.body));
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          autocomplete_searching = false;
        });
      }
      Utils.log_error(e.toString());
    }
  }

  void fetch_geo_data_from_latlong(double latitude, double longitude) async {
    if (mounted) {
      setState(() {
        selected_geo_point = null;
        autocomplete_searching = true;
      });
    }
    String url = get_latlong_to_geodata_url(latitude, longitude);
    Utils.log('fetching $url');
    try {
      var response = await http.get(Uri.parse(url));
      if (mounted) {
        setState(() {
          autocomplete_searching = false;
        });
      }
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Utils.log('retrieved data');
        Utils.log(data);
        select_geo_point({
          "title":
              "Près de $global_place_name - ${data["features"][0]["properties"]["distance"]}",
          "subtitle": data["features"][0]["properties"]["name"],
          "latitude": latitude,
          "longitude": longitude
        });
      } else {
        Utils.log_error(json.decode(response.body));
      }
    } on Exception catch (e) {
      Utils.log(e.toString());
      if (mounted) {
        setState(() {
          autocomplete_searching = false;
        });
      }
    }
  }

  select_geo_point(dynamic geo_point) {
    map_search_form.control('search').patchValue(
        geo_point["title"] + ", " + geo_point["subtitle"],
        emitEvent: false);
    Utils.log(geo_point);
    if (mounted) {
      setState(() {
        selected_geo_point = geo_point;
        global_marker_position =
            LatLng(geo_point["latitude"], geo_point["longitude"]);
      });
    }
  }

  search_results() {
    if (selected_geo_point != null) {
      return Container();
    }

    if (autocomplete_searching) {
      return Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: SizedBox(
              height: 30.sp,
              width: 30.sp,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.gray2),
              ),
            ),
          ));
    } else {
      if (auto_compl_suggestions != null) {
        if (auto_compl_suggestions!.isNotEmpty) {
          return Container(
              height: 150.sp,
              child: ListView.builder(
                itemCount: auto_compl_suggestions!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Utils.log(auto_compl_suggestions![index]);
                      //select_geo_point(auto_compl_suggestions![index]);
                      var _latitude =
                          auto_compl_suggestions![index]["latitude"];
                      var _longitude =
                          auto_compl_suggestions![index]["longitude"];
                      var subtitle = auto_compl_suggestions![index]["subtitle"];
                      var title = auto_compl_suggestions![index]["title"];
                      var distance = auto_compl_suggestions![index]["distance"];
                      select_geo_point({
                        "title": "Près de $title",
                        "subtitle": subtitle,
                        "latitude": _latitude,
                        "longitude": _longitude
                      });
                      animated_map_controller.animateTo(
                          dest: LatLng(_latitude, _longitude), zoom: 15.0);

                      if (mounted) {
                        setState(() {
                          from_inner = true;
                          map_search_form.control("search").patchValue(title);
                          global_place_name =
                              auto_compl_suggestions![index]["title"];
                          auto_compl_suggestions = null;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.sp),
                      decoration: BoxDecoration(
                          border: BorderDirectional(
                              bottom: BorderSide(color: AppColors.gray5))),
                      child: Row(
                        children: [
                          Icon(Icons.my_location,
                              color: AppColors.gray3, size: 30.sp),
                          SizedBox(
                            width: 10.sp,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MediumBoldText(
                                    text: auto_compl_suggestions![index]![
                                        "title"]),
                                SmallLightText(
                                    text: auto_compl_suggestions![index]![
                                        "subtitle"]),
                                SizedBox(
                                  height: 5.sp,
                                ),
                                Container(
                                  width: 1.sp,
                                  color: AppColors.gray5,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ));
        } else {
          return Container(
            height: 100.sp,
            width: double.infinity,
            child: Center(
              child: SmallLightText(
                text: "Aucun résultat à afficher.",
              ),
            ),
          );
        }
      } else {
        return Container(
          height: 0,
          width: double.infinity,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: animated_map_controller,
            options: MapOptions(
              zoom: zoom_level,
              center: global_marker_position,
              onTap: (tapPosition, point) {
                // Move the marker to the tapped location
                update_marker_position(point);
              },
            ),
            children: [
              // Layer that adds the map
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              // Layer that adds points the map
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0.sp,
                    height: 80.0.sp,
                    point: global_marker_position,
                    builder: (ctx) => GestureDetector(
                      onPanUpdate: (details) {
                        // Update the marker position while dragging
                        LatLng newPosition = LatLng(
                          global_marker_position.latitude +
                              details.delta.dy * 0.0001,
                          global_marker_position.longitude +
                              details.delta.dx * 0.0001,
                        );
                        update_marker_position(newPosition);
                      },
                      child: Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.sp),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.15), // Shadow color with opacity
                      spreadRadius: 5, // Spread radius
                      blurRadius: 7, // Blur radius
                      offset: Offset(0, 3), // Offset in X and Y axis
                    )
                  ],
                ),
                padding: EdgeInsets.all(15.sp),
                width: MediaQuery.of(context).size.width - 40.sp,
                margin: EdgeInsets.only(
                    top: AppBar().preferredSize.height.sp,
                    left: 20.sp,
                    right: 20.sp),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmallTitreText(
                          text: "Sélectionner " +
                              widget.intent_data?["lieu_label"],
                        ),
                        AppButton(
                          onPressed: () {
                            Utils.log("annuler");
                            Navigator.pop(context);
                          },
                          background_color: Colors.transparent,
                          foreground_color: Colors.red,
                          text: "annuler",
                          force_height: 55.sp,
                          text_size: "small",
                          padding: [0, 0, 0, 0],
                        )
                      ],
                    ),
                    selected_geo_point != null
                        ? GestureDetector(
                            child: InfoBoxComponent(
                                content: selected_geo_point["title"] +
                                    ", " +
                                    selected_geo_point["subtitle"],
                                button_widget: {
                                  "padding": [0.0, 0.0, 0.0, 0.0],
                                  "app_button": true,
                                  "background_color": Colors.transparent,
                                  "foreground_color": AppColors.gray3,
                                  "on_pressed": () {
                                    if (mounted) {
                                      map_search_form
                                          .patchValue({"search": ""});
                                      setState(() {
                                        selected_geo_point = null;
                                      });
                                    }
                                  },
                                  "svg_path": "assets/SVG/close.svg",
                                  "with_text": false,
                                  "text": "",
                                }),
                          )
                        : ReactiveForm(
                            formGroup: map_search_form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 25.sp),
                                Container(
                                  child: ReactiveTextField(
                                    formControlName: 'search',
                                    style: Utils.small_bold_text_style,
                                    decoration: Utils
                                        .get_default_input_decoration_with_button(
                                            map_search_form.control("search"),
                                            false,
                                            1,
                                            'Rechercher une adresse',
                                            {
                                              "icon": Icons.search,
                                              "size": 30.sp
                                            },
                                            Colors.transparent,
                                            AppColors.gray7,
                                            AppButton(
                                              child_type: "icon",
                                              foreground_color: AppColors.dark,
                                              icon_size: "40x40",
                                              icon: Icon(
                                                Icons.my_location,
                                                size: 25.sp,
                                              ),
                                              onPressed: () {
                                                getCurrentPosition();
                                              },
                                            )),
                                  ),
                                ),
                                SizedBox(height: 15.sp),
                                search_results(),
                              ],
                            ),
                          ),
                    SizedBox(
                      height: 15.sp,
                    ),
                    selected_geo_point == null
                        ? Container()
                        : AppButton(
                            onPressed: () {
                              Navigator.pop(context, selected_geo_point);
                            },
                            child_type: "text",
                            svg_image_size: "wx16",
                            text: "Choisir comme " +
                                widget.intent_data?["lieu_label"],
                            text_size: "small",
                            text_align: TextAlign.center,
                            text_weight: "bold",
                            foreground_color: AppColors.dark,
                            border_radius_size: "normal",
                            background_color: AppColors.primary,
                          )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
