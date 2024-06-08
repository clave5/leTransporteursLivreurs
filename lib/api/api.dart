/// OPENROUTESERVICE DIRECTION SERVICE REQUEST
/// Parameters are : startPoint, endPoint and api key

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'dart:convert';

import 'package:reactive_forms/reactive_forms.dart';

const String API_BASE_URL = "https://admin.letransporteur.co/api";
const String OPEN_ROUTE_DIRECTION_BASE_URL =
    'https://api.openrouteservice.org/v2/directions/driving-car';
const String OPEN_ROUTE_AUTOCOMPLETE_BASE_URL =
    'https://api.openrouteservice.org/geocode/autocomplete';
const String OPEN_ROUTE_LATLONG_TO_GEODATA_BASE_URL =
    'https://api.openrouteservice.org/geocode/reverse';
const String OPEN_ROUTE_API_KEY =
    '5b3ce3597851110001cf6248ff657fd3ca4f4127a57164d43eeba1c1';

get_route_url(String startPoint, String endPoint) {
  return Uri.parse(
      '$OPEN_ROUTE_DIRECTION_BASE_URL?api_key=$OPEN_ROUTE_API_KEY&start=$startPoint&end=$endPoint');
}

get_auto_complete_url(String search) {
  return Uri.parse(
          '$OPEN_ROUTE_AUTOCOMPLETE_BASE_URL?boundary.country=BJ&text=$search&api_key=$OPEN_ROUTE_API_KEY')
      .toString();
}

get_latlong_to_geodata_url(double longitude, double latitude) {
  return Uri.parse(
          '$OPEN_ROUTE_LATLONG_TO_GEODATA_BASE_URL?point.lon=$longitude&point.lat=$latitude&api_key=$OPEN_ROUTE_API_KEY&&radiuse=1000')
      .toString();
}

Future<void> post_request(
    String api_url,
    String token,
    Map<String, dynamic> data,
    Function(Map<String, dynamic>) on_success,
    Function(dynamic) on_error,
    FormGroup? form_to_handle,
    BuildContext context) async {
  final url = Uri.parse(api_url); // Replace with your URL

  try {
    var request = http.MultipartRequest('POST', url);

    data.forEach((key, value) {
      request.fields.addAll({key: "$value"});
    });
    request.headers.addAll({"Authorization": "Bearer $token"});

    Utils.log([url, data]);

    final response = await http.Response.fromStream(await request.send());
    dynamic response_body = json.decode(response.body);
    // Read the response body
    if (response_body["status"] == true) {
      // Handle successful response
      Utils.log(json.decode(response.body));
      on_success(json.decode(response.body));
    } else if (response.statusCode == 422) {
      // erreurs de validation

      Utils.log_error("${response.statusCode} ${response.reasonPhrase}");
      Utils.log_error(response_body);
      on_error({"field_validation": true, "response_body": response_body});

      if (form_to_handle != null) {
        response_body["errors"].forEach((key, value) {
          if (form_to_handle.controls[key] != null) {
            form_to_handle.controls[key]
                ?.setErrors({"field_validation": (value as List)[0]});
            Utils.log(form_to_handle.controls[key]?.errors);
          } else {
            launch_dialog(context, key + " : " + (value as List)[0]);
          }
        });
        form_to_handle.markAllAsTouched();
      }
    } else {
      Utils.log_error(json.decode(response.body));
      on_error(response_body["message"]);
      launch_dialog(context, response_body["message"]);
    }
  } catch (e) {
    // Handle any exceptions
    on_error(e.toString());
    Utils.log_error(e.toString());
    //rethrow;
  }
}

launch_dialog(BuildContext context, String text) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(""),
          content: SmallBoldText(text: text),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok, compris'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

Future<void> get_request(
  String apiUrl,
  String token,
  Map<String, dynamic> queryParams,
  Function(Map<String, dynamic>) on_success,
  Function(String) on_error,
) async {
  Map<String, String> headers = {
    "Content-Type": "multipart/form-data",
    "Authorization": "Bearer $token"
  };

  Uri uri = Uri.parse(apiUrl);
  uri = uri.replace(queryParameters: queryParams);

  Utils.log(uri);

  try {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      // Handle successful response
      Utils.log(json.decode(response.body));
      on_success(json.decode(response.body));
    } else {
      // Handle error response
      Utils.log_error('Error: ${response.reasonPhrase}');
      on_error('Error: ${response.reasonPhrase}');
    }
  } catch (e) {
    // Handle any exceptions
    on_error('Error: ${e.toString()}');
    Utils.log_error(e);
  }
}
