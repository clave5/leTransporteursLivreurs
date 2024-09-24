// pages/assistance/assistance_article.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
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
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';

class AssistanceArticle extends StatefulWidget {
  String title = "";
  var question;
  AssistanceArticle({super.key, required this.title, this.question});

  @override
  State<AssistanceArticle> createState() => AssistanceArticleState();
}

class AssistanceArticleState extends State<AssistanceArticle> {
  String htmlContent =
      """<h1>Comment et où je télécharge l'application pour m'inscrire ?</h1>
<p>Pour vous inscrire, vous pouvez vous rendre sur PlayStore ou sur AppStore pour télécharger l'application en cliquant
    le lien ci-dessous : </p>
<a href="https://letransporteur.io/install">https://letransporteur.io/install</a>
<p>Si vous avez des difficultés à télécharger, nous vous suggérons de vérifier si vous êtes bien connectés à Internet.
</p>
<p>Vous devriez également vérifier si votre smartphone a assez d'espace pour l'application. </p>
<p>Vous pouvez toutes fois contacter le support d'assistance via l'un des numeros ci-dessous :</p>
<a href="https://wa.me/22960606060">https://wa.me/22960606060</a>
<a href="https://wa.me/22965656565">https://wa.me/22965656565</a>
<p>Le Transporteur • 21 décembre 2023</p>""";

  var reponse_faq = {};

  late Future<void> answer_faq = Future<void>(() {});

  @override
  void dispose() {
    if (answer_faq != null) answer_faq.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    answer_faq = get_request(
      "${API_BASE_URL}/client/answer/faq/${widget.question?["id"]}", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        if (mounted) {
          setState(() {
            reponse_faq = response?["answers"][0];
            Utils.log(reponse_faq["libelle"]);
          });
        }
      },
      (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            (kToolbarHeight + 20).sp), // Adjust height as needed
        child: Padding(
          padding: EdgeInsets.only(bottom: 10), // Add bottom padding
          child: AppBar(
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: LargeBoldText(
                        text: "Assistance",
                        color: Utils.colorToHex(AppColors.dark)),
                  ),
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
        padding: EdgeInsets.all(15),
        color: AppColors.gray7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LargeBoldText(text: widget.title),
            reponse_faq["libelle"] == null
                ? loading_component()
                : Html(
                    data: reponse_faq["libelle"] ?? "",
                  )
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

  void onPressed() {}
}
