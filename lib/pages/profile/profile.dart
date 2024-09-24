// pages/profile/profile.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/activites/activites.dart';
import 'package:letransporteur_client/pages/auth/login.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/pages/profile/edit_password.dart';
import 'package:letransporteur_client/pages/profile/edit_preferences.dart';
import 'package:letransporteur_client/pages/profile/edit_profile.dart';
import 'package:letransporteur_client/pages/profile/parrainages.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart'; // This is needed for MediaType
import 'package:mime/mime.dart' as mime;
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/activites/activite_component.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_regular_text.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  var notif_non_lu = 0;
  var commandes_en_cours = 0;
  File _image = File("");
  bool loading = false;
  final ImagePicker _picker = ImagePicker();

  late Future<void> logout_post = Future<void>(() {});
  late Future<void> update_profile_post = Future<void>(() {});
  late Future<void> auth_profile_get = Future<void>(() {});

  var photo_profil = null;

  @override
  void dispose() {
    if (update_profile_post != null) update_profile_post.ignore();
    if (logout_post != null) logout_post.ignore();
    if (auth_profile_get != null) auth_profile_get.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      photo_profil = Utils.client["photo"];
    });
    auth_profile_get = get_request(
      "$API_BASE_URL/auth/profile", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        if (mounted) {
          setState(() {
            Utils.client = response?["data"];
            commandes_en_cours = response["nbreCommandeEncour"];
            notif_non_lu = response["nbreNotifNonLu"];
          });
        }
      },
      (error) {},
    );
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // update_photo(_image);
        uploadFile(_image);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadFile(File imageFile) async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    // API endpoint URL
    final String uploadUrl = '$API_BASE_URL/auth/update/photo/profile';

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    // Add fields (if necessary)
    //request.fields['user_id'] = '123';  // Add other form fields if needed

    // Add the file to the request
    var mimeType = mime.lookupMimeType(imageFile.path); // Get MIME type
    var fileStream = http.ByteStream(imageFile.openRead());
    var fileLength = await imageFile.length();

    var multipartFile = http.MultipartFile(
      'image', // the key name expected by the API for the file
      fileStream,
      fileLength,
      filename: path.basename(imageFile.path),
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );

    request.files.add(multipartFile);
