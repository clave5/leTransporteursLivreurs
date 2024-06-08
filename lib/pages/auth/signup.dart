// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/auth/signup_continue.dart';
import 'package:letransporteur_client/pages/first_login.dart';
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
    'telephone': FormControl<int>(validators: [
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

  @override
  void initState() {
    super.initState();
    // Fetch posts when the widget is initialized
    if (widget.data != null) {
      form.patchValue(widget.data);
    }

    if (widget.validation_errors != null) {
      widget.validation_errors?.forEach((key, value) {
      });
      form.markAllAsTouched();
    }

    form.valueChanges.listen((element) {
      form.controls.forEach((key, value) {
        value.setErrors({});
      });
      Utils.log({"valid": form.valid, "form": element});
      setState(() {});
    });

    /* load_villes();
    form.controls["countryCode"]?.valueChanges.listen((event) {
      load_villes();
    }); */
  }

  load_villes() {
    //get the question securite
    setState(() {
      villes_loading = true;
    });
    get_request(
      "$API_BASE_URL/ville/pays/${form.rawValue["countryCode"] as String}", // API URL
      _token,
      {}, // Query parameters (if any)
      (response) {
        setState(() {
          villes = response["villes_pays"];
          villes_loading = false;
        });
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
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LargeTitreText(
                      text: "Inscrivez vous",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    MediumLightText(
                        text:
                            "Entrez vos informations ci-dessous pour créer vote compte.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 35),
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
                            decoration: Utils.get_default_input_decoration(
                                'Nom', Icons.face, null, null),
                          ),
                          SizedBox(height: 10),
                          ReactiveTextField(
                            formControlName: 'prenoms',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'Le prénom est requis',
                              'field_validation': (error) => error as String,
                            },
                            decoration: Utils.get_default_input_decoration(
                                'Prénoms', Icons.face, null, null),
                          ),
                          SizedBox(height: 10),
                          ReactiveDatePicker(
                            formControlName: 'dateNaissance',
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
                                decoration: Utils.get_default_input_decoration(
                                    'Date de naissance',
                                    Icons.calendar_today_rounded,
                                    null,
                                    null),
                                style: Utils.small_bold_text_style,
                              );
                            },
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CountryCodePicker(
                                backgroundColor: AppColors.gray6,
                                onChanged: country_code_changed,
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'BJ',
                                favorite: ['+229', 'BJ'],
                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                // optional. Shows only country name and flag when popup is closed.
                                showOnlyCountryWhenClosed: false,
                                // optional. aligns the flag and the Text left
                                alignLeft: false,
                              ),
                              Expanded(
                                flex: 2,
                                child: ReactiveTextField(
                                  formControlName: 'telephone',
                                  keyboardType: TextInputType.phone,
                                  validationMessages: {
                                    ValidationMessage.required: (error) =>
                                        'Le téléphone est requis',
                                    'field_validation': (error) =>
                                        error as String,
                                  },
                                  decoration:
                                      Utils.get_default_input_decoration(
                                          'Numero de téléphone',
                                          null,
                                          null,
                                          null),
                                  style: Utils.small_bold_text_style,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20),
                          ReactiveTextField(
                            decoration: Utils.get_default_input_decoration(
                                'Ville de résidence',
                                Icons.pin_drop,
                                null,
                                null),
                            formControlName: 'ville',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'La ville de résidence est requise',
                              'field_validation': (error) => error as String,
                            },
                          ),
                          SizedBox(height: 35),
                          RouterButton(
                              destination: SignupContinue(data: form.rawValue),
                              background_color: AppColors.primary,
                              disabled: !form.valid,
                              text: "Continuer",
                              text_weight: "bold"),
                          SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              XSmallLightText(text: "Déjà inscrit ?"),
                              SizedBox(width: 5),
                              RouterButton(
                                  force_height: 20,
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

  void country_code_changed(CountryCode code) {
    Utils.log(code.toString());
    form.patchValue({"countryCode": code.toString()});
  }

  void onPressed() {}

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }
}
