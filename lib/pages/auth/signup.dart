// pages/auth/signup.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/auth/signup_continue.dart';
import 'package:letransporteur_client/pages/auth/login.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Signup extends StatefulWidget {
  final Map<String, Object?>? data;
  final Map<String, dynamic>? validation_errors;

  const Signup({super.key, this.data, this.validation_errors});

  @override
  State<Signup> createState() => SignupState();
}

class SignupState extends State<Signup> {
  bool villes_loading = false;
  List<dynamic> villes = [];
  String _token = "";

  FormGroup form = FormGroup({
    'telephone': FormControl<String>(validators: [
      Validators.required,
      Validators.number(allowNegatives: false)
    ]),
    'countryCode': FormControl<String>(validators: [
      Validators.required,
    ], value: "+229"),
    'nom': FormControl<String>(validators: [
      Validators.required,
    ]),
    'prenoms': FormControl<String>(validators: [
      Validators.required,
    ]),
    'dateNaissance': FormControl<DateTime>(validators: [
      Validators.required,
    ]),
    'ville': FormControl<String>(validators: [
      Validators.required,
    ]),
    'password': FormControl<String>(validators: []),
    'password_confirmation': FormControl<String>(validators: []),
    'question_securite': FormControl<int>(validators: []),
    'reponse_securite': FormControl<String>(validators: []),
    'have_parrain': FormControl<bool>(validators: []),
    'codeParrain': FormControl<String>(validators: []),
  });

  bool phone_valid = false;

  late Future<void> ville_pays_get = Future<void>(() {});

  @override
  void initState() {
    super.initState();
    // Fetch posts when the widget is initialized
    if (widget.data != null) {
      form.patchValue(widget.data);
    }

    Utils.log(widget.validation_errors);
    if (widget.validation_errors != null) {
      widget.validation_errors?.forEach((key, value) {
        form
            .control(key)
            .setErrors(<String, dynamic>{"field_validation": value});
      });
      form.markAllAsTouched();
    }

    form.valueChanges.listen((element) {
      form.controls.forEach((key, value) {
        value.setErrors({});
      });
      Utils.log({"valid": form.valid, "form": element});
      if (mounted) setState(() {});
    });

    load_villes("+229");
    /* form.controls["countryCode"]?.valueChanges.listen((event) {
      load_villes();
    }); */
  }

