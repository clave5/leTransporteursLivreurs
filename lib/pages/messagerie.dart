// pages/messagerie.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
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
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Messagerie extends StatefulWidget {
  var client_commande;
  Messagerie({super.key, required this.client_commande});

  @override
  State<Messagerie> createState() => MessagerieState();
}

class MessagerieState extends State<Messagerie> {
  FormGroup chat_form = FormGroup({
    'expediteur_id': FormControl<String>(validators: [], value: ""),
    'destinateur_id': FormControl<String>(validators: [], value: ""),
    'commande_id': FormControl<String>(validators: [], value: ""),
    'is_client': FormControl<String>(validators: [], value: ""),
    'contenu': FormControl<String>(validators: [], value: ""),
  });

  bool loading = false;

  bool send_btn_pressed = false;

  Future<void> send_message_request = Future<void>(() {});

  var message_to_send = "";

  var messages = [];

  Timer? timer;
  final ScrollController scroll_controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    Utils.log(widget.client_commande);
    chat_form.valueChanges.listen((element) {
      chat_form.controls.forEach((key, value) {
        value.setErrors({});
      });
      setState(() {
        message_to_send = chat_form.control("contenu").value;
      });
      Utils.log(message_to_send);
    });

    chat_form.patchValue({
      "expediteur_id": "${Utils.client["client_id"]}",
      "destinateur_id": "${widget.client_commande["livreur_id"]}",
      "commande_id": "${widget.client_commande["id"]}",
      "is_client": "1",
    });

    refresh_chat(false);
    timer = Timer.periodic(new Duration(seconds: 60), (timer) {
      refresh_chat(true);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    refresh_chat(true);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refresh,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                kToolbarHeight.sp + 20.sp), // Adjust height as needed
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.sp), // Add bottom padding
              child: AppBar(
                title: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LargeBoldText(
                          text:
                              "${widget.client_commande["livreur_prenoms"]} ${widget.client_commande["livreur_nom"]}",
                          color: Utils.colorToHex(AppColors.dark)),
                      AppButton(
                        onPressed: () {
                          launch_livreur_phone();
                        },
                        child_type: "icon",
                        icon: Icon(
                          Icons.phone,
                          size: 25.sp,
                          color: Colors.white,
                        ),
                        icon_size: "normal",
                        text: "",
                        with_text: true,
                        foreground_color: Colors.white,
                        background_color: AppColors.dark,
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
          body: loading
              ? loading_commandes_component()
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height:
                      MediaQuery.of(context).size.height, // Full screen height
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: scroll_controller,
                        child: messages_list(),
                      ),
                      Positioned(bottom: 0, child: chat_input())
                    ],
                  ),
                ),
        ));
  }

  loading_commandes_component() {
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

  Future<void> launch_livreur_phone() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: widget.client_commande["livreur_telephone"],
    );
    try {
      UrlLauncher.launchUrl(launchUri);
    } on Exception catch (e) {
      // TODO
    }
  }

  messages_list() {
    return Container(
      padding:
          EdgeInsets.only(top: 20.sp, left: 20.sp, right: 20.sp, bottom: 85.sp),
      child: Column(
        children: [
          ...messages.map((message) {
            return Container(
              margin: EdgeInsets.only(bottom: 20.sp),
              child: message["expediteur_id"] == Utils.client["client_id"]
                  ? self_message(message)
                  : foreign_message(message),
            );
          }).toList()
        ],
      ),
    );
  }

  foreign_message(message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).size.width - 40).sp - 80.sp),
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
              color: AppColors.gray6,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  bottomRight: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp))),
          child: SmallRegularText(
            text: message["contenu"],
          ),
        ),
        SizedBox(
          width: 10.sp,
        ),
        Container(
            margin: EdgeInsets.only(bottom: 10.sp),
            child: SmallLightText(
              text: Utils.ta(message["created_at"]),
              color: Utils.colorToHex(AppColors.gray3),
            ))
      ],
    );
  }

  self_message(message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Spacer(),
        Container(
            margin: EdgeInsets.only(bottom: 10.sp),
            child: SmallLightText(
              text: Utils.ta(message["created_at"]),
              color: Utils.colorToHex(AppColors.gray3),
            )),
        SizedBox(
          width: 10.sp,
        ),
        Container(
          constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).size.width - 40).sp - 80.sp),
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  bottomLeft: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp))),
          child: SmallRegularText(
            text: message["contenu"],
          ),
        ),
      ],
    );
  }

  chat_input() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(15.sp),
      child: ReactiveForm(
        formGroup: chat_form,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: (MediaQuery.of(context).size.width.sp - 30.sp) - 55.sp,
              height: 65.sp,
              child: ReactiveTextField(
                style: TextStyle(height: 1.5.sp),
                formControlName: 'contenu',
                decoration: Utils.get_chat_input_decoration('Tapez un message'),
              ),
            ),
            Opacity(
              opacity: message_to_send != "" ? 1 : 0.4,
              child: GestureDetector(
                onTap: () {
                  if (message_to_send != "") send_message();
                },
                onTapDown: (details) {
                  if (message_to_send != "") {
                    setState(() {
                      send_btn_pressed = true;
                    });
                  }
                },
                onTapUp: (details) {
                  if (message_to_send != "") {
                    setState(() {
                      send_btn_pressed = false;
                    });
                  }
                },
                child: Container(
                  transform: Matrix4.translationValues(-1, 0, 0),
                  height: 65.sp,
                  width: 65.sp,
                  decoration: BoxDecoration(
                      color:
                          send_btn_pressed ? AppColors.dark : AppColors.primary,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.sp),
                          bottomRight: Radius.circular(5.sp)),
                      border: Border.all(color: AppColors.dark, width: 1)),
                  child: Icon(
                    Icons.send,
                    color: send_btn_pressed ? Colors.white : AppColors.dark,
                    size: 30.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  send_message() {
    Map<String, Object?> data = chat_form.rawValue;

    if (mounted) {
      setState(() {
        loading = true;
        chat_form.patchValue({"contenu": ""});
      });
    }
    //send request
    send_message_request = post_request(
        "${API_BASE_URL}/message/store", // API URL
        Utils.TOKEN,
        data, // Query parameters (if any)
        (response) {
      // Success callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      if (response["status"] == true) {
        refresh_chat(true);
      } else {
        launch_dialog(context, response["message"], null);
      }
    }, (error) {
Utils.show_toast(context, error);      // Error callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      //print(error);
    }, chat_form, context);
  }

  refresh_chat(bool silent) {
    if (mounted && silent == false) {
      setState(() {
        loading = true;
      });
    }
    Map<String, Object?> data = {"commande_id": widget.client_commande["id"]};

    //send request
    send_message_request = post_request(
        "${API_BASE_URL}/message/all", // API URL
        Utils.TOKEN,
        data, // Query parameters (if any)
        (response) {
      // Success callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      if (response["status"] == true) {
        if (mounted) {
          setState(() {
            messages = response["data"];
          });
          scroll_controller.animateTo(
            scroll_controller.position.maxScrollExtent,
            curve: Curves.ease,
            duration: Duration(milliseconds: 300),
          );
        }
      } else {
        launch_dialog(context, response["message"], null);
      }
    }, (error) {
Utils.show_toast(context, error);      // Error callback
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      //print(error);
    }, chat_form, context);
  }

  void onPressed() {}
}
