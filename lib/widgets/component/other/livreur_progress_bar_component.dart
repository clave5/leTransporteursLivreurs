// widgets/component/other/livreur_progress_bar_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';

class LivreurProgressBarComponent extends StatefulWidget {
  int step;
  ValueChanged<int> stepChanged;
  LivreurProgressBarComponent({
    super.key,
    this.step = 1,
    required this.stepChanged,
  });

  @override
  State<LivreurProgressBarComponent> createState() =>
      _LivreurProgressBarComponentState();
}

class _LivreurProgressBarComponentState
    extends State<LivreurProgressBarComponent> {
  get_step_title_widget() {
    var step_title_text;
    switch (widget.step) {
      case 1:
        step_title_text = SmallBoldText(text: "Ramassage en cours");
        break;
      case 2:
        step_title_text = SmallBoldText(text: "Ramassage colis en cours");
        break;
      case 3:
        step_title_text = SmallBoldText(text: "Livraison en cours");
        break;
      case 4:
        step_title_text = SmallBoldText(text: "Livraison effectuée");
        break;
      default:
        break;
    }
    return Row(children: [
      get_step_title_svg_path(),
      SizedBox(width: 5),
      step_title_text
    ]);
  }

  get_step_title_svg_path() {
    var step_title_icon;
    switch (widget.step) {
      case 1:
        step_title_icon = "assets/SVG/step-ramassage.svg";
        break;
      case 2:
        step_title_icon = "assets/SVG/step-ramassage-colis.svg";
        break;
      case 3:
        step_title_icon = "assets/SVG/step-livraison.svg";
        break;
      case 4:
        step_title_icon = "assets/SVG/circle_check.svg";
        break;
      default:
        break;
    }
    return SvgPicture.asset(
      step_title_icon, // Path to your SVG asset
      width: 15.sp,
      height: 15.sp,
      color: AppColors.gray2,
    );
  }

  get_step_color() {
    Color step_color = Colors.black;
    switch (widget.step) {
      case 1:
        step_color = AppColors.gray3;
        break;
      case 2:
        step_color = AppColors.gray2;
        break;
      case 3:
        step_color = Colors.orange;
        break;
      case 4:
        step_color = Colors.green;
        break;
      default:
        break;
    }
    return step_color;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(mounted) setState(() {
          if (widget.step == 4) {
            widget.step = 1;
          } else {
            widget.step++;
          }
          print('step: ${widget.step}');
          widget.stepChanged(widget.step);
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 5.sp),
                child: get_step_title_widget()),
            SizedBox(height: 5.sp),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                FractionallySizedBox(
                  widthFactor: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          color: widget.step >= 4
                              ? get_step_color()
                              : AppColors.gray5,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                          )),
                      child: SizedBox(
                        height: 15.sp,
                        width: 30.sp,
                      )),
                ),
                FractionallySizedBox(
                  widthFactor: 0.75,
                  child: Container(
                      decoration: BoxDecoration(
                          color: widget.step >= 3
                              ? get_step_color()
                              : AppColors.gray5,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                          )),
                      child: SizedBox(
                        height: 15.sp,
                        width: 30.sp,
                      )),
                ),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                      decoration: BoxDecoration(
                          color: widget.step >= 2
                              ? get_step_color()
                              : AppColors.gray5,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                          )),
                      child: SizedBox(
                        height: 15.sp,
                        width: 30.sp,
                      )),
                ),
                FractionallySizedBox(
                  widthFactor: 0.25,
                  child: Container(
                      decoration: BoxDecoration(
                          color: widget.step >= 1
                              ? get_step_color()
                              : AppColors.gray5,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                          )),
                      child: SizedBox(
                        height: 15.sp,
                        width: 30.sp,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
