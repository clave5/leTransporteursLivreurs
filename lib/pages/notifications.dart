// pages/notifications.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/api/firebase_api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/notification/notification_component.dart';
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
    'dateDebut': FormControl<String>(validators: []),
    'dateFin': FormControl<String>(validators: []),
  });

  var notifications = [];

  bool loading_notifications = false;

  late Future<void> notification_periode_post = Future<void>(() {});

  late Future<void> notification_get = Future<void>(() {});

  @override
  void initState() {
    super.initState();
    FirebaseApi().init_notification();
    initData();
  }

  @override
  void dispose() {
    if (notification_periode_post != null) notification_periode_post.ignore();
    if (notification_get != null) notification_get.ignore();
    super.dispose();
  }

  void initData() {
    Utils.log(Utils.TOKEN);
    if (mounted) {
      setState(() {
        loading_notifications = true;
      });
    }
    notification_get = get_request(
      "$API_BASE_URL/client/notification/${Utils.big_data?["infoClient"]?["client_id"]}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        if (mounted) {
          setState(() {
            loading_notifications = false;
            notifications = response["notification"];
          });
        }
      },
      (error) {
Utils.show_toast(context, error);        if (mounted) {
          setState(() {
            loading_notifications = false;
          });
        }
      },
    );

    form.valueChanges.listen((element) {
      Utils.log(form.rawValue);
      if (form.rawValue["dateDebut"] != null &&
          form.rawValue["dateFin"] != null) {
        if (mounted) {
          setState(() {
            loading_notifications = true;
          });
        }
        notification_periode_post = post_request(
            "$API_BASE_URL/client/notification/periode", // API URL
            Utils.TOKEN,
            {
              "client_id": Utils.client["client_id"],
              "dateDebut": (form.rawValue["dateDebut"] as String).split("T")[0],
              "dateFin": (form.rawValue["dateFin"] as String).split("T")[0],
            }, // Query parameters (if any)
            (response) {
          Utils.log(response);
          if (mounted) {
            setState(() {
              notifications = response["data"];
              loading_notifications = false;
            });
          }
        }, (error) {
Utils.show_toast(context, error);          if (mounted) {
            setState(() {
              loading_notifications = false;
            });
          }
        }, null, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            (kToolbarHeight + 20).sp), // Adjust height as needed
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
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
                height: 15.sp,
              ),
              loading_notifications
                  ? loading_notifications_component()
                  : notifications.isEmpty
                      ? SmallRegularText(
                          text: "Pas de notifications pour le moment.")
                      : Column(
                          children: [
                            ...notifications.map((notification) {
                              return Column(
                                children: [
                                  NotificationComponent(
                                      notification: notification),
                                  SizedBox(
                                    height: 15.sp,
                                  ),
                                ],
                              );
                            })
                          ],
                        )
            ],
          ),
        )),
      ),
      /* bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.assistance), */
    );
  }

  loading_notifications_component() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 40.sp,
          ),
          SvgPicture.asset(
            "assets/SVG/activite-menu-stroke-icon.svg",
            height: 100,
            width: 100,
            fit: BoxFit.contain,
            color: AppColors.gray5,
          ),
          SizedBox(
            height: 10,
          ),
          SmallLightText(
            text: "Chargement",
            color: Utils.colorToHex(AppColors.gray3),
          )
        ],
      ),
    );
  }

  date_filter() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.sp,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ReactiveForm(
                formGroup: form,
                child: Row(
                  children: [
                    SizedBox(
                      height: 50.sp,
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
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                        form.control('dateDebut'),
                                        false,
                                        'Date de début',
                                        {
                                          "icon": Icons.calendar_today_rounded,
                                          "size": 24.sp
                                        },
                                        null,
                                        AppColors.gray5)
                                    .copyWith(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 10)),
                            style: Utils.small_bold_text_style,
                          );
                        },
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      ),
                    ),
                    SizedBox(
                      width: 10.sp,
                    ),
                    SizedBox(
                      height: 50.sp,
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
                            decoration:
                                Utils.get_default_input_decoration_normal(
                                        form.control('dateFin'),
                                        false,
                                        'Date de fin',
                                        {
                                          "icon": Icons.calendar_today_rounded,
                                          "size": 24.sp
                                        },
                                        null,
                                        AppColors.gray5)
                                    .copyWith(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 10)),
                            style: Utils.small_bold_text_style,
                          );
                        },
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      ),
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  category_filters() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
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
              SingleChildScrollView(
                child: GroupButton(
                  buttons: get_notification_categories(),
                  onSelected: (value, index, isSelected) {},
                  buttonBuilder: (selected, categorie, context) {
                    return Container(
                      decoration: BoxDecoration(
                          color: selected == true
                              ? Colors.white
                              : AppColors.primary_light,
                          borderRadius: BorderRadius.circular(100)),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          (categorie as dynamic)["icon"] ?? Container(),
                          (categorie as dynamic)["icon"] != null
                              ? SizedBox(
                                  width: 25.sp,
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
              ),
            ],
          ),
        ));
  }

  get_notification_categories() {
    return [
      {"icon": null, "text": "Tout"},
      {"icon": Icon(Icons.list), "text": "Activités"},
      {"icon": Icon(Icons.check_circle), "text": "Flash news"}
    ];
  }

  Future<void> _refresh() async {
    initData();
  }

  void onPressed() {}
}
