// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/notifications/notification_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  FormGroup form = FormGroup({
    'dateDebut': FormControl<String>(validators: [
    ]),
    'dateFin': FormControl<String>(validators: [
    ]),
  });

  @override
  void initState() {
    Utils.log(Utils.TOKEN);
    get_request(
      "$API_BASE_URL/client/notification/79", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        setState(() {});
      },
      (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 20), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 0), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Notifications",
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
            category_filters(),
            date_filter(),
            SizedBox(
              height: 15,
            ),
            NotificationComponent(),
            SizedBox(
              height: 15,
            ),
            NotificationComponent(),
            SizedBox(
              height: 15,
            ),
            NotificationComponent(),
            SizedBox(
              height: 15,
            ),
            NotificationComponent(),
            SizedBox(
              height: 15,
            ),
            NotificationComponent(),
            SizedBox(
              height: 15,
            ),
            NotificationComponent(),
          ],
        ),
      )),
      /* bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.assistance), */
    );
  }

  date_filter() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmallBoldText(text: "Sélectionnez une période"),
          SizedBox(
            height: 10,
          ),
          ReactiveForm(
              formGroup: form,
              child: Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: ReactiveDatePicker(
                      formControlName: 'dateDebut',
                      builder: (context, picker, child) {
                        return ReactiveTextField(
                          readOnly: true,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                'La date de début est requise',
                            'field_validation': (error) => error as String,
                          },
                          onTap: (control) => {picker.showPicker()},
                          formControlName: 'dateDebut',
                          decoration: Utils.get_default_input_decoration(
                              'Date de début',
                              Icons.calendar_today_rounded,
                              null,
                              AppColors.gray5),
                          style: Utils.small_bold_text_style,
                        );
                      },
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: ReactiveDatePicker(
                      formControlName: 'dateFin',
                      builder: (context, picker, child) {
                        return ReactiveTextField(
                          readOnly: true,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                'La date de fin est requise',
                            'field_validation': (error) => error as String,
                          },
                          onTap: (control) => {picker.showPicker()},
                          formControlName: 'dateFin',
                          decoration: Utils.get_default_input_decoration(
                              'Date de fin',
                              Icons.calendar_today_rounded,
                              null,
                              AppColors.gray5),
                          style: Utils.small_bold_text_style,
                        );
                      },
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  category_filters() {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20), // Set the radius here
        ),
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GroupButton(
            buttons: get_notification_categories(),
            onSelected: (value, index, isSelected) {},
            buttonBuilder: (selected, categorie, context) {
              return Container(
                decoration: BoxDecoration(
                    color: selected == true
                        ? Colors.white
                        : AppColors.primary_light,
                    borderRadius: BorderRadius.circular(100)),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  children: [
                    (categorie as dynamic)["icon"] ?? Container(),
                    (categorie as dynamic)["icon"] != null
                        ? SizedBox(
                            width: 5,
                          )
                        : SizedBox(
                            width: 0,
                          ),
                    SmallBoldText(text: (categorie as dynamic)["text"]),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  get_notification_categories() {
    return [
      {"icon": null, "text": "Tout"},
      {"icon": Icon(Icons.list), "text": "Activités"},
      {"icon": Icon(Icons.check_circle), "text": "Flash news"}
    ];
  }

  void onPressed() {}
}
