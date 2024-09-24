// widgets/component/other/star_rating_component.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/assistance/assistance.dart';
import 'package:letransporteur_client/pages/profile/profile.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';

class StarRatingComponent extends StatefulWidget {
  Function(int rate) onRated;
  StarRatingComponent({super.key, required this.onRated});

  @override
  State<StarRatingComponent> createState() => _StarRatingComponentState();
}

class _StarRatingComponentState extends State<StarRatingComponent> {
  var ratings = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...ratings.asMap().entries.map((map) {
          return GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() {
                  ratings = [false, false, false, false, false];
                  for (var i = 0; i < map.key + 1; i++) {
                    ratings[i] = !ratings[map.key];
                  }
                });
              }
              Future.delayed(Duration(seconds: 1), () {
                widget.onRated(map.key + 1);
              });

              //Utils.log((map, ratings));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                    size: 40.sp,
                    color: AppColors.primary,
                    ratings[map.key] == false
                        ? Icons.star_outline
                        : Icons.star_rate)),
          );
        })
      ],
    );
  }
}
