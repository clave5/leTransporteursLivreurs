// pages/profile/edit_password.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => EditPasswordState();
}

class EditPasswordState extends State<EditPassword> {
  FormGroup form = FormGroup({
    'password_last': FormControl<String>(validators: [
      Validators.required,
    ]),
    'password': FormControl<String>(validators: [
      Validators.required,
    ]),
    'password_confirmation': FormControl<String>(validators: [
      Validators.required,
    ]),
  });

  bool loading = false;

  late Future<void> update_password = Future<void>(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            (kToolbarHeight + 20).sp), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 10), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Modifier mot de passe",
                      color: Utils.colorToHex(AppColors.dark)),
                  /*  RouterButton(
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
              height: 10,
            ),
            edit_profile_form()
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.profile),
    );
  }

  @override
  void dispose() {
    if (update_password != null) update_password.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    form.valueChanges.listen((element) {
      form.controls.forEach((key, value) {
        value.setErrors({});
      });
      Utils.log({"valid": form.valid, "form": element});
      if (mounted) setState(() {});
    });

    /* load_villes();
    form.controls["countryCode"]?.valueChanges.listen((event) {
      load_villes();
    }); */
  }

  edit_profile_form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            ReactiveTextField(
                formControlName: 'password_last',
                obscureText: true,
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'L\'actuel mot de passe est requis',
                  'field_validation': (error) => error as String,
                },
                decoration: Utils.get_default_input_decoration_normal(
                    form.control('password_last'),
                    false,
                    'Actuel mot de passe',
                    {"icon": Icons.face, "size": 24.sp},
                    null,
                    null),
                style: Utils.small_bold_text_style),
            SizedBox(height: 20.sp),
            ReactiveTextField(
                formControlName: 'password',
                obscureText: true,
                validationMessages: {
                  ValidationMessage.required: (error) =>
                      'Le nouveau mot de passe est requis',
                  'field_validation': (error) => error as String,
                },
                decoration: Utils.get_default_input_decoration_normal(
                    form.control('password'),
                    false,
                    'Nouveau mot de passe',
                    {"icon": Icons.face, "size": 24.sp},
                    null,
                    null),
                style: Utils.small_bold_text_style),
            SizedBox(height: 20.sp),
            ReactiveTextField(
              formControlName: 'password_confirmation',
              obscureText: true,
              validationMessages: {
                ValidationMessage.required: (error) =>
                    'Le mot de passe est requis',
                'field_validation': (error) => error as String,
              },
              decoration: Utils.get_default_input_decoration_normal(
                  form.control('password_confirmation'),
                  false,
                  'Répéter mot de passe',
                  {"icon": Icons.face, "size": 24.sp},
                  null,
                  form.control("password_confirmation").hasErrors
                      ? Colors.red
                      : null),
              style: Utils.small_bold_text_style,
            ),
            SizedBox(height: 35.sp),
            AppButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      loading = true;
                    });
                  }
                  update_password = post_request(
                      "$API_BASE_URL/auth/update/password", // API URL
                      Utils.TOKEN,
                      form.rawValue, // Query parameters (if any)
                      (response) {
                    Utils.log(response);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: AppColors.primary_light,
                        content: SmallBoldText(
                          text: response["message"],
                        )));
                    if (mounted) {
                      setState(() {
                        loading = false;
                      });
                    }
                  }, (error) {
Utils.show_toast(context, error);                    if (mounted) {
                      setState(() {
                        loading = false;
                      });
                    }
                  }, form, context);
                },
                loading: loading,
                background_color: AppColors.primary,
                disabled: !form.valid,
                text: "Enregistrer les modifications",
                text_weight: "bold"),
          ],
        ),
      ),
    );
  }

  void onPressed() {}
}
