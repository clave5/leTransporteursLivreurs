import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:letransporteur_client/api/api.dart';
import 'package:letransporteur_client/main.dart';
import 'package:letransporteur_client/misc/utils.dart';

class FirebaseApi {
  final _firebase_messaging = FirebaseMessaging.instance;

  Future<void> activite_periode_post = Future<void>(() {});

  Future<void> init_notification() async {
    await _firebase_messaging.requestPermission();

    String? fCM_TOKEN = "";
    _firebase_messaging.getToken().then((value) {
      fCM_TOKEN = value;
      Utils.log("fCM token : $value");
      send_notif_token(fCM_TOKEN);
    });

    init_push_notifications();
  }

  send_notif_token(fCM_TOKEN) {
    activite_periode_post = post_request(
        "$API_BASE_URL/auth/token/notification", // API URL
        Utils.TOKEN,
        {
          "token_notification": fCM_TOKEN,
        }, // Query parameters (if any)
        (response) {
      Utils.log(response);
    }, (error) {}, null, null);
  }

  void handle_message(RemoteMessage message) {
    if (message == null) return;
    Utils.log(message.notification);
    Utils.log(message.data);
    navigatorKey.currentState
        ?.pushNamed('/notification_sreen', arguments: message);
  }

  Future init_push_notifications() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((value) => handle_message);

    FirebaseMessaging.onMessageOpenedApp.listen(handle_message);
  }
}
