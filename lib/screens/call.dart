import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../globais/varGlobal.dart' as globals;

class CallPage extends StatelessWidget {
  final String channel;
  const CallPage({
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
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}


class GroupCallPage extends StatelessWidget {
  final String channel;
  const GroupCallPage({
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
      config: ZegoUIKitPrebuiltCallConfig.groupVoiceCall(),
    );

  }
}