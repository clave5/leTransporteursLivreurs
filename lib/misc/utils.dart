// misc/utils.dart
// ignore_for_file: non_constant_identifier_names// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:letransporteur_client/main.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:letransporteur_client/misc/colors.dart';
import 'package:logger/logger.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Utils {
  static var logger = Logger();

  static var REPAS_WIDGET_DEFAULT_WIDTH = 160.0;
  static String TOKEN = "";
  static var panier = {"repas": [], "boissons": [], "accomps": []};
  static var big_data = {};
  static var repas_categories = [];
  static var repas_restaurants = [];
  static var TYPE_COMMANNDES = {"livraison": 1, "repas": 2, "taxi": 3};
  static var client = {};
  static var YOUR_API_PUBLIC_KEY = "pk_sandbox_nQ4y56sOOvKEmFnIAM0xkjsR";
  static var current_location = "";
  static var location_good = false;
  static const APP_HIVE_BOX_NAME = "LT";
  static const ACCESS_TOKEN_KEY = "access_token";

  static Future<void> storeAccessToken(String token) async {
    await Hive.box(APP_HIVE_BOX_NAME).put(ACCESS_TOKEN_KEY, token);
  }

  static Future<String?> getAccessToken() async {
    return await Hive.box(APP_HIVE_BOX_NAME).get(ACCESS_TOKEN_KEY);
  }

  static Future<void> removeAccessToken() async {
    TOKEN = "";
    await Hive.box(APP_HIVE_BOX_NAME).delete(ACCESS_TOKEN_KEY);
  }

  static set_token(String token) {
    TOKEN = token;
    storeAccessToken(token);
  }

  static String get_current_location() {
    return "Cotonou"; // current_location;
  }

  static String nf(var number) {
    final formatter = NumberFormat('###,###.##', 'en_US');
    bool negative = false;
    if (number == null) return "0";
    number = int.parse("$number");
    if (number < 0) negative = true;
    if (number == 0) return "0";
    final formattedNumber = formatter.format(number);

    // Replace commas with spaces
    return (negative ? "-" : "") + formattedNumber.replaceAll(',', ' ');
  }

  static String ta(var timestamp) {
    timeago.setLocaleMessages(
        'fr_short', FrShortMessages()); // Add french messages

    // Parse the timestamp string into a DateTime object
    final DateTime dateTime = DateTime.parse(timestamp);

    // Convert the DateTime object to a "time ago" format
    final String timeAgo = timeago.format(dateTime, locale: 'fr_short');
    return timeAgo;
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

  static void log_obj_error(dynamic object, StackTrace stack) {
    //print(['LOG_DEBUG', object]);
    logger.e(object, error: {DateTime.now(), object, stack});
  }

  static TextStyle xsmall_light_text_style = Utils.get_text_with_style(
      AppColors.dark, 13.sp, "Aller", FontWeight.w300);
  static TextStyle xsmall_regular_text_style = Utils.get_text_with_style(
      AppColors.dark, 13.sp, "Aller", FontWeight.normal);
  static TextStyle xsmall_bold_text_style = Utils.get_text_with_style(
      AppColors.dark, 13.sp, "Aller", FontWeight.bold);

  static TextStyle small_light_text_style = Utils.get_text_with_style(
      AppColors.dark, 15.sp, "Aller", FontWeight.w300);
  static TextStyle small_regular_text_style = Utils.get_text_with_style(
      AppColors.dark, 15.sp, "Aller", FontWeight.normal);
  static TextStyle small_bold_text_style = Utils.get_text_with_style(
      AppColors.dark, 15.sp, "Aller", FontWeight.bold);

  static TextStyle medium_bold_text_style = Utils.get_text_with_style(
      AppColors.dark, 18.sp, "Aller", FontWeight.bold);
  static TextStyle medium_light_text_style = Utils.get_text_with_style(
      AppColors.dark, 18.sp, "Aller", FontWeight.w300);
  static TextStyle medium_regular_text_style = Utils.get_text_with_style(
      AppColors.dark, 18.sp, "Aller", FontWeight.normal);

  static TextStyle large_light_text_style = Utils.get_text_with_style(
      AppColors.dark, 28.sp, "Aller", FontWeight.w300);
  static TextStyle large_regular_text_style = Utils.get_text_with_style(
      AppColors.dark, 28.sp, "Aller", FontWeight.normal);
  static TextStyle large_bold_text_style = Utils.get_text_with_style(
      AppColors.dark, 28.sp, "Aller", FontWeight.bold);

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
    if (field_icon != null) {
      field_icon = Icon(field_icon["icon"], size: field_icon["size"]);
    }

    var inputDecoration = InputDecoration(
        filled: true,
        labelStyle: small_regular_text_style,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.sp),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none // Set border radius
            ),
        fillColor: fillColor ?? AppColors.gray6,
        labelText: placeholder,
        prefixIcon: field_icon);

    return inputDecoration;
  }

  static InputDecoration get_default_input_decoration_multi_lines(
      AbstractControl control,
      bool with_hint,
      String placeholder,
      dynamic field_icon,
      Color? fillColor,
      Color? borderColor) {
    return _get_default_input_decoration(
        control, with_hint, 5, placeholder, field_icon, fillColor, borderColor);
  }

  static InputDecoration get_default_input_decoration_normal(
      AbstractControl control,
      bool with_hint,
      String placeholder,
      dynamic field_icon,
      Color? fillColor,
      Color? borderColor) {
    return _get_default_input_decoration(
        control, with_hint, 1, placeholder, field_icon, fillColor, borderColor);
  }

  static InputDecoration _get_default_input_decoration(
      AbstractControl control,
      bool with_hint,
      int multi_lines,
      String placeholder,
      dynamic field_icon,
      Color? fillColor,
      Color? borderColor) {
    if (field_icon != null) {
      field_icon = Icon(field_icon["icon"], size: field_icon["size"]);
    }

    //log((control.errors, control.value, control.hasErrors, control.touched));

    var field_height = 65.sp * multi_lines;

    if (control.hasErrors && control.touched) {
      field_height += 40.sp;
    }
    if (with_hint) {
      field_height += 40.sp;
    }
    var inputDecoration = InputDecoration(
        filled: true,
        constraints: BoxConstraints(maxHeight: field_height),
        labelStyle: small_regular_text_style,
        helperStyle: small_regular_text_style,
        errorStyle:
            small_regular_text_style.copyWith(color: Colors.red.shade900),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.sp),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none // Set border radius
            ),
        fillColor: fillColor ?? AppColors.gray6,
        labelText: placeholder,
        prefixIcon: field_icon);

    return inputDecoration;
  }

  static InputDecoration get_chat_input_decoration(
    String placeholder,
  ) {
    //log((control.errors, control.value, control.hasErrors, control.touched));

    var inputDecoration = InputDecoration(
      filled: true,
      constraints: BoxConstraints(minHeight: 65.sp),
      labelStyle: small_regular_text_style,
      helperStyle: small_regular_text_style,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.sp), bottomLeft: Radius.circular(5.sp)),
      ),
      fillColor: AppColors.gray7,
      labelText: placeholder,
    );

    return inputDecoration;
  }

  static InputDecoration get_default_input_decoration_with_button(
      AbstractControl control,
      bool with_hint,
      int multi_lines,
      String placeholder,
      dynamic field_icon,
      Color? fillColor,
      Color? borderColor,
      Widget? suffix) {
    if (field_icon != null) {
      field_icon = Icon(field_icon["icon"], size: field_icon["size"]);
    }

    var field_height = 65.sp * multi_lines;

    if (control.hasErrors && control.touched) {
      field_height += 40.sp;
    }
    if (with_hint) {
      field_height += 40.sp;
    }
    var inputDecoration = InputDecoration(
        filled: true,
        constraints: BoxConstraints(minHeight: field_height),
        labelStyle: small_regular_text_style,
        helperStyle: small_regular_text_style,
        errorStyle:
            small_regular_text_style.copyWith(color: Colors.red.shade900),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.sp),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none // Set border radius
            ),
        fillColor: fillColor ?? AppColors.gray6,
        labelText: placeholder,
        suffixIcon: suffix,
        prefixIcon: field_icon);

    return inputDecoration;
  }

  static void show_toast(BuildContext context, String error) {
    try {
      /* Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: AppColors.primary_light,
                content: SmallBoldText(text: error)));
          },
          child: Container(),
        ),
      ); */

      /* MyApp.scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          backgroundColor: AppColors.primary_light,
          content: SmallBoldText(text: error))); */
    } on Exception catch (e) {
      // TODO
    }
  }
}

/// French shott messages
class FrShortMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => "d'ici";
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => "à l'instant";
  @override
  String aboutAMinute(int minutes) => '1min';
  @override
  String minutes(int minutes) => '${minutes}min';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1j';
  @override
  String days(int days) => '${days}j';
  @override
  String aboutAMonth(int days) => '1m';
  @override
  String months(int months) => '${months}m';
  @override
  String aboutAYear(int year) => '1an';
  @override
  String years(int years) => '${years}a';
  @override
  String wordSeparator() => ' ';
}