  load_villes(String contry_code) {
    //get the question securite
    if (mounted) {
      setState(() {
        villes_loading = true;
      });
    }
    ville_pays_get = get_request(
      "$API_BASE_URL/ville/pays/$contry_code", // API URL
      _token,
      {}, // Query parameters (if any)
      (response) {
        if (mounted) {
          setState(() {
            villes = response["villes_pays"];
            villes_loading = false;
          });
        }
      },
      (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/img/auth-ill.jpg"),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              fit: BoxFit.cover,
            ),
            Container(
              
              width: MediaQuery.of(context).size.width * 0.9,
              transform: Matrix4.translationValues(0, -60, 0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                
                padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 40.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LargeTitreText(
                      text: "Inscrivez vous",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.sp),
                    MediumLightText(
                        text:
                            "Entrez vos informations ci-dessous pour créer vote compte.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 35.sp),
                    ReactiveForm(
                      
                      formGroup: form,
                      child: Column(
                        children: [
                          ReactiveTextField(
                            formControlName: 'nom',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'Le nom est requis',
                              'field_validation': (error) => error as String,
                            },
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('nom'),
                                    false,
                                    'Nom',
                                    {"icon": Icons.face, "size": 24.sp},
                                    null,
                                    null),
                                    style: Utils.small_bold_text_style,
                          ),
                          SizedBox(height: 10.sp),
                          ReactiveTextField(
                            formControlName: 'prenoms',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'Le prénom est requis',
                              'field_validation': (error) => error as String,
                            },
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('prenoms'),
                                    false,
                                    'Prénoms',
                                    {"icon": Icons.face, "size": 24.sp},
                                    null,
                                    null),
                                    style: Utils.small_bold_text_style,
                          ),
                          SizedBox(height: 10.sp),
                          
                          ReactiveDatePicker(
                            formControlName: 'dateNaissance',
                            //locale: Locale("fr", "FR"),
                            builder: (context, picker, child) {
                              return ReactiveTextField(
                                readOnly: true,
                                validationMessages: {
                                  ValidationMessage.required: (error) =>
                                      'La date de naissance est requise',
                                  'field_validation': (error) =>
                                      error as String,
                                },
                                onTap: (control) => {picker.showPicker()},
                                formControlName: 'dateNaissance',
                                decoration:
                                    Utils.get_default_input_decoration_normal(
                                        form.control('dateNaissance'),
                                        false,
                                        'Date de naissance',
                                        {
                                          "icon": Icons.calendar_today_rounded,
                                          "size": Utils.small_bold_text_style
                                              .fontSize!.sp
                                        },
                                        null,
                                        null),
                                style: Utils.small_bold_text_style,
                              );
                            },
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          ),
                          SizedBox(height: 10.sp),
                          IntlPhoneField(
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('telephone'),
                                    true,
                                    'Numero de téléphone',
                                    null,
                                    null,
                                    null),
                            style: Utils.small_bold_text_style,
                            initialCountryCode: 'BJ',
                            languageCode: "fr",
                            onCountryChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  load_villes("+${value.fullCountryCode}");
                                });
                              }
                            },
                            onChanged: (phone) {
                              Utils.log(phone);
                              if (mounted) {
                                setState(() {
                                  try {
                                    phone_valid = phone.isValidNumber();
                                  } on Exception catch (e) {
                                    phone_valid = false;
                                  }
                                  form.patchValue(
                                      {"telephone": phone.completeNumber});
                                });
                              }
                            },
                          ),
                          form
                                      .control("telephone")
                                      .errors["field_validation"] !=
                                  null
                              ? XSmallBoldText(
                                  color: Utils.colorToHex(Colors.red),
                                  text: form
                                      .control("telephone")
                                      .errors["field_validation"]
                                      .toString())
                              : Container(),
                          SizedBox(height: 20.sp),
                          
                          ReactiveDropdownField<String>(
                            isExpanded: true,
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('ville'),
                                    true,
                                    'Ville de résidence',
                                    {"icon": Icons.location_pin, "size": 24.sp},
                                    null,
                                    null),
                            formControlName: 'ville',
                            style: Utils.small_bold_text_style,
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'La ville de résidence est requise',
                              'field_validation': (error) => error as String,
                            },
                            hint: Text('Ville de résidence'),
                            items: [
                              ...villes.map((ville) {
                                return DropdownMenuItem(
                                  value: ville["libelle"],
                                  child: Text(ville["libelle"]),
                                );
                              }),
                            ],
                          ),
                          SizedBox(height: 35.sp),
                          RouterButton(
                              destination: SignupContinue(data: form.rawValue),
                              background_color: AppColors.primary,
                              disabled: !form.valid || !phone_valid,
                              text: "Continuer",
                              text_weight: "bold"),
                          SizedBox(height: 15.sp),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              XSmallLightText(text: "Déjà inscrit ?"),
                              SizedBox(width: 5),
                              RouterButton(
                                  padding: [0, 0, 0, 0],
                                  destination: Login(),
                                  text_size: "xsmall",
                                  text_weight: "bold",
                                  text: "Connectez-vous"),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
/* 
  Future<String?> _showBottomSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.options.map((option) {
            return ListTile(
              title: Text(option),
              onTap: () {
                Navigator.of(context).pop(option);  // Return the selected option
              },
            );
          }).toList(),
        );
      },
    );
  } */

  void country_code_changed(CountryCode code) {
    Utils.log(code.toString());
    form.patchValue({"countryCode": code.toString()});
  }

  void onPressed() {}

  @override
  void dispose() {
    if (ville_pays_get != null) ville_pays_get.ignore();
    form.dispose();
    super.dispose();
  }
}
