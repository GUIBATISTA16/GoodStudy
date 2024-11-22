import 'package:firebase_messaging/firebase_messaging.dart';

Future backgroundNotification(RemoteMessage message) async {

}

void handleMessage(RemoteMessage? message){
  if(message == null){
    return ;
  }

}

Future initPushNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(backgroundNotification);
}


class FirebaseNotifications {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future initNotifications() async{
    await firebaseMessaging.requestPermission();
    //final token = await firebaseMessaging.getToken();
    initPushNotifications();
  }

}