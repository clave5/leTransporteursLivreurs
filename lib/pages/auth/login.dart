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
import 'package:letransporteur_client/pages/auth/signup.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  FormGroup form = FormGroup({
    'telephone': FormControl<String>(validators: [
      Validators.required,
      Validators.number(allowNegatives: false)
    ], value: ""), //56341683
    'password': FormControl<String>(validators: [
      Validators.required,
    ], value: ""), //wwwwwwww
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

    Utils.big_data = {};

    //go_login();

    /* load_villes();
    form.controls["countryCode"]?.valueChanges.listen((event) {
      load_villes();
    }); */
  }

  void go_login() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    Map<String, Object?> data = form.rawValue;
    //send request
    login_post = post_request(
        "${API_BASE_URL}/auth/login", // API URL
        _token,
        data, // Query parameters (if any)
        (response) {
      // Success callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }

      Utils.set_token(response["data"]["token"]);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Accueil(token: Utils.TOKEN)),
        (Route<dynamic> route) => false,
      );
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
                padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 40.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LargeTitreText(
                      text: "Connectez-vous",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.sp),
                    MediumLightText(
                        text:
                            "Entrez vos identifiants ci-dessous pour accéder à vote compte.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 35.sp),
                    ReactiveForm(
                      formGroup: form,
                      child: Column(
                        children: [
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
                            onChanged: (phone) {
                              Utils.log(phone);
                              if (mounted) {
                                setState(() {
                                  try {
                                    phone_valid = phone.isValidNumber();
                                  } on Exception catch (e) {
                                    phone_valid = false;
                                  }
                                  form.patchValue({"telephone": phone.completeNumber});
                                });
                              }
                            },
                          ),
                          SizedBox(height: 15.sp),
                          ReactiveTextField(
                            formControlName: 'password',
                            obscureText: true,
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                    form.control('password'),
                                    false,
                                    'Mot de passe',
                                    {"icon": Icons.lock, "size": 24.sp},
                                    null,
                                    null),
                          ),
                          SizedBox(height: 5.sp),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Spacer(),
                              RouterButton(
                                  force_height: 40.sp,
                                  padding: [0, 0, 0, 0],
                                  destination: ForgotPass(),
                                  text_size: "xsmall",
                                  text_weight: "bold",
                                  text: "Mot de passe oublié ?"),
                            ],
                          ),
                          SizedBox(height: 20.sp),
                          AppButton(
                              onPressed: () {
                                go_login();
                              },
                              disabled: !form.valid || !phone_valid,
                              background_color: AppColors.primary,
                              loading: loading,
                              text: "Connexion",
                              text_weight: "bold"),
                          SizedBox(height: 15.sp),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              XSmallLightText(text: "Pas encore de compte ?"),
                              SizedBox(width: 5),
                              RouterButton(
                                  destination: Signup(),
                                  text_size: "xsmall",
                                  text_weight: "bold",
                                  text: "Créez-en un"),
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

  void onPressed() {}

  @override
  void dispose() {
    if (login_post != null) login_post.ignore();
    form.dispose();
    super.dispose();
  }
}
