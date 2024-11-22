import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:intl/intl.dart';
import 'package:projeto_goodstudy/services/gruposdatabase.dart';
import 'package:projeto_goodstudy/services/files/grupofile.dart';
import 'package:uuid/uuid.dart';

class MsgsGrupoDatabaseService {

  final String grupoId;

  MsgsGrupoDatabaseService({required this.grupoId});

  final CollectionReference db = FirebaseFirestore.instance.collection('mensagens');
  String docId = Uuid().v4();

  Future sendMensage(String uid,String text) async{
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
    if(uid != '1'){
      await updateSort();
    }
    return await db.doc('grupos').collection(grupoId).doc(docId).set({
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
    final GrupoStorageService storageService = GrupoStorageService();
    int width = 0;
    int height = 0;
    double aspectRatio = 0.0;
    String? url = await storageService.uploadImage(selectedImage,grupoId,docId);
    if(url != null){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
      final image =  await decodeImageFromList(selectedImage.readAsBytesSync());
      width = image.width;
      height = image.height;
      aspectRatio = width / height;
      await db.doc('grupos').collection(grupoId).doc(docId).set({
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
    final GrupoStorageService storageService = GrupoStorageService();
    String? url = await storageService.uploadFile(selectedFile,grupoId,docId);
    if(url != null){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy kk:mm').format(now);
      await db.doc('grupos').collection(grupoId).doc(docId).set({
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
    final GrupoStorageService storageService = GrupoStorageService();
    String? url = await storageService.uploadVideo(selectedVideo,grupoId,docId);
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
      await db.doc('grupos').collection(grupoId).doc(docId).set({
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
    await GruposDatabaseService().updateSort(grupoId);
  }

  Stream<QuerySnapshot> get streamMsgs {
    return db.doc('grupos').collection(grupoId)
        .orderBy('sort')
        .snapshots();
  }
}