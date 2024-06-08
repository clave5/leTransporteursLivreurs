// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/input/input_box_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/component/other/info_box_component.dart';
import 'package:letransporteur_client/widgets/map/map_picker_screen.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CommandeLivraison extends StatefulWidget {
  const CommandeLivraison({super.key});

  @override
  State<CommandeLivraison> createState() => CommandeLivraisonState();
}

class CommandeLivraisonState extends State<CommandeLivraison> {
  int step_index = 0;
  FormGroup form = FormGroup({
    'lieu_recup': FormControl<int>(validators: [
      Validators.required,
    ]),
    'contact_recup': FormControl<String>(validators: [
      Validators.number(allowNegatives: false),
      Validators.required,
    ]),
    'lieu_dest': FormControl<int>(validators: [
      Validators.required,
    ]),
    'contact_dest': FormControl<String>(validators: [
      Validators.number(allowNegatives: false),
      Validators.required,
    ]),
  });

  Widget get_step_1() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ReactiveForm(
        formGroup: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            ReactiveTextField(
              formControlName: 'lieu_recup',
              obscureText: true,
              decoration: Utils.get_default_input_decoration(
                  'Lieu de récupération',
                  Icons.pin_drop,
                  Colors.transparent,
                  AppColors.gray7),
              onTap: (control) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MapPickerScreen()),
                );
              },
            ),
            SizedBox(height: 15),
            ReactiveTextField(
              formControlName: 'contact_recup',
              keyboardType: TextInputType.phone,
              decoration: Utils.get_default_input_decoration(
                  'Contact de récupération', Icons.phone, Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 25),
            ReactiveTextField(
              formControlName: 'lieu_dest',
              keyboardType: TextInputType.phone,
              decoration: Utils.get_default_input_decoration(
                  'Lieu de livraison', Icons.pin_drop, Colors.transparent,
                  AppColors.gray7),
              style: Utils.small_bold_text_style,
              onTap: (control) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MapPickerScreen()),
                );
              },
            ),
            SizedBox(height: 15),
            ReactiveTextField(
              formControlName: 'contact_dest',
              obscureText: true,
              decoration: Utils.get_default_input_decoration(
                  'Lieu de livraison', Icons.phone, Colors.transparent,
                  AppColors.gray7),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 20), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 10), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Commande Livraison",
                      color: Utils.colorToHex(AppColors.dark)),
                  Image(
                    image: AssetImage('assets/img/livraison-repas-bike.png'),
                    height: 40,
                  )
                ],
              ),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Set the radius here
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: step_index,
                onStepTapped: (int step) {
                  setState(() {
                    step_index = step;
                  });
                },
                onStepContinue: step_index < 3
                    ? () {
                        setState(() {
                          step_index += 1;
                        });
                      }
                    : null,
                onStepCancel: step_index > 0
                    ? () {
                        setState(() {
                          step_index -= 1;
                        });
                      }
                    : null,
                steps: <Step>[
                  Step(
                    title: SmallTitreText(
                        text: step_index == 0 ? "Emplacement" : ""),
                    content: get_step_1(),
                    isActive: step_index >= 0,
                    state: step_index >= 0
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: SmallTitreText(
                        text: step_index == 1 ? "Tarif livraison" : ""),
                    content: Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Content for Step 2')),
                    isActive: step_index >= 1,
                    state: step_index >= 1
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title:
                        SmallTitreText(text: step_index == 2 ? "Paiement" : ""),
                    content: Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Content for Step 3')),
                    isActive: step_index >= 2,
                    state: step_index >= 2
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.profile),
    );
  }

  void onPressed() {}
}
