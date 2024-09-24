// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:letransporteur_client/api/firebase_api.dart';
import 'package:letransporteur_client/firebase_options.dart';
import 'package:letransporteur_client/misc/utils.dart';
import 'package:letransporteur_client/pages/accueil.dart';
import 'package:letransporteur_client/pages/commande_livraison.dart';
import 'package:letransporteur_client/pages/auth/login.dart';
import 'package:letransporteur_client/pages/notifications.dart';
import 'package:logger/logger.dart';
import 'package:letransporteur_client/widgets/page/map/map_picker_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final navigatorKey = GlobalKey<NavigatorState>();
var token;

void main() async {
  final logger = Logger();
  // Set the global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    logger.e(details.exceptionAsString(),
        error: details.exception, stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseApi().init_push_notifications();

  await Hive.initFlutter();
  await Hive.openBox(Utils.APP_HIVE_BOX_NAME);
  token = await Hive.box(Utils.APP_HIVE_BOX_NAME).get(Utils.ACCESS_TOKEN_KEY);
  if (token != null) Utils.set_token(token);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 731),
      builder: (context, child) {
        return MaterialApp(
            title: 'Le Transporteur',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // TRY THIS: Try running your application with "flutter run". You'll see
              // the application has a purple toolbar. Then, without quitting the app,
              // try changing the seedColor in the colorScheme below to Colors.green
              // and then invoke "hot reload" (save your changes or press the "hot
              // reload" button in a Flutter-supported IDE, or press "r" if you used
              // the command line to start the app).
              //
              // Notice that the counter didn't reset back to zero; the application
              // state is not lost during the reload. To reset the state, use hot
              // restart instead.
              //
              // This works for code too, not just values: Most code changes can be
              // tested with just a hot reload.
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
              useMaterial3: true,
            ),
            navigatorKey: navigatorKey,
            routes: {'/notification_sreen': (context) => Notifications()},
            scaffoldMessengerKey:
                scaffoldMessengerKey, // Set scaffoldMessengerKey to MaterialApp
            home: token == null ? Login() : Accueil(token: token));
      },
    );
  }
}