// Add Bearer token to the headers
    request.headers['Authorization'] = 'Bearer ${Utils.TOKEN}';
    // Send the request and await the response
    var response = await request.send();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
    // Handle the response
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('File uploaded successfully.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.primary_light,
          content: SmallBoldText(
            text: "Changement effectué avec succès.",
          )));
      var responseData = await http.Response.fromStream(response);
      var result = json.decode(responseData.body);
      Utils.log(result);
      if (result["status"] == true) {
        setState(() {
          photo_profil = result["photo"];
        });
      }
      //print(responseData.body); // Response data from the server
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.primary_light,
          content: SmallBoldText(
            text: "Changement echoué. Veuillez réessayer.",
          )));
      Utils.log_error(response.statusCode);
      print('File upload failed. Status code: ${response.statusCode}');
    }
  }

  update_photo(image) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.primary_light,
        content: SmallBoldText(
          text: "Changement de votre photo de profil...",
        )));
    update_profile_post = post_request(
        "$API_BASE_URL/auth/update/photo/profile", // API URL
        Utils.TOKEN,
        {image: http.ByteStream(image.openRead())}, // Query parameters (if any)
        (response) {
      Utils.log(response);
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.primary_light,
          content: SmallBoldText(
            text: response["message"],
          )));
    }, (error) {
      Utils.show_toast(context, error);
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }, null, context);
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
                children: [],
              ),
            ),
            backgroundColor: AppColors.primary,
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
            profile_header(),
            activites_notifications(),
            SizedBox(
              height: 10,
            ),
            parametres_menu()
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.profile),
    );
  }

  parametres_menu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Column(children: [
        menu_mettre_a_jour(),
        Container(height: 1, color: AppColors.gray6),
        menu_modifier_mot_de_passe(),
        Container(height: 1, color: AppColors.gray6),
        menu_preference_de_compte(),
        Container(height: 1, color: AppColors.gray6),
        menu_parainnage(),
        Container(
            height: 10,
            margin: EdgeInsets.only(top: 30),
            color: AppColors.gray6),
        menu_deconnexion(),
      ]),
    );
  }

  menu_deconnexion() {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Icon(
                  Icons.check_circle,
                  color: Colors.green[800],
                  size: 20.sp,
                ),
                content: SmallLightText(
                    text: "Voulez-vous vraiment vous déconnecter ?"),
                actions: <Widget>[
                  TextButton(
                    child: Text(loading == true
                        ? "Déconnection en cours..."
                        : 'Oui, déconnecter →'),
                    onPressed: () {
                      if (loading == true) return;
                      if (mounted) {
                        setState(() {
                          loading = true;
                        });
                      }
                      logout_post = post_request(
                          "${API_BASE_URL}/auth/logout", // API URL
                          Utils.TOKEN,
                          {}, // Query parameters (if any)
                          (response) {
                        // Success callback
                        Utils.removeAccessToken().then((value) {
                          if (mounted) {
                            setState(() {
                              loading = false;
                            });
                          }
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        });
                      }, (error) {
                        Utils.show_toast(context, error); // Error callback
                        if (mounted) {
                          setState(() {
                            loading = false;
                          });
                        }
                        //print(error);
                      }, null, context);
                    },
                  ),
                ],
              );
            });
      },
      child: Container(
        height: 60,
        child: Row(
          children: [
            Icon(
              Icons.logout,
              size: 25,
              color: Colors.red,
            ),
            SizedBox(
              width: 10.sp,
            ),
            MediumBoldText(text: "Déconnexion"),
            Spacer(),
            AppButton(
                onPressed: () {
                  Utils.log("go");
                },
                child_type: "icon",
                icon_size: "25x25",
                foreground_color: AppColors.dark,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: AppColors.gray4,
                ),
                background_color: AppColors.transparent),
            SizedBox(
              width: 25.sp,
            )
          ],
        ),
      ),
    );
  }

  menu_preference_de_compte() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPreferences(),
            ));
      },
      child: Container(
        height: 60,
        child: Row(
          children: [
            Icon(
              Icons.settings,
              size: 25,
              color: AppColors.dark,
            ),
            SizedBox(
              width: 10.sp,
            ),
            MediumBoldText(text: "Préférences de compte"),
            Spacer(),
            AppButton(
                onPressed: () {
                  Utils.log("go");
                },
                child_type: "icon",
                icon_size: "25x25",
                foreground_color: AppColors.dark,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: AppColors.gray4,
                ),
                background_color: AppColors.transparent),
            SizedBox(
              width: 25.sp,
            )
          ],
        ),
      ),
    );
  }

  menu_parainnage() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Parrainages(),
            ));
      },
      child: Container(
        height: 60,
        child: Row(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 25,
              color: AppColors.dark,
            ),
            SizedBox(
              width: 10.sp,
            ),
            MediumBoldText(text: "Parrainage"),
            Spacer(),
            AppButton(
                onPressed: () {
                  Utils.log("go");
                },
                child_type: "icon",
                icon_size: "25x25",
                foreground_color: AppColors.dark,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: AppColors.gray4,
                ),
                background_color: AppColors.transparent),
            SizedBox(
              width: 25.sp,
            )
          ],
        ),
      ),
    );
  }

  menu_modifier_mot_de_passe() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPassword(),
            ));
      },
      child: Container(
        height: 60,
        child: Row(
          children: [
            Icon(
              Icons.lock,
              size: 25,
              color: AppColors.dark,
            ),
            SizedBox(
              width: 10.sp,
            ),
            MediumBoldText(text: "Modifier mon mot de passe"),
            Spacer(),
            AppButton(
                onPressed: () {
                  Utils.log("go");
                },
                child_type: "icon",
                icon_size: "25x25",
                foreground_color: AppColors.dark,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: AppColors.gray4,
                ),
                background_color: AppColors.transparent),
            SizedBox(
              width: 25.sp,
            )
          ],
        ),
      ),
    );
  }

  menu_mettre_a_jour() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfile(),
            ));
      },
      child: Container(
        height: 60,
        child: Row(
          children: [
            Icon(
              Icons.account_circle,
              size: 25,
              color: AppColors.dark,
            ),
            SizedBox(
              width: 10.sp,
            ),
            MediumBoldText(text: "Mettre à jour mon profil"),
            Spacer(),
            AppButton(
                onPressed: () {
                  Utils.log("go");
                },
                child_type: "icon",
                icon_size: "25x25",
                foreground_color: AppColors.dark,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: AppColors.gray4,
                ),
                background_color: AppColors.transparent),
            SizedBox(
              width: 25.sp,
            )
          ],
        ),
      ),
    );
  }

  profile_header() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 100.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.sp), // Set the radius here
            ),
          ),
        ),
        Positioned(
          top: 25.sp,
          left: 25.sp,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 150.sp,
                  width: 150.sp,
                  alignment: Alignment.topRight,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white,
                          width: 15.sp,
                          strokeAlign: BorderSide.strokeAlignInside),
                      borderRadius: BorderRadius.circular(150.sp),
                      image: photo_profil != null
                          ? DecorationImage(image: NetworkImage(photo_profil), fit: BoxFit.cover)
                          : DecorationImage(
                              image: AssetImage("assets/img/avatar.png"))),
                ),
                SizedBox(
                  width: 20.sp,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediumBoldText(
                        text:
                            "${Utils.client["prenoms"]}  ${Utils.client["nom"]}"),
                    SizedBox(
                      height: 1,
                    ),
                    SmallLightText(
                        text: "né(e) le ${Utils.client["dateNaissance"]}"),
                    SizedBox(
                      height: 20.sp,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
            top: 10.sp,
            left: 150.sp,
            child: loading
                ? Container(
                    width: 55.sp,
                    height: 55.sp,
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(55.sp))),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : AppButton(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    child_type: "icon",
                    icon_size: "55x55",
                    foreground_color: AppColors.dark,
                    icon: Icon(
                      Icons.edit,
                      size: 30.sp,
                      color: AppColors.dark,
                    ),
                    background_color: Colors.white))
      ],
    );
  }

  activites_notifications() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 100.sp, left: 20.sp, right: 20.sp),
          padding: EdgeInsets.only(
              left: 20.sp, top: 10.sp, bottom: 10.sp, right: 10.sp),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.sp),
              border: Border.all(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                  width: 1)),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Activites()));
            },
            child: Row(
              children: [
                SvgPicture.asset("assets/SVG/encours-activite-icon-dark.svg",
                    height: 15.sp, width: 15.sp),
                SizedBox(
                  width: 25.sp,
                ),
                MediumBoldText(
                    text: "${commandes_en_cours} activités en cours"),
                Spacer(),
                RouterButton(
                    destination: Activites(),
                    child_type: "icon",
                    icon_size: "25x25",
                    foreground_color: AppColors.dark,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 15.sp,
                      color: AppColors.gray4,
                    ),
                    background_color: AppColors.transparent),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10.sp,
        ),
        Container(
          margin: EdgeInsets.only(top: 10.sp, left: 20.sp, right: 20.sp),
          padding: EdgeInsets.only(
              left: 20.sp, top: 10.sp, bottom: 10.sp, right: 10.sp),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                  width: 1)),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Notifications()));
            },
            child: Row(
              children: [
                SvgPicture.asset("assets/SVG/notif-unread.svg",
                    height: 15.sp, width: 15.sp),
                SizedBox(
                  width: 25.sp,
                ),
                MediumBoldText(text: "${notif_non_lu} notifications non lues"),
                Spacer(),
                RouterButton(
                    destination: Notifications(),
                    child_type: "icon",
                    icon_size: "28x28",
                    foreground_color: AppColors.dark,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 15.sp,
                      color: AppColors.gray4,
                    ),
                    background_color: AppColors.transparent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void onPressed() {}
}
