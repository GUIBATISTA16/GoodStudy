import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projeto_goodstudy/screens/wrapper.dart';
import 'package:projeto_goodstudy/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await FirebaseNotifications().initNotifications();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  if (Platform.isAndroid) {
    await Permission.storage.request();
    await Permission.notification.request();
  }
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null && response.payload!.isNotEmpty) {
        await openFile(response.payload!);
      }
    },
  );
  //ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  // call the useSystemCallingUI
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    runApp(  MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: MyApp(navigatiorKey: navigatorKey,),
    ));
  });
}

Future<void> openFile(String filePath) async {
  await Permission.manageExternalStorage.request();
  if(await Permission.manageExternalStorage.isGranted){
    await OpenFile.open(filePath);
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatiorKey;
  const MyApp({super.key, required this.navigatiorKey});


  /*@override
  Widget build(BuildContext context) {
    return Login();
  }*/

  @override
  Widget build(BuildContext context) {
    return
    StreamProvider<User?>.value(
      value: AuthService().streamLogin,
      initialData: null,
      child: Wrapper(navigatorKey: navigatiorKey,),
    );
  }
}





