// pages/profile/edit_profile.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart'; // This is needed for MediaType
import 'package:mime/mime.dart' as mime;
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/misc/colors.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:letransporteur_client/widgets/button/app_button.dart';
import 'package:letransporteur_client/widgets/button/router_button.dart';
import 'package:letransporteur_client/widgets/component/other/app_bottom_nav_bar_component.dart';
import 'package:letransporteur_client/widgets/texts/large/large_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/large/large_titre_text.dart';
import 'package:letransporteur_client/widgets/texts/medium/medium_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_bold_text.dart';
import 'package:letransporteur_client/widgets/texts/small/small_light_text.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:letransporteur_client/widgets/texts/xsmall/xsmall_light_text.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  FormGroup form = FormGroup({
    'telephone': FormControl<String>(validators: [
      Validators.required,
      Validators.number(allowNegatives: false)
    ], value: ""),
    'countryCode': FormControl<String>(validators: [
      Validators.required,
    ], value: "+229"),
    'nom': FormControl<String>(validators: [
      Validators.required,
    ], value: Utils.client?["nom"] ?? ""),
    'prenoms': FormControl<String>(validators: [
      Validators.required,
    ], value: Utils.client?["prenoms"] ?? ""),
    'dateNaissance': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
        value: Utils.client?["dateNaissance"] != null
            ? DateTime.parse(Utils.client?["dateNaissance"])
            : DateTime.now()),
    'sexe': FormControl<String>(validators: [
      Validators.required,
    ], value: Utils.client?["sexe"] ?? ""),
  });

  bool loading = false;
  bool phone_valid = true;
  var profile = {};

  File _image = File("");

  final ImagePicker _picker = ImagePicker();

  TextEditingController phone_controller = TextEditingController();

  late Future<void> update_profile_post = Future<void>(() {});
  late Future<void> update_photo_post = Future<void>(() {});

  late Future<void> auth_profile_get = Future<void>(() {});

  var photo_profil;

  @override
  void dispose() {
    if (update_profile_post != null) update_profile_post.ignore();
    if (auth_profile_get != null) auth_profile_get.ignore();
    if (update_photo_post != null) update_photo_post.ignore();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      photo_profil = Utils.client["photo"];
    });
    form.valueChanges.listen((element) {
      form.controls.forEach((key, value) {
        value.setErrors({});
      });
      Utils.log({"valid": form.valid, "form": element});
      if (mounted) setState(() {});
    });

    auth_profile_get = get_request(
      "$API_BASE_URL/auth/profile", // API URL
      Utils.TOKEN,
      {}, // Query parameters (if any)
      (response) {
        Utils.log(response);
        if (mounted) {
          setState(() {
            profile = response?["data"];
            fill_profile();
          });
        }
      },
      (error) {},
    );

    /* load_villes();
    form.controls["countryCode"]?.valueChanges.listen((event) {
      load_villes();
    }); */
  }

  fill_profile() {
    Utils.client = profile;
    if (profile["telephone"] != null) {
      profile["telephone"] = profile["telephone"].replaceFirst("+229", "");
    }
    form.patchValue({
      "telephone": profile["telephone"],
      "nom": profile["nom"],
      "prenoms": profile["prenoms"],
      "dateNaissance": DateTime.parse(profile["dateNaissance"]),
      "sexe": profile["sexe"],
    });
    phone_controller.text = profile["telephone"];
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
                  LargeBoldText(
                      text: "Modifier profile",
                      color: Utils.colorToHex(AppColors.dark)),
                  /*  RouterButton(
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
        width: double.infinity,
        padding: EdgeInsets.all(0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 15.sp,
            ),
            profile_header(),
            SizedBox(
              height: 5.sp,
            ),
            MediumBoldText(
                text: "${Utils.client["prenoms"]}  ${Utils.client["nom"]}"),
            SizedBox(
              height: 30.sp,
            ),
            edit_profile_form()
          ],
        ),
      )),
      bottomNavigationBar:
          AppBottomNavBarComponent(active: BottomNavPage.profile),
    );
  }

  edit_profile_form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.sp, vertical: 10.sp),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            ReactiveTextField(
              formControlName: 'nom',
              validationMessages: {
                ValidationMessage.required: (error) => 'Le nom est requis',
                'field_validation': (error) => error as String,
              },
              style: Utils.small_bold_text_style,
              decoration: Utils.get_default_input_decoration_normal(
                  form.control('nom'),
                  false,
                  'Nom',
                  {"icon": Icons.face, "size": 24.sp},
                  null,
                  null),
            ),
            SizedBox(height: 20.sp),
            ReactiveTextField(
              formControlName: 'prenoms',
              validationMessages: {
                ValidationMessage.required: (error) => 'Le prénom est requis',
                'field_validation': (error) => error as String,
              },
              style: Utils.small_bold_text_style,
              decoration: Utils.get_default_input_decoration_normal(
                  form.control('prenoms'),
                  false,
                  'Prénoms',
                  {"icon": Icons.face, "size": 24.sp},
                  null,
                  null),
            ),
            SizedBox(height: 20.sp),
            ReactiveDatePicker(
              formControlName: 'dateNaissance',
              builder: (context, picker, child) {
                return ReactiveTextField(
                  readOnly: true,
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'La date de naissance est requise',
                    'field_validation': (error) => error as String,
                  },
                  onTap: (control) => {picker.showPicker()},
                  formControlName: 'dateNaissance',
                  decoration: Utils.get_default_input_decoration_normal(
                      form.control('dateNaissance'),
                      false,
                      'Date de naissance',
                      {"icon": Icons.calendar_today_rounded, "size": 24.sp},
                      null,
                      null),
                  style: Utils.small_bold_text_style,
                );
              },
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            ),
            SizedBox(height: 20.sp),
            IntlPhoneField(
              decoration: Utils.get_default_input_decoration_normal(
                  form.control('telephone'),
                  true,
                  'Numero de téléphone',
                  null,
                  null,
                  null),
              style: Utils.small_bold_text_style,
              controller: phone_controller,
              initialCountryCode: 'BJ',
              onChanged: (phone) {
                Utils.log(phone);
                if (mounted) {
                  setState(() {
                    try {
                      phone_valid = phone.isValidNumber();
                    } on Exception catch (e) {
                      phone_valid = false;
                    }
                    form.patchValue({"telephone": phone.number});
                  });
                }
              },
            ),
            SizedBox(height: 20.sp),
            ReactiveDropdownField(
              items: [
                DropdownMenuItem(
                  value: 'Homme',
                  child: SmallBoldText(
                    text: "Homme",
                  ),
                ),
                DropdownMenuItem(
                  value: 'Femme',
                  child: SmallBoldText(
                    text: "Femme",
                  ),
                ),
              ],
              decoration: Utils.get_default_input_decoration_normal(
                  form.control('sexe'),
                  true,
                  'Choissez votre sexe',
                  {"icon": Icons.transgender, "size": 24.sp},
                  null,
                  null),
              style: Utils.small_bold_text_style,
              formControlName: 'sexe',
              validationMessages: {
                ValidationMessage.required: (error) => 'Le sexe est requis',
                'field_validation': (error) => error as String,
              },
            ),
            SizedBox(height: 35.sp),
            AppButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      loading = true;
                    });
                  }
                  update_profile_post = post_request(
                      "$API_BASE_URL/auth/update/profile", // API URL
                      Utils.TOKEN,
                      form.rawValue, // Query parameters (if any)
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
                },
                loading: loading,
                background_color: AppColors.primary,
                disabled: !form.valid,
                text: "Enregistrer les modifications",
                text_weight: "bold"),
          ],
        ),
      ),
    );
  }

  void country_code_changed(CountryCode code) {
    Utils.log(code.toString());
    form.patchValue({"countryCode": code.toString()});
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

  profile_header() {
    return Stack(
      clipBehavior: Clip.none,
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
        Positioned(
            top: -10,
            right: -10,
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
                      size: 30,
                      color: AppColors.dark,
                    ),
                    background_color: Colors.white))
      ],
    );
  }

  void onPressed() {}
}
