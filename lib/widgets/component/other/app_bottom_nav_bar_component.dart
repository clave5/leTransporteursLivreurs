// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:letransporteur_livreur/misc/colors.dart';
import 'package:letransporteur_livreur/pages/accueil.dart';
import 'package:letransporteur_livreur/pages/activites.dart';
import 'package:letransporteur_livreur/pages/assistance.dart';
import 'package:letransporteur_livreur/pages/profile.dart';
import 'package:letransporteur_livreur/widgets/button/router_button.dart';

enum BottomNavPage { accueil, activites, assistance, profile }

class AppBottomNavBarComponent extends StatefulWidget {
  BottomNavPage active;
  AppBottomNavBarComponent({super.key, required this.active});

  @override
  State<AppBottomNavBarComponent> createState() => _AppBottomNavBarComponentState();
}

class _AppBottomNavBarComponentState extends State<AppBottomNavBarComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                get_accueil_router_button(),
                get_activites_router_button(),
                get_assistance_router_button(),
                get_profile_router_button(),
              ],
            )));
  }

  RouterButton get_profile_router_button() {
    RouterButton button = get_initial_router_button(
        Profile(), "assets/SVG/profile-menu-stroke-icon.svg");

    if (widget.active == BottomNavPage.profile) {
      set_active_router_button_props(
          button, "assets/SVG/icon-profil-fill.svg", "Profile");
    }
    return button;
  }

  RouterButton get_assistance_router_button() {
    RouterButton button = get_initial_router_button(
        Assistance(), "assets/SVG/assistance-menu-stroke-icon.svg");

    if (widget.active == BottomNavPage.assistance) {
      set_active_router_button_props(
          button, "assets/SVG/icon-assistance-fill.svg", "Assistance");
    }
    return button;
  }

  RouterButton get_activites_router_button() {
    RouterButton button = get_initial_router_button(
        Activites(), "assets/SVG/activite-menu-stroke-icon.svg");

    if (widget.active == BottomNavPage.activites) {
      set_active_router_button_props(
          button, "assets/SVG/icon-activite-fill.svg", "Activités");
    }
    return button;
  }

  RouterButton get_accueil_router_button() {
    RouterButton button = get_initial_router_button(
        Accueil(), "assets/SVG/accueil-menu-stroke-icon.svg");

    if (widget.active == BottomNavPage.accueil) {
      set_active_router_button_props(
          button, "assets/SVG/icon-accueil-fill.svg", "Accueil");
    }
    return button;
  }

  RouterButton get_initial_router_button(Widget destination, String svg_path) {
    RouterButton button = RouterButton(
      destination: destination,
      child_type: "svgimage",
      svg_image_size: "wx25",
      svg_path: svg_path,
      padding: [12, 20, 12, 20],
      foreground_color: AppColors.dark,
      background_color: Colors.transparent,
    );
    return button;
  }

  void set_active_router_button_props(
      RouterButton button, String svg_path, String text) {
    setState(() {
      button.svg_path = svg_path;
      button.text = text;
      button.foreground_color = Colors.white;
      button.with_text = true;
      button.text_size = "small";
      button.text_weight = "bold";
      button.svg_image_size = "wx18";
      button.border_radius_size = "100";
      button.background_color = AppColors.dark;
    });
  }
}
