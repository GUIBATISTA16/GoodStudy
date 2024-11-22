import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../main.dart';
import '../objects/mensagem.dart';
import '../widget/loading.dart';
import '../widget/videoplayer.dart';
import 'colorsglobal.dart';

void showCustomSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    margin: const EdgeInsets.only(
      bottom: 50,
      left: 70,
      right: 70,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> downloadFile(String url, String filename,BuildContext context) async {
  showCustomSnackBar(context, 'Download Iniciado');
  bool dirDownloadExists = true;
  var directory;
  if (Platform.isIOS) {
    directory = await getDownloadsDirectory();
  } else {
    directory = "/storage/emulated/0/Download/";

    dirDownloadExists = await Directory(directory).exists();
    if (dirDownloadExists) {
      directory = "/storage/emulated/0/Download/";
    } else {
      directory = "/storage/emulated/0/Downloads/";
    }
  }
  String downloadsPath;
  if (Platform.isIOS) {
    downloadsPath = directory.path;
  } else {
    downloadsPath = directory;
  }
  Directory downloadsFolder = Directory(downloadsPath);

  if (!downloadsFolder.existsSync()) {
    downloadsFolder.createSync(recursive: true);
  }

  String filepath = '${downloadsFolder.path}${const Uuid().v1().substring(0, 4)}$filename';
  File downloadToFile = File(filepath);

  try {
    Dio dio = Dio();
    await dio.download(url, downloadToFile.path);
    showNotification(filepath);
  } catch (e) {
    showCustomSnackBar(context, 'Erro ao fazer o Download!');
  }
}

Future<void> showNotification(String filePath) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'download_channel',
    'Downloads',
    channelDescription: 'Canal para notificações de download',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Download Concluído',
    'Clique para abrir o ficheiro.',
    platformChannelSpecifics,
    payload: filePath,
  );
}

Future<void> downloadImage(String url, String filename,BuildContext context) async {
  showCustomSnackBar(context, 'Download Iniciado');
  final tempDir = await getTemporaryDirectory();
  final path = '${tempDir.path}/$filename';
  await Dio().download(url, path);
  await GallerySaver.saveImage(path, albumName: 'GoodStudy', toDcim: true);
  showNotification(path);
}

Future<void> downloadVideo(String url, String filename, BuildContext context) async {
  showCustomSnackBar(context, 'Download Iniciado');
  final tempDir = await getTemporaryDirectory();
  final path = '${tempDir.path}/$filename';
  await Dio().download(url, path);
  await GallerySaver.saveVideo(path, albumName: 'GoodStudy', toDcim: true);
  showNotification(path);
}

Future<void> checkAndRequestPermissions() async {
  var statusS = await Permission.storage.status;
  if (!statusS.isGranted) {
    await Permission.storage.request();
  }
  var statusN = await Permission.notification.status;
  if (!statusN.isGranted) {
    await Permission.notification.request();
  }
}

void showModalImagem(BuildContext context, MensagemObject msg) {
  showDialog(
    context: context,
    builder: (bcontext) {
      return AlertDialog(
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
        backgroundColor: fundoMenus,
        title: Row(
          children: [
            const BackButton(),
            const Expanded(child: SizedBox()),
            IconButton(
              onPressed: () async {
                await downloadImage(msg.fileUrl!, msg.filename!, context);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(0.8)),
              ),
              icon: const Icon(
                size: 23,
                Icons.download,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    msg.fileUrl!,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Loading(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showModalVideo(BuildContext context, MensagemObject msg) {
  showDialog(
    context: context,
    builder: (bcontext) {
      return AlertDialog(
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        contentPadding: const EdgeInsets.only(top: 10.0),
        title: Row(
          children: [
            const BackButton(),
            const Expanded(child: SizedBox()),
            IconButton(
              onPressed: () async {
                await downloadVideo(msg.fileUrl!, msg.filename!, context);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(0.8)),
              ),
              icon: const Icon(
                size: 23,
                Icons.download,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: fundoMenus,
        content: Container(
          width: MediaQuery.of(context).size.width ,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(3, 0, 3, 8),
            child: Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Videoplayer(url: msg.fileUrl!,)
            ),
          ),
        ),
      );
    },
  );
}

int typeOfFile(File file){
  if(file.path.split('.').last == 'mp4'){
    return 3;
  }
  if(file.path.split('.').last == 'png' || file.path.split('.').last == 'jpeg' || file.path.split('.').last == 'jpg'
      || file.path.split('.').last == 'webp'){
    return 2;
  }
  else{
    return 1;
  }
}

void onUserLogin() {
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: appId /*input your AppID*/,
    appSign: appSign /*input your AppSign*/,
    userID: userlogged!.uid,
    userName: userlogged!.nome!,
    plugins: [ZegoUIKitSignalingPlugin()],
  );
}

void onUserLogout() {
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}

