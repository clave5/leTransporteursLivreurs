// pages/auth/signup_continue.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, prefer_interpolation_to_compose_strings// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, prefer_interpolation_to_compose_strings

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/auth/signup.dart';
import 'package:letransporteur_client/pages/auth/login.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';
import 'package:text_scroll/text_scroll.dart';

Map<String, dynamic> customValidator(AbstractControl<dynamic> control) {
  return {"field_validation": control.errors["field_validation"] != null};
}

class SignupContinue extends StatefulWidget {
  final Map<String, Object?>? data;
  const SignupContinue({super.key, required this.data});

  @override
  State<SignupContinue> createState() => SignupContinueState();
}

class SignupContinueState extends State<SignupContinue> {
  String _token = "";
  List<dynamic> question_securites = [];
  bool loading = false;
  bool questions_loading = false;

  FormGroup form = FormGroup({
    'password': FormControl<String>(validators: [Validators.required]),
    'password_confirmation':
        FormControl<String>(validators: [Validators.required]),
    'question_securite': FormControl<int>(validators: [
      Validators.required,
    ]),
    'reponse_securite': FormControl<String>(validators: [
      Validators.required,
    ]),
    'ville': FormControl<String>(validators: [
      Validators.required,
    ]),
    'have_parrain': FormControl<bool>(validators: [], value: false),
    'codeParrain': FormControl<String>(validators: []),
    'telephone': FormControl<String>(validators: [
      Validators.required,
      Validators.number(allowNegatives: false)
    ]),
    'countryCode': FormControl<String>(validators: [
      Validators.required,
    ]),
    'nom': FormControl<String>(validators: [
      Validators.required,
    ]),
    'prenoms': FormControl<String>(validators: [
      Validators.required,
    ]),
    'dateNaissance': FormControl<DateTime>(validators: [
      Validators.required,
    ]),
  });

  late Future<void> inscription_post = Future<void>(() {});

  late Future<void> question_securite_get = Future<void>(() {});

  // Method to load the shared preference data
  void _load_preferences() async {
    /* final prefs = await SharedPreferences.getInstance();
    if(mounted) setState(() {
      _token = prefs.getString('token') ?? '';
    }); */
  }

  @override
  void initState() {
    super.initState();
    _load_preferences();

    form.valueChanges.listen((element) {
      form.controls.forEach((key, value) {
        value.setErrors({});
      });
      Utils.log({
        "valid": form.valid,
        "questions_loading == true": questions_loading == true,
        "form.valid == false": form.valid == false,
        "questions_loading == true || form.valid == false":
            questions_loading == true || form.valid == false,
        "form": element
      });
      if (mounted) setState(() {});
    });
    // load form values from signup
    form.patchValue(widget.data);

    //get the question securite
    if (mounted) {
      setState(() {
        questions_loading = true;
      });
    }
    question_securite_get = get_request(
      "${API_BASE_URL}/question/securite", // API URL
      _token,
      {}, // Query parameters (if any)
      (response) {
        if (mounted) {
          setState(() {
            question_securites = response["question_securite"];
            questions_loading = false;
          });
        }
      },
      (error) {},
    );
  }

