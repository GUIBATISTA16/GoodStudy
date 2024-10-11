import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../globais/varGlobal.dart' as globals;

class VideoCallPage extends StatelessWidget {
  final String channel;
  const VideoCallPage({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: globals.appId,
      appSign: globals.appSign,
      userID: globals.userlogged!.uid,
      userName: globals.userlogged!.nome!,
      callID: channel,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );

  }
}


class VideoGroupCallPage extends StatelessWidget {
  final String channel;
  const VideoGroupCallPage({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: globals.appId,
      appSign: globals.appSign,
      userID: globals.userlogged!.uid,
      userName: globals.userlogged!.nome!,
      callID: channel,
      config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
    );

  }
}