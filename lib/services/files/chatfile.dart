import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ChatStorageService {

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File file, String chatid, String docId) async {
    try {
      String fileName = 'chat/$chatid/$docId/${file.path.split('/').last}';
      Reference ref = storage.ref(fileName);

      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadFile(File file, String chatid, String docId) async {
    try {
      String fileName = 'chat/$chatid/$docId/${file.path.split('/').last}';
      Reference ref = storage.ref(fileName);

      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadVideo(File file, String chatid, String docId) async {
    try {
      String fileName = 'chat/$chatid/$docId/${file.path.split('/').last}';
      Reference ref = storage.ref(fileName);

      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}