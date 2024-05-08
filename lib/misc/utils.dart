// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:letransporteur_livreur/misc/colors.dart';

class Utils {
  // Function to convert Color to hexadecimal string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
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
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight);
  }

  static InputDecoration get_default_input_decoration(
      String placeholder, dynamic field_icon) {
    if (field_icon != null) field_icon = Icon(field_icon);

    var inputDecoration = InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none // Set border radius
        ),
        fillColor: AppColors.gray6,
        labelText: placeholder,
        prefixIcon: field_icon);

    return inputDecoration;
  }
}
