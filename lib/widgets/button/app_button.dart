// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_light_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_titre_text.dart';

class AppButton extends StatefulWidget {
  String child_type;
  Icon icon;
  Color background_color;
  Color foreground_color;
  ButtonStyle style;
  bool with_text;
  String text;
  double force_height;

  /// WidthxHeight
  String ratio_constraint;

  /// xsmal | small | normal | large | double
  String text_size;

  /// light | regular | bold | titre
  String text_weight;

  /// small | normal | large | "doublexdouble"
  String icon_size;

  /// horizontal | vertical
  String orientation;

  /// small | normal | large | "doublexdouble"
  String image_size;

  /// small | normal | large | "doublexdouble"
  String svg_image_size;

  /// small | normal | large | "doublexdouble"
  String border_radius_size;

  /// [AppColors.dark, 2, BorderStyle.solid]
  List border;
  TextAlign text_align;
  String svg_path;

  ///[top, left, right, bottom]
  List<double> padding;

  bool? conserve_svg_image_color = false;

  String image_path;

  BorderRadius? border_radius_only;

  bool? disabled = false;
  bool? flex_reverse = false;
  bool? loading = true;
  Function() onPressed;

  AppButton(
      {super.key,
      this.child_type = "text",
      this.with_text = false,
      this.text = "Button",
      this.ratio_constraint = "20x20",
      this.icon = const Icon(Icons.add_circle_outlined),
      this.background_color = AppColors.transparent,
      this.foreground_color = AppColors.dark,
      this.style = const ButtonStyle(),
      this.text_align = TextAlign.center,
      this.icon_size = "normal",
      this.image_size = "normal",
      this.svg_image_size = "normal",
      this.text_size = "normal",
      this.text_weight = "regular",
      this.border_radius_size = "normal",
      this.orientation = "horizontal",
      this.svg_path = "",
      this.force_height = 0,
      this.padding = const [],
      this.image_path = "",
      this.border_radius_only,
      this.border = const [],
      this.conserve_svg_image_color = false,
      this.disabled = false,
      this.flex_reverse = false,
      this.loading = false,
      required this.onPressed});

  @override
  State<AppButton> createState() => AppButtonState();
}

class AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    ButtonStyle default_style = ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            side: widget.border.isEmpty
                ? BorderSide.none
                : BorderSide(
                    color: widget.border[0],
                    width: widget.border[1],
                    style: widget.border[2]),
            borderRadius: widget.border_radius_only ??
                BorderRadius.circular(
                    get_border_radius_size(widget.border_radius_size)))),
        backgroundColor:
            MaterialStatePropertyAll<Color>(widget.background_color));
    ButtonStyle disabled_style = ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: widget.border_radius_only ??
                BorderRadius.circular(
                    get_border_radius_size(widget.border_radius_size)))),
        backgroundColor: MaterialStatePropertyAll<Color>(AppColors.gray6));

    List<Widget> button_children = [get_button_child()];
    if (widget.with_text) {
      button_children.add(Padding(
        padding: widget.flex_reverse == true
            ? EdgeInsets.only(right: 5)
            : EdgeInsets.only(left: 5),
        child: get_text_child(),
      ));
    }

    button_children = widget.flex_reverse == true
        ? button_children.reversed.toList()
        : button_children;

    FilledButton button = FilledButton(
        onPressed: onPressed,
        style: widget.style
            .merge(widget.disabled == false ? default_style : disabled_style),
        child: Padding(
          padding: widget.padding.isEmpty
              ? EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25)
              : EdgeInsets.only(
                  top: widget.padding[0],
                  bottom: widget.padding[2],
                  left: widget.padding[3],
                  right: widget.padding[1]),
          child: widget.orientation == "horizontal"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: button_children,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: button_children,
                ),
        ));

    //if is icon button
    if (widget.child_type == "icon" && widget.with_text == false) {
      return ClipOval(
        child: Material(
          color: widget.background_color, // Button color
          child: InkWell(
            splashColor:
                widget.background_color.withOpacity(0.8), // Splash color
            onTap: () {
              widget.onPressed();
            },
            child: SizedBox(
              width: get_image_dimensions(widget.icon_size)[0],
              height: get_image_dimensions(widget.icon_size)[1],
              child: widget.icon,
            ),
          ),
        ),
      );
    }

    return widget.force_height > 0
        ? SizedBox(height: widget.force_height, child: button)
        : button;
  }

  Widget get_button_child() {
    Widget child = SmallBoldText(text: widget.text);

    switch (widget.child_type) {
      case "icon":
        child = widget.icon;
        break;
      case "text":
        //alraeady text
        child = widget.loading == true
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.gray2),
              )
            : get_text_child();
        break;
      case "image":
        child = Image(
            image: AssetImage(widget.image_path),
            width: get_image_dimensions(widget.image_size)[0],
            height: get_image_dimensions(widget.image_size)[1]);
        break;
      case "svgimage":
        child = SvgPicture.asset(
          widget.svg_path, // Path to your SVG asset
          width: get_image_dimensions(widget.svg_image_size)[0],
          height: get_image_dimensions(widget.svg_image_size)[1],
          color: widget.conserve_svg_image_color == true
              ? null
              : widget.foreground_color,
        );
        break;
      default:
    }

    print([widget.svg_path, widget.foreground_color]);
    print(get_image_dimensions(widget.svg_image_size));
    return child;
  }

  Widget get_text_child() {
    Widget child = SmallBoldText(
      text: widget.text,
      textAlign: widget.text_align,
    );

    Color text_color =
        widget.disabled == false ? widget.foreground_color : AppColors.gray4;
    switch (widget.text_size) {
      case "xsmall":
        switch (widget.text_weight) {
          case "light":
            child = XSmallLightText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "regular":
            child = XSmallRegularText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "bold":
            child = XSmallBoldText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "titre":
            child = XSmallTitreText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          default:
            break;
        }
        break;
      case "small":
        switch (widget.text_weight) {
          case "light":
            child = SmallLightText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "regular":
            child = SmallRegularText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "bold":
            child = SmallBoldText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "titre":
            child = SmallTitreText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          default:
            break;
        }
        break;
      case "normal":
        switch (widget.text_weight) {
          case "light":
            child = MediumLightText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "regular":
            child = MediumRegularText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "bold":
            child = MediumBoldText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "titre":
            child = MediumTitreText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          default:
            break;
        }
        break;
      case "large":
        switch (widget.text_weight) {
          case "light":
            child = LargeLightText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "regular":
            child = LargeRegularText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "bold":
            child = LargeBoldText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          case "titre":
            child = LargeTitreText(
                text: widget.text,
                textAlign: widget.text_align,
                color: Utils.colorToHex(text_color));
            break;
          default:
            break;
        }
        break;
      default:
        break;
    }
    return child;
  }

  List<dynamic> get_image_dimensions(String size_str) {
    List<dynamic> dimensions = [];
    double ratio_width = double.parse(widget.ratio_constraint.split("x")[0]);
    double ratio_height = double.parse(widget.ratio_constraint.split("x")[1]);
    double ratio = ratio_width / ratio_height;

    if (size_str.contains("wx")) {
      double height = double.parse(size_str.split("wx")[1]);
      double width = height * ratio;
      dimensions.addAll([width, height]);
    } else if (size_str.contains("xh")) {
      double width = double.parse(size_str.split("xh")[0]);
      double height = width / ratio;
      dimensions.addAll([width, height]);
    } else {
      try {
        String width_str = size_str.split('x')[0];
        String height_str = size_str.split('x')[1];
        double width = double.parse(width_str);
        double height = double.parse(height_str);
        dimensions.addAll([width, height]);
      } catch (e) {
        print(e);
        dimensions = [20.0, 20.0];
      }
    }

    return dimensions;
  }

  double get_border_radius_size(size_str) {
    double size = 5;
    switch (size_str) {
      case "small":
        break;
      case "normal":
        size = 10;
        break;
      case "large":
        size = 20;
        break;
      default:
        size = double.parse(size_str);
    }
    return size;
  }

  dynamic get_image_size(size_str) {
    double size = 20;
    switch (size_str) {
      case "small":
        break;
      case "normal":
        size = 30;
        break;
      case "large":
        size = 50;
        break;
      default:
    }
    return size;
  }

  void onPressed() {
    if (widget.loading == false && widget.disabled == false) {
      widget.onPressed();
    }
  }
}