  void go_signup() {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    Map<String, Object?> data = {};
    String dateNaissance = DateFormat('yyyy-MM-dd')
        .format(form.controls["dateNaissance"]?.value as DateTime);

    //repare have_parrain
    if (form.rawValue["have_parrain"] == null) {
      form.rawValue["have_parrain"] = false;
    }

    form.rawValue.forEach((key, value) {
      if (form.rawValue["have_parrain"] != true) {
        if (!["codeParrain"].contains(key)) {
          data[key] = value;
        }
      } else {
        data[key] = value;
      }
    });
    data["dateNaissance"] = dateNaissance;
    //send request
    inscription_post = post_request(
        "${API_BASE_URL}/auth/inscription", // API URL
        _token,
        data, // Query parameters (if any)
        (response) {
      // Success callback
      if (mounted) {
        setState(() {
          loading = false;
        });
        Utils.set_token(response["data"]?["token"]);
      }
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Accueil(
                  token: Utils.TOKEN,
                )),
        (Route<dynamic> route) => false,
      );
    }, (error) {
      Utils.show_toast(context, error); // Error callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      //print(error);
      if (error is String) {
      } else if (error is Map && error["field_validation"] == true) {
        bool go_to_signup = false;
        error["response_body"]["errors"].forEach((key, value) {
          if (["nom", "prenoms", "dateNaissance", "telephone"].contains(key)) {
            go_to_signup = true;
          }
        });
        if (go_to_signup) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Signup(
                    data: form.rawValue,
                    validation_errors: error["response_body"]["errors"])),
          );
        }
      }
    }, form, context);
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
                padding:
                    EdgeInsets.symmetric(horizontal: 40.sp, vertical: 40.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LargeTitreText(
                      text: "Finalisez votre inscription",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.sp),
                    MediumLightText(
                        text:
                            "Entrez votre mot de passe et répondez à une question de sécurité.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 35.sp),
                    ReactiveForm(
                      formGroup: form,
                      child: Column(
                        children: [
                          ReactiveTextField(
                            formControlName: 'password',
                            obscureText: true,
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'Le mot de passe est requis',
                              'field_validation': (error) => error as String,
                            },
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('password'),
                                    false,
                                    'Mot de passe',
                                    {"icon": Icons.lock, "size": 24.sp},
                                    null,
                                    null),
                            style: Utils.small_bold_text_style,
                          ),
                          SizedBox(height: 10.sp),
                          ReactiveTextField(
                            formControlName: 'password_confirmation',
                            obscureText: true,
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'Le mot de passe est requis',
                              'field_validation': (error) => error as String,
                            },
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('password_confirmation'),
                                    false,
                                    'Répétez mot de passe',
                                    {"icon": Icons.lock, "size": 24.sp},
                                    null,
                                    null),
                            style: Utils.small_bold_text_style,
                          ),
                          SizedBox(height: 10.sp),
                          ReactiveDropdownField<int>(
                            isExpanded: true,
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('question_securite'),
                                    true,
                                    'Question de sécurité',
                                    {"icon": Icons.face, "size": 24.sp},
                                    null,
                                    null),
                            style: Utils.small_bold_text_style,
                            formControlName: 'question_securite',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'La question de sécurité est requise',
                              'field_validation': (error) => error as String,
                            },
                            hint: Text('Question de sécurité'),
                            items: [
                              ...question_securites.map((question) {
                                return DropdownMenuItem(
                                  value: question["id"],
                                  child: Row(
                                    children: [
                                      Text("👉🏻 "),
                                      Flexible(
                                        child: TextScroll(
                                          question["libelle"],
                                          
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                          SizedBox(height: 10.sp),
                          ReactiveTextField(
                            formControlName: 'reponse_securite',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'La réponse de sécurité est requise',
                              'field_validation': (error) => error as String,
                            },
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('reponse_securite'),
                                    false,
                                    'Réponse',
                                    {"icon": Icons.face, "size": 24.sp},
                                    null,
                                    null),
                            style: Utils.small_bold_text_style,
                          ),
                          SizedBox(height: 20.sp),
                          ReactiveCheckboxListTile(
                            formControlName: 'have_parrain',
                            title: SmallBoldText(
                              text: "Utiliser un code de parrainage",
                            ),
                          ),
                          SizedBox(height: 10.sp),
                          ReactiveValueListenableBuilder(
                              formControlName: "have_parrain",
                              builder: (context, control, child) {
                                return Visibility(
                                    visible: control.value == true,
                                    child: ReactiveTextField(
                                      formControlName: 'codeParrain',
                                      validationMessages: {
                                        'field_validation': (error) =>
                                            error as String,
                                      },
                                      decoration: Utils
                                          .get_default_input_decoration_normal(
                                              form.control('codeParrain'),
                                              false,
                                              'Code de parainnage',
                                              null,
                                              null,
                                              null),
                                      style: Utils.small_bold_text_style,
                                    ));
                              }),
                          SizedBox(height: 35.sp),
                          AppButton(
                              disabled: questions_loading == true ||
                                  form.valid == false,
                              loading: loading,
                              onPressed: () {
                                go_signup();
                              },
                              background_color: AppColors.primary,
                              text: "Terminer",
                              text_weight: "bold"),
                          SizedBox(height: 15.sp),
                          RouterButton(
                              force_height: 40.sp,
                              padding: [0, 0, 0, 0],
                              destination: Signup(data: form.rawValue),
                              text_size: "small",
                              text_weight: "bold",
                              text: "← Modifier mes informations"),
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

  void onPressed() {}

  @override
  void dispose() {
    if (question_securite_get != null) question_securite_get.ignore();
    if (inscription_post != null) inscription_post.ignore();
    form.dispose();
    super.dispose();
  }
}
