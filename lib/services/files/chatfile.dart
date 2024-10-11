import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ChatStorageService {

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File file, String chatid, String docId) async {
    try {
      String fileName = 'chat/$chatid/$docId/${file.path.split('/').last}';
      print(fileName);
      Reference ref = storage.ref(fileName);

      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await ref.getDownloadURL();

      print('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      return null;
    }
  }

  Future<String?> uploadFile(File file, String chatid, String docId) async {
    try {
      String fileName = 'chat/$chatid/$docId/${file.path.split('/').last}';
      print(fileName);
      Reference ref = storage.ref(fileName);

      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await ref.getDownloadURL();

      print('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Erro ao enviar ficheiro: $e');
      return null;
    }
  }

  Future<String?> uploadVideo(File file, String chatid, String docId) async {
    try {
      String fileName = 'chat/$chatid/$docId/${file.path.split('/').last}';
      print(fileName);
      Reference ref = storage.ref(fileName);

      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() => null);

      String downloadUrl = await ref.getDownloadURL();

      print('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Erro ao enviar ficheiro: $e');
      return null;
    }
  }
}