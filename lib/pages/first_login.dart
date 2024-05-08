// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_livreur/misc/colors.dart';
import 'package:letransporteur_livreur/misc/utils.dart';
import 'package:letransporteur_livreur/pages/accueil.dart';
import 'package:letransporteur_livreur/pages/first_login.dart';
import 'package:letransporteur_livreur/pages/login.dart';
import 'package:letransporteur_livreur/pages/notifications.dart';
import 'package:letransporteur_livreur/widgets/button/router_button.dart';
import 'package:letransporteur_livreur/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_livreur/widgets/texts/medium/medium_light_text.dart';
import 'package:letransporteur_livreur/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_livreur/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class FirtsLogin extends StatefulWidget {
  const FirtsLogin({super.key});

  @override
  State<FirtsLogin> createState() => FirtsLoginState();
}

class FirtsLoginState extends State<FirtsLogin> {
  FormGroup form = FormGroup({
    'new_pass': FormControl<String>(validators: [
      Validators.required,
    ]),
    'new_pass_confirm': FormControl<String>(validators: [
      Validators.required,
    ]),
    'question': FormControl<String>(validators: [Validators.required]),
    'reponse': FormControl<String>(validators: [Validators.required]),
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
              image: AssetImage("assets/img/first-login-livreur-ill.jpg"),
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
                      text: "Première connexion",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    MediumLightText(
                        text:
                            "Choisissez votre mot de passe et une question de sécurité pour continuer.",
                        textAlign: TextAlign.center),
                    SizedBox(height: 35),
                    ReactiveForm(
                      formGroup: form,
                      child: Column(
                        children: [
                          ReactiveTextField(
                            formControlName: 'new_pass',
                            obscureText: true,
                            decoration: Utils.get_default_input_decoration(
                                'Nouveau mot de passe', Icons.lock),
                          ),
                          SizedBox(height: 10),
                          ReactiveTextField(
                            formControlName: 'new_pass_confirm',
                            obscureText: true,
                            decoration: Utils.get_default_input_decoration(
                                'Répéter mot de passe', Icons.lock),
                          ),
                          SizedBox(height: 20),
                          ReactiveDropdownField<String>(
                            formControlName: 'question',
                            isExpanded: true,
                            decoration: Utils.get_default_input_decoration(
                                'Choisissez une question de sécurité', null),
                            hint: Text('Selectionnez'),
                            items: [
                              DropdownMenuItem(
                                  value:
                                      "Quel est le nom de votre premier animal de compagnie ?",
                                  child: SmallBoldText(
                                    text:
                                        "Quel est le nom de votre premier animal de compagnie ?",
                                  )),
                              DropdownMenuItem(
                                value:
                                    "Comment s'appelle votre premier amour ?",
                                child: SmallBoldText(
                                  text:
                                      "Comment s'appelle votre premier amour ?",
                                ),
                              ),
                              DropdownMenuItem(
                                value:
                                    "Où avez vous connu votre meilleur ami ?",
                                child: SmallBoldText(
                                  text:
                                      "Où avez vous connu votre meilleur ami ?",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ReactiveTextField(
                            formControlName: 'reponse',
                            obscureText: true,
                            decoration: Utils.get_default_input_decoration(
                                'Votre réponse', null),
                          ),
                          SizedBox(height: 20),
                          RouterButton(
                              destination: Accueil(),
                              background_color: AppColors.primary,
                              text: "Continuer",
                              text_weight: "bold"),
                          SizedBox(height: 15),
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
