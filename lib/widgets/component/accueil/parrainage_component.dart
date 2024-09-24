// widgets/component/accueil/parrainage_component.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/messagerie.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/select/app_select.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/big/big_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_light_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';

class ParrainageComponent extends StatefulWidget {
  var info_client = {};
  ParrainageComponent({super.key, required this.info_client});

  @override
  State<ParrainageComponent> createState() => _ParrainageComponentState();
}

class _ParrainageComponentState extends State<ParrainageComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: 20.sp, bottom: 20.sp, left: 35.sp, right: 35.sp),
      child: Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 30.sp),
          decoration: BoxDecoration(
            boxShadow: [],
            image: DecorationImage(
              image: AssetImage(
                  "assets/img/parrainage-back.png"), // Replace with your image URL
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallTitreText(text: "PARRAINEZ & GAGNEZ"),
                SizedBox(
                  height: 5.sp,
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 5.sp),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.sp)),
                        child: LargeTitreText(
                            textAlign: TextAlign.center,
                            text: widget.info_client?["codeParrainage"]),
                      ),
                      SizedBox(
                        height: 20.sp,
                      ),
                      AppButton(
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: widget.info_client?["codeParrainage"]));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: AppColors.primary_light,
                                content: SmallBoldText(
                                  text: "Code de parraiage copié !",
                                )));
                          },
                          force_height: 40.sp,
                          text: "Copier mon code",
                          text_size: "small",
                          text_align: TextAlign.left,
                          text_weight: "bold",
                          padding: [0, 0, 0, 0],
                          foreground_color: AppColors.dark,
                          border_radius_size: "normal",
                          background_color: AppColors.primary_light),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
