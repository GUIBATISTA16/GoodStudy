import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_goodstudy/services/explicacaodatabase.dart';
import 'package:projeto_goodstudy/services/gruposdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

class ChatDatabaseService {

  final String? chatId;

  ChatDatabaseService({this.chatId});

  final CollectionReference db = FirebaseFirestore.instance.collection('chats');

  Future createChat(String uidExplicador, String uidExplicando) async {
    
    return await db.doc('${uidExplicador.substring(0,3)}_${uidExplicando.substring(0,3)}').set({
      'uidExplicador': uidExplicador,
      'uidExplicando': uidExplicando,
      'estado': 'Ativo',
      'sort':FieldValue.serverTimestamp(),
    });
  }

  Future updateSort(String chatId) async {
    return await db.doc(chatId).set({
      'sort': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  Future checkChat(String uidExplicador, String uidExplicando) async {
    AggregateQuerySnapshot result = await db
                            .where('uidExplicador', isEqualTo: uidExplicador)
                            .where('uidExplicando', isEqualTo: uidExplicando)
                            .where('estado', isEqualTo: 'Ativo')
                            .count().get();
    if(result.count! > 0){
      return true;
    }
    else {
      return false;
    }
  }

  Future getEstado(String docId) async {
    return await db.doc(docId).get();
  }

  Future endChat(String docId,String aluno) async {
    GruposDatabaseService().chatEnded(aluno);
    ExplicacaoDatabaseService().chatEnded(aluno);
    return await db.doc(docId).set({
      'estado': 'Inativo',
      'hasAnswered': false,
    },SetOptions(merge: true));
  }

  Future hasAnswered (String docId) async {
    return await db.doc(docId).set({
      'hasAnswered': true,
    },SetOptions(merge: true));
  }

  Future<List<String>> getListExplicandos() async {
    List<String> listUid = [];
    await db
        .where('uidExplicador', isEqualTo: globals.userlogged!.uid)
        .where('estado', isEqualTo: 'Ativo')
        .get()
        .then((QuerySnapshot querySnapshot){
          querySnapshot.docs.forEach((doc){
            listUid.add(doc['uidExplicando']);
          });
    });
    return listUid;
  }
  
  Stream<QuerySnapshot> get streamExpChats {
    return db
        .where('uidExplicador' , isEqualTo: globals.userlogged!.uid)
        .orderBy('sort', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> get streamAluChats {
    return db
        .where('uidExplicando' , isEqualTo: globals.userlogged!.uid)
        .orderBy('sort', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Object?>> get logChat {
    return db.doc(chatId)
        .snapshots();
  }
}