// widgets/component/commande/commande_status_evolution_component.dart
// ignore_for_file: prefer_const_constructors// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';

class CommandeStatusEvolutionComponent extends StatefulWidget {
  var commande;
  var mode;
  CommandeStatusEvolutionComponent(
      {super.key, required this.commande, required String mode});

  @override
  State<CommandeStatusEvolutionComponent> createState() =>
      _CommandeStatusEvolutionComponentState();
}

class _CommandeStatusEvolutionComponentState
    extends State<CommandeStatusEvolutionComponent> {
  double step_width = 0;
  double step_content_width = 0;
  double step_icon_size = 50.0.sp;
  int step_count = 4;
  var suivis_map = {
    Utils.TYPE_COMMANNDES["repas"]: [
      {"message": "Réception de commande"},
      {"message": "Préparation du repas"},
      {"message": "Livraison en cours"},
      {"message": ""}
    ],
    Utils.TYPE_COMMANNDES["livraison"]: [
      {"message": "En attente d'un livreur"},
      {"message": "Ramassage en cours"},
      {"message": "En route pr. destin."},
      {"message": ""}
    ],
    Utils.TYPE_COMMANNDES["taxi"]: [
      {"message": "En attente de chauffeur"},
      {"message": "Ramassage en cours"},
      {"message": "En route pr. destin."},
      {"message": ""}
    ]
  };

  var step_progress_bar_height = 15.0.sp;

  @override
  void initState() {
    Utils.log(widget.commande);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var available_width = MediaQuery.of(context).size.width - (30 * 2).sp;
    if (widget.mode == "compact") available_width = available_width - 50.sp;
    step_width = (available_width - step_icon_size) / 3.5;
    step_content_width = step_width / 1.5;

    var steps = [];
    for (var i = 0; i < step_count; i++) {
      if (widget.commande["suivies"] != null &&
          widget.commande["suivies"].length > i) {
        steps.add(step_widget(widget.commande["suivies"][i] != null,
            widget.commande["suivies"][i], i));
      } else {
        steps.add(step_widget(
            false, suivis_map[widget.commande["type_commande_id"]]?[i], i));
      }
    }

    return Container(
      transform: Matrix4.translationValues(-10.sp, 0, 0),
      margin: EdgeInsets.only(bottom: 20.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...steps.reversed],
      ),
    );
  }

  step_widget(bool active, step_suivi, step_index) {
    return Container(
      width: step_width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(
                top: (step_icon_size / 2) - (step_progress_bar_height / 2)),
            decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.gray6,
                borderRadius: BorderRadius.all(Radius.circular(20.sp))),
            height: step_progress_bar_height,
            width: step_width - (step_width / 3),
          ),
          Positioned(
              left: (step_content_width / 2) + (step_content_width / 4),
              child: Container(
                width: step_content_width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: step_icon_size,
                      height: step_icon_size,
                      decoration: BoxDecoration(
                          color: active ? AppColors.primary : Colors.white,
                          border: active
                              ? Border.all(width: 0, color: AppColors.primary)
                              : Border.all(color: AppColors.gray4),
                          borderRadius: BorderRadius.all(
                              Radius.circular(step_icon_size))),
                      child: Icon(get_step_icon(step_index),
                          size: 30.sp,
                          color: active ? AppColors.dark : AppColors.gray4),
                    ),
                    active
                        ? XSmallBoldText(
                            text: step_suivi["message"],
                            textAlign: TextAlign.center,
                          )
                        : XSmallLightText(
                            text: step_suivi["message"],
                            textAlign: TextAlign.center,
                            color: Utils.colorToHex(AppColors.gray3),
                          )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  step_2(bool active, step_suivi) {
    return Container();
  }

  step_3(bool active, step_suivi) {
    return Container();
  }

  step_4(bool active, step_suivi) {
    return Container();
  }

  get_step_icon(step_index) {
    switch (widget.commande["type_commande_id"]) {
      //{"livraison": 1, "repas": 2, "taxi": 3};
      case 1: //livraison
        if (step_index == 0) {
          return Icons.hourglass_top;
        } else if (step_index == 1) {
          return Icons.breakfast_dining_rounded;
        } else if (step_index == 2) {
          return Icons.delivery_dining_rounded;
        } else if (step_index == 3) {
          return Icons.check;
        }
        break;
      case 2: //repas
        if (step_index == 0) {
          return Icons.hourglass_top;
        } else if (step_index == 1) {
          return Icons.restaurant;
        } else if (step_index == 2) {
          return Icons.delivery_dining;
        } else if (step_index == 3) {
          return Icons.check;
        }

        break;
      case 3: //taxi
        if (step_index == 0) {
          return Icons.hourglass_top;
        } else if (step_index == 1) {
          return Icons.electric_car;
        } else if (step_index == 2) {
          return Icons.directions_car_filled_sharp;
        } else if (step_index == 3) {
          return Icons.check;
        }

        break;
      default:
    }
  }
}
