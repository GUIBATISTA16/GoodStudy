import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class AvatarStorageService {

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadAvatar(File file, String uid) async {
    try {
      String fileName = 'avatar/$uid';

      Reference ref = storage.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> download(String uid) async{
    String fileName = 'avatar/$uid';
    try {
      Reference ref = storage.ref().child(fileName);

      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch(e){
      return null;
    }

  }


}