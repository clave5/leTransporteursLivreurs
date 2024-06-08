// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:logger/logger.dart';

class Utils {
  static var logger = Logger();

  static var REPAS_WIDGET_DEFAULT_WIDTH = 160.0;
  static var TOKEN = "";
  static set_token(String token) {
    TOKEN = token;
  }
  // Function to convert Color to hexadecimal string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static void log(dynamic object) {
    //print(['LOG_DEBUG', object]);
    logger.i(object);
  }

  static void log_error(dynamic object) {
    //print(['LOG_DEBUG', object]);
    logger.e(object);
  }

  static TextStyle small_light_text_style =
      Utils.get_text_with_style(AppColors.dark, 14, "Aller", FontWeight.w300);
  static TextStyle small_regular_text_style =
      Utils.get_text_with_style(AppColors.dark, 14, "Aller", FontWeight.normal);
  static TextStyle small_bold_text_style =
      Utils.get_text_with_style(AppColors.dark, 14, "Aller", FontWeight.bold);

  static TextStyle medium_bold_text_style =
      Utils.get_text_with_style(AppColors.dark, 16, "Aller", FontWeight.w300);
  static TextStyle medium_light_text_style =
      Utils.get_text_with_style(AppColors.dark, 16, "Aller", FontWeight.normal);
  static TextStyle medium_regular_text_style =
      Utils.get_text_with_style(AppColors.dark, 16, "Aller", FontWeight.bold);

  static TextStyle large_bold_text_style =
      Utils.get_text_with_style(AppColors.dark, 24, "Aller", FontWeight.w300);
  static TextStyle large_light_text_style =
      Utils.get_text_with_style(AppColors.dark, 24, "Aller", FontWeight.normal);
  static TextStyle large_regular_text_style =
      Utils.get_text_with_style(AppColors.dark, 24, "Aller", FontWeight.bold);

  static TextStyle get_text_with_style(
      Color color, double fontSize, String fontFamily, FontWeight fontWeight) {
    return TextStyle(
        inherit: true,
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight);
  }

  static InputDecoration get_default_input_decoration(String placeholder,
      dynamic field_icon, Color? fillColor, Color? borderColor) {
    if (field_icon != null) field_icon = Icon(field_icon);

    var inputDecoration = InputDecoration(
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none // Set border radius
            ),
        fillColor: fillColor ?? AppColors.gray6,
        labelText: placeholder,
        prefixIcon: field_icon);

    return inputDecoration;
  }
}
