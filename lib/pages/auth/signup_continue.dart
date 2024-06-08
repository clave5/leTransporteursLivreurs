// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, prefer_interpolation_to_compose_strings

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/auth/signup.dart';
import 'package:letransporteur_client/pages/first_login.dart';
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
    'telephone': FormControl<int>(validators: [
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

  // Method to load the shared preference data
  void _load_preferences() async {
    /* final prefs = await SharedPreferences.getInstance();
    setState(() {
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
      setState(() {});
    });
    // load form values from signup
    form.patchValue(widget.data);

    //get the question securite
    setState(() {
      questions_loading = true;
    });
    get_request(
      "${API_BASE_URL}/question/securite", // API URL
      _token,
      {}, // Query parameters (if any)
      (response) {
        setState(() {
          question_securites = response["question_securite"];
          questions_loading = false;
        });
      },
      (error) {},
    );
  }

  void go_signup() {
    setState(() {
      loading = true;
    });
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
    post_request(
        "${API_BASE_URL}/auth/inscription", // API URL
        _token,
        data, // Query parameters (if any)
        (response) {
      // Success callback
      setState(() {
        loading = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Icon(Icons.check_circle, color: Colors.green[800], size: 20,),
              content: SmallLightText(text: response["message"]),
              actions: <Widget>[
                TextButton(
                  child: const Text('Continuer →'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Accueil()),
                    );
                  },
                ),
              ],
            );
          });
    }, (error) {
      // Error callback
      setState(() {
        loading = false;
      });
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
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LargeTitreText(
                      text: "Finalisez votre inscription",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    MediumLightText(
                        text:
                            "Entrez votre mot de passe et répondez à une question de sécurité.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 35),
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
                            decoration: Utils.get_default_input_decoration(
                                'Mot de passe', Icons.lock, null, null),
                          ),
                          SizedBox(height: 10),
                          ReactiveTextField(
                            formControlName: 'password_confirmation',
                            obscureText: true,
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'Le mot de passe est requis',
                              'field_validation': (error) => error as String,
                            },
                            decoration: Utils.get_default_input_decoration(
                                'Répétez mot de passe', Icons.lock, null, null),
                          ),
                          SizedBox(height: 10),
                          ReactiveDropdownField<int>(
                            isExpanded: true,
                            decoration: Utils.get_default_input_decoration(
                                'Question de sécurité', Icons.face, null, null),
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
                                  child: Text(question["libelle"]),
                                );
                              }),
                            ],
                          ),
                          SizedBox(height: 10),
                          ReactiveTextField(
                            formControlName: 'reponse_securite',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'La réponse de sécurité est requise',
                              'field_validation': (error) => error as String,
                            },
                            decoration: Utils.get_default_input_decoration(
                                'Réponse', Icons.face, null, null),
                          ),
                          SizedBox(height: 20),
                          ReactiveCheckboxListTile(
                            formControlName: 'have_parrain',
                            title: SmallBoldText(
                              text: "Utiliser un code de parrainage",
                            ),
                          ),
                          SizedBox(height: 10),
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
                                      decoration:
                                          Utils.get_default_input_decoration(
                                              'Code de parainnage',
                                              null,
                                              null,
                                              null),
                                    ));
                              }),
                          SizedBox(height: 35),
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
                          SizedBox(height: 15),
                          RouterButton(
                              force_height: 20,
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
    form.dispose();
    super.dispose();
  }
}
