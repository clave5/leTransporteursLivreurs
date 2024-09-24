// pages/profile/edit_preferences.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EditPreferences extends StatefulWidget {
  const EditPreferences({super.key});

  @override
  State<EditPreferences> createState() => EditPreferencesState();
}

class EditPreferencesState extends State<EditPreferences> {
  FormGroup form = FormGroup({
    'langue': FormControl<String>(validators: [
      Validators.required,
    ]),
    'notifications': FormControl<String>(validators: [
      Validators.required,
    ]),
  });

  @override
  void initState() {
    super.initState();

    form.valueChanges.listen((element) {
      form.controls.forEach((key, value) {
        value.setErrors({});
      });
      Utils.log({"valid": form.valid, "form": element});
      if(mounted) setState(() {});
    });

    /* load_villes();
    form.controls["countryCode"]?.valueChanges.listen((event) {
      load_villes();
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight((kToolbarHeight + 20).sp), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 10), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Préférences du compte",
                      color: Utils.colorToHex(AppColors.dark)),
                  /* RouterButton(
                    destination: Notifications(),
                    child_type: "svgimage",
                    svg_image_size: "wx25",
                    svg_path: "assets/SVG/notif-unread.svg",
                  ), */
                ],
              ),
            ),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Set the radius here
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 5.sp,
            ),
            edit_profile_form()
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.profile),
    );
  }

  edit_profile_form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            SizedBox(height: 20.sp),
            ReactiveDropdownField(
              items: [
                DropdownMenuItem(
                  value: 'Français',
                  child: SmallBoldText(
                    text: "Français",
                  ),
                ),
                DropdownMenuItem(
                  value: 'English',
                  child: SmallBoldText(
                    text: "English",
                  ),
                ),
              ],
              decoration: Utils.get_default_input_decoration_normal(
                  form.control('langue'),
                  true,
                  'Choissez votre langue',
                  {"icon": Icons.translate, "size": 24.sp},
                  null,
                  null),
              formControlName: 'langue',
              validationMessages: {
                'field_validation': (error) => error as String,
              },
            ),
            SizedBox(height: 35.sp),
            /* AppButton(
                onPressed: () {},
                background_color: AppColors.primary,
                disabled: !form.valid,
                text: "Enregistrer les modifications",
                text_weight: "bold"), */
            Container(
                height: 10,
                margin: EdgeInsets.only(top: 30),
                color: AppColors.gray6),
            supprimer_compte(),
          ],
        ),
      ),
    );
  }

  supprimer_compte() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 60,
        child: Row(
          children: [
            Icon(
              Icons.logout,
              size: 25,
              color: Colors.red,
            ),
            SizedBox(
              width: 10.sp,
            ),
            MediumBoldText(text: "Supprimer mon compte"),
            Spacer(),
            AppButton(
                onPressed: () {
                  Utils.log("go");
                },
                child_type: "icon",
                icon_size: "25x25",
                foreground_color: Colors.red,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: AppColors.gray4,
                ),
                background_color: AppColors.transparent),
            SizedBox(
              width: 25.sp,
            )
          ],
        ),
      ),
    );
  }

  void onPressed() {}
}
