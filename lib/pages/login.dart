// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_livreur/misc/colors.dart';
import 'package:letransporteur_livreur/misc/utils.dart';
import 'package:letransporteur_livreur/pages/accueil.dart';
import 'package:letransporteur_livreur/pages/first_login.dart';
import 'package:letransporteur_livreur/pages/notifications.dart';
import 'package:letransporteur_livreur/widgets/button/router_button.dart';
import 'package:letransporteur_livreur/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_livreur/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_livreur/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  FormGroup form = FormGroup({
    'phone': FormControl<int>(validators: [
      Validators.required,
      Validators.number(allowNegatives: false)
    ]),
    'pass': FormControl<String>(validators: [
      Validators.required,
    ]),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [],
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/img/login-livreur-ill.jpg"),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3,
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
                      text: "Connectez-vous",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    MediumLightText(
                        text:
                            "Entrez vos identifiants ci-dessous pour accéder à vote compte.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 35),
                    ReactiveForm(
                      formGroup: form,
                      child: Column(
                        children: [
                          ReactiveTextField(
                            formControlName: 'phone',
                            keyboardType: TextInputType.phone,
                            decoration: Utils.get_default_input_decoration(
                                'Numero de téléphone', Icons.phone),
                            style: Utils.small_bold_text_style,
                          ),
                          SizedBox(height: 15),
                          ReactiveTextField(
                            formControlName: 'pass',
                            obscureText: true,
                            decoration: Utils.get_default_input_decoration(
                                'Mot de passe', Icons.lock),
                          ),
                          SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Spacer(),
                              RouterButton(
                                  force_height: 20,
                                  padding: [0, 0, 0, 0],
                                  destination: FirtsLogin(),
                                  text_size: "xsmall",
                                  text_weight: "bold",
                                  text: "Mot de passe oublié ?"),
                            ],
                          ),
                          SizedBox(height: 20),
                          RouterButton(
                              destination: FirtsLogin(),
                              background_color: AppColors.primary,
                              text: "Connexion",
                              text_weight: "bold"),
                          SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              XSmallLightText(text: "Pas encore de compte ?"),
                              SizedBox(width: 5),
                              RouterButton(
                                  force_height: 20,
                                  padding: [0, 0, 0, 0],
                                  destination: FirtsLogin(),
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
}
