import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_goodstudy/services/userdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

class AvaliacaoDatabaseService {

  final CollectionReference db = FirebaseFirestore.instance.collection('avaliacoes');

  Future createAvaliacao(String explicador, int rating) async {
    await db.doc('${explicador.substring(0,3)}_${globals.userlogged!.uid.substring(0,3)}').set({
      'explicador': explicador,
      'explicando': globals.userlogged!.uid,
      'rating': rating,
      'sort': FieldValue.serverTimestamp()
    });
    await UserDatabaseService(uid: explicador).updateAvaliacao(explicador);
  }

  
  Future<double> getAvaliacao(String explicador) async {
    QuerySnapshot snapshot = await db.where('explicador', isEqualTo: explicador).get();
    int totalRating = 0;
    int count = 0;
    for (var doc in snapshot.docs) {
      totalRating += int.parse(doc['rating'].toString());
      count++;
    }
    return totalRating / count;
  }
}