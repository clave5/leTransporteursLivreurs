// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_livreur/misc/colors.dart';
import 'package:letransporteur_livreur/widgets/button/app_button.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_bold_text.dart';

class RouterButton extends StatefulWidget {
  Widget destination;

  /// icon | text | image | svgimage
  String child_type;
  Icon icon;
  Color background_color;
  Color foreground_color;
  ButtonStyle style;
  bool with_text;
  double force_height;
  String text;
  String ratio_constraint;

  /// small | normal | large | double
  String text_size;

  /// light | regular | bold | titre
  String text_weight;
  String icon_size;

  /// small | normal | large | "doublexdouble"
  String image_size;

  /// small | normal | large | "doublexdouble"
  String svg_image_size;

  /// small | normal | large | "doublexdouble"
  String border_radius_size;
  TextAlign text_align;
  String svg_path;
  List<double> padding;
  String image_path;

  RouterButton({
    super.key,
    required this.destination,
    this.child_type = "text",
    this.with_text = false,
    this.ratio_constraint = "20x20",
    this.text = "Button",
    this.text_weight = "regular",
    this.icon = const Icon(Icons.add_circle_outlined),
    this.background_color = AppColors.transparent,
    this.foreground_color = AppColors.dark,
    this.style = const ButtonStyle(),
    this.text_align = TextAlign.center,
    this.icon_size = "normal",
    this.image_size = "normal",
    this.svg_image_size = "normal",
    this.text_size = "normal",
    this.border_radius_size = "normal",
    this.svg_path = "",
    this.padding = const [],
    this.force_height = 0,
    this.image_path = "",
  });

  @override
  State<RouterButton> createState() => RouterButtonState();
}

class RouterButtonState extends State<RouterButton> {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onPressed,
      child_type: widget.child_type,
      with_text: widget.with_text,
      text_align: widget.text_align,
      text_weight: widget.text_weight,
      force_height: widget.force_height,
      style: widget.style,
      padding: widget.padding,
      text: widget.text,
      icon: widget.icon,
      ratio_constraint: widget.ratio_constraint,
      background_color: widget.background_color,
      foreground_color: widget.foreground_color,
      icon_size: widget.icon_size,
      image_size: widget.image_size,
      svg_image_size: widget.svg_image_size,
      text_size: widget.text_size,
      border_radius_size: widget.border_radius_size,
      svg_path: widget.svg_path,
      image_path: widget.image_path,
    );
  }

  void onPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget.destination),
    );
  }
}
