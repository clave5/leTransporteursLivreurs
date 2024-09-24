// pages/assistance/assistance.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/assistance/assistance_session_component.dart';
import 'package:letransporteur_client/widgets/component/assistance/faq_question_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Assistance extends StatefulWidget {
  const Assistance({super.key});

  @override
  State<Assistance> createState() => _AssistanceState();
}

class _AssistanceState extends State<Assistance> {
  FormGroup search_form = FormGroup({
    'search': FormControl<String>(validators: []),
  });

  var faqs = [];

  late Future<void> faq_get = Future<void>(() {});

  @override
  void dispose() {
    if (faq_get != null) faq_get.ignore();
    super.dispose();
  }

  @override
  void initState() {
    Utils.log(Utils.TOKEN);
    faq_get = get_request(
      "$API_BASE_URL/client/faq", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        if(mounted) setState(() {
          response = response["questionFAQ"];
          response.keys.forEach((key) {
            Utils.log(response[key]);
            faqs.add({"title": key, "questions": response[key]});
          });
        });
      },
      (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight.sp), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 0), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LargeBoldText(
                      text: "Assistance",
                      color: Utils.colorToHex(AppColors.dark)),
                  RouterButton(
                    destination: Notifications(),
                    child_type: "svgimage",
                    svg_image_size: "wx25",
                    svg_path: "assets/SVG/notif-unread.svg",
                  ),
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
        padding: EdgeInsets.all(0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            recherche(),
            faqs.isEmpty
                ? loading_component()
                : Column(
                    children: [
                      ...faqs.map((faq) {
                        return Column(
                          children: [
                            SizedBox(height: 15.sp),
                            AssistanceSessionComponent(faq: faq),
                          ],
                        );
                      })
                    ],
                  ),
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.assistance),
    );
  }

  
  loading_component() {
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

  recherche() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ReactiveForm(
        formGroup: search_form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 15.sp),
            Container(
              height: 50.sp,
              child: ReactiveTextField(
                formControlName: 'search',
                decoration: Utils.get_default_input_decoration_normal(
                    search_form.control('search'),
                    false,
                    'Tapez un terme de recherche',
                    {"icon": Icons.search, "size": 24.sp},
                    Colors.transparent,
                    AppColors.gray7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPressed() {}
}
