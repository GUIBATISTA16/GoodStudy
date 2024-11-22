import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:intl/intl.dart';
import 'package:projeto_goodstudy/services/chatdatabase.dart';
import 'package:projeto_goodstudy/services/files/chatfile.dart';
import 'package:uuid/uuid.dart';

class MsgsChatDatabaseService {

  final String chatId;

  MsgsChatDatabaseService({required this.chatId});

  final CollectionReference db = FirebaseFirestore.instance.collection('mensagens');
  String docId = const Uuid().v4();
  Future sendMensage(String uid,String text) async{
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
    if(uid != '1'){
      await updateSort();
    }
    return await db.doc('chats').collection(chatId).doc(docId).set({
      'remetente': uid,
      'tipo': 'texto',
      'data': formattedDate,
      'sort': FieldValue.serverTimestamp(),
      'texto': text,
      'ficheiro': null,
      'filename': null,
      'width': null,
      'aspectRatio': null,
    });

  }

  Future sendImage(String uid,File selectedImage) async{
    final ChatStorageService storageService = ChatStorageService();
    int width = 0;
    int height = 0;
    double aspectRatio = 0.0;
    String? url = await storageService.uploadImage(selectedImage,chatId,docId);
    if(url != null){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
      final image =  await decodeImageFromList(selectedImage.readAsBytesSync());
      width = image.width;
      height = image.height;
      aspectRatio = width / height;
      await db.doc('chats').collection(chatId).doc(docId).set({
        'remetente': uid,
        'tipo': 'imagem',
        'data': formattedDate,
        'sort': FieldValue.serverTimestamp(),
        'texto': null,
        'ficheiro': url,
        'filename': selectedImage.path.split('/').last,
        'width': width,
        'aspectRatio': aspectRatio,
      });
      await updateSort();
      return true;
    }
    else{
      return false;
    }
  }

  Future sendFile(String uid,File selectedFile) async{
    final ChatStorageService storageService = ChatStorageService();
    String? url = await storageService.uploadFile(selectedFile,chatId,docId);
    if(url != null){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
      await db.doc('chats').collection(chatId).doc(docId).set({
        'remetente': uid,
        'tipo': 'ficheiro',
        'data': formattedDate,
        'sort': FieldValue.serverTimestamp(),
        'texto': null,
        'ficheiro': url,
        'filename': selectedFile.path.split('/').last,
        'width': null,
        'aspectRatio': null,
      });
      await updateSort();
      return true;
    }
    else{
      return false;
    }
  }

  Future sendVideo(String uid,File selectedVideo) async{
    final ChatStorageService storageService = ChatStorageService();
    String? url = await storageService.uploadVideo(selectedVideo,chatId,docId);
    int? width = 0;
    int? height = 0;
    double aspectRatio = 0.0;
    if(url != null){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);

      final videoInfo = FlutterVideoInfo();
      var info = await videoInfo.getVideoInfo(selectedVideo.path);
      width = info?.width;
      height = info?.height;
      aspectRatio = width! / height!;
      await db.doc('chats').collection(chatId).doc(docId).set({
        'remetente': uid,
        'tipo': 'video',
        'data': formattedDate,
        'sort': FieldValue.serverTimestamp(),
        'texto': null,
        'ficheiro': url,
        'filename': selectedVideo.path.split('/').last,
        'width': width,
        'aspectRatio': aspectRatio,
      });
      await updateSort();
      return true;
    }
    else{
      return false;
    }
  }

  Future updateSort() async {
    await ChatDatabaseService().updateSort(chatId);
  }

  Stream<QuerySnapshot> get streamMsgs {
    return db.doc('chats').collection(chatId)
        .orderBy('sort')
        .snapshots();
  }
}