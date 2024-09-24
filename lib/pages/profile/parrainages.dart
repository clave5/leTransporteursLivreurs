// pages/profile/parrainages.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/accueil/parrainage_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_light_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';

class Parrainages extends StatefulWidget {
  const Parrainages({super.key});

  @override
  State<Parrainages> createState() => ParrainagesState();
}

class ParrainagesState extends State<Parrainages> {
  var fileuls = [];

  late Future<void> mes_parrainer_get = Future<void>(() {});

  @override
  void dispose() {
    if (mes_parrainer_get != null) mes_parrainer_get.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Utils.log(Utils.client);

    mes_parrainer_get = get_request(
      "$API_BASE_URL/client/mes/parrainer/${Utils.client["client_id"]}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        if(mounted) setState(() {
          fileuls = response?["mesparrainer"];
        });
      },
      (error) {},
    );

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
                      text: "Parrainages",
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
        padding: EdgeInsets.all(0),
        color: AppColors.gray7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: ParrainageComponent(
                info_client: Utils.big_data?["infoClient"],
              ),
            ),
            fileuls.isEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        LargeBoldText(
                            textAlign: TextAlign.center,
                            text: "Aucune personne parrainée pour l'instant."),
                        SmallRegularText(
                            textAlign: TextAlign.center,
                            text:
                                "Veuillez parrainer à l'aide de votre code de parrainage ci-dessus pour bénéficier des réductions !"),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      LargeLightText(text: "Personnes parrainées"),
                      SizedBox(
                        height: 15.sp,
                      ),
                      ...fileuls.map((fileul) {
                        return personne_parrainee(fileul);
                      })
                    ],
                  )
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.profile),
    );
  }

  personne_parrainee(var fileul) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediumBoldText(text: "${fileul["nom"]} ${fileul["prenoms"]}"),
          SmallLightText(
              text: "parrainé le ${fileul["created_at"].split("T")[0]}"),
          SizedBox(
            height: 5.sp,
          ),
          Container(height: 1, color: AppColors.gray5),
        ],
      ),
    );
  }

  void onPressed() {}
}
