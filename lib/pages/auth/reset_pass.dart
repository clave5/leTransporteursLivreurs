// pages/auth/login.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps

import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/auth/forgot_pass.dart';
import 'package:letransporteur_client/pages/auth/login.dart';
import 'package:letransporteur_client/pages/auth/signup.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ResetPass extends StatefulWidget {
  var telephone;
  var question_securite;
  var question_securite_id;

  ResetPass(
      {super.key,
      required this.telephone,
      required this.question_securite,
      required this.question_securite_id});

  @override
  State<ResetPass> createState() => ResetPassState();
}

class ResetPassState extends State<ResetPass> {
  FormGroup form = FormGroup({
    'telephone': FormControl<String>(validators: [
      Validators.required,
    ], value: ""), //56341683
    'password': FormControl<String>(validators: [Validators.required]),
    'password_confirmation':
        FormControl<String>(validators: [Validators.required]),
    'reponse_securite': FormControl<String>(validators: [
      Validators.required,
    ]),
  });
  bool loading = false;
  String _token = "";
  bool phone_valid = false;

  late Future<void> login_post = Future<void>(() {});

  @override
  void initState() {
    super.initState();

    form.valueChanges.listen((element) {
      form.controls.forEach((key, value) {
        value.setErrors({});
      });
      Utils.log(
          {"valid": form.valid, "form": element, "phone_valid": phone_valid});
      if (mounted) setState(() {});
    });

    form.patchValue({"telephone": widget.telephone});
  }

  void go_forgot() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    Map<String, Object?> data = form.rawValue;
    //send request
    login_post = post_request(
        "${API_BASE_URL}/auth/change/password/forget", // API URL
        _token,
        data, // Query parameters (if any)
        (response) {
      // Success callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      if (response["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: AppColors.primary_light,
            content: SmallBoldText(
              text:
                  'Mot de passe bien réinitialisé. Veuillez vous connecter à présent.',
            )));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppColors.primary_light,
            content: SmallBoldText(text: response["message"])));
      }
    }, (error) {
Utils.show_toast(context, error);      // Error callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      //print(error);
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
                      text: "Compte trouvé !",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.sp),
                    SmallRegularText(
                        text: "Répondez à votre question de sécurité.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 15.sp),
                    LargeBoldText(
                        text: widget.question_securite,
                        textAlign: TextAlign.center),
                    SizedBox(height: 20.sp),
                    ReactiveForm(
                      formGroup: form,
                      child: Column(
                        children: [
                          ReactiveTextField(
                            formControlName: 'reponse_securite',
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  'La réponse est requise',
                              'field_validation': (error) => error as String,
                            },
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('reponse_securite'),
                                    false,
                                    'Réponse de sécurite',
                                    null,
                                    null,
                                    null),
                            style: Utils.small_bold_text_style,
                          ),
                          SizedBox(height: 25.sp),
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
                                    'Nouveau mot de passe',
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
                          SizedBox(height: 20.sp),
                          AppButton(
                              onPressed: () {
                                go_forgot();
                              },
                              disabled: !form.valid,
                              background_color: AppColors.primary,
                              loading: loading,
                              text: "Continuer",
                              text_weight: "bold"),
                          SizedBox(height: 15.sp),
                          RouterButton(
                              force_height: 40.sp,
                              padding: [0, 0, 0, 0],
                              destination: ForgotPass(),
                              text_size: "small",
                              text_weight: "bold",
                              text: "← Retour"),
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
    if (login_post != null) login_post.ignore();
    form.dispose();
    super.dispose();
  }
}
