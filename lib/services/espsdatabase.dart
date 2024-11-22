import 'package:cloud_firestore/cloud_firestore.dart';

class EspDatabaseService {
  final CollectionReference db = FirebaseFirestore.instance.collection('especialidades');

  Future<QuerySnapshot> getData() async {
    return await db.get();
  }
}