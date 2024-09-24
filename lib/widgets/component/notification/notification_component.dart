// widgets/component/notification/notification_component.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/select/app_select.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/texts/big/big_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_light_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';

class NotificationComponent extends StatefulWidget {
  var notification = {};
  NotificationComponent({super.key, required this.notification});

  @override
  State<NotificationComponent> createState() => _NotificationComponentState();
}

class _NotificationComponentState extends State<NotificationComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray5, width: 1),
            color: AppColors.gray7),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* SvgPicture.asset(
              "assets/SVG/notif-repas-icon.svg", // Path to your SVG asset
              width: 30.sp,
              height: 30.sp,
              fit: BoxFit.contain,
            ),
            SizedBox(
              width: 10.sp,
            ), */
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  XSmallBoldText(text: widget.notification["titre"]),
                  SizedBox(
                    height: 5.sp,
                  ),
                  SmallRegularText(text: widget.notification["description"])
                ],
              ),
            ),
            SizedBox(
              width: 10.sp,
            ),
            SmallLightText(text: Utils.ta(widget.notification["created_at"]))
          ],
        ),
      ),
    );
  }
}
