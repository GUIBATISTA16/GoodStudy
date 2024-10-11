import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

class PedidoDatabaseService {

  final CollectionReference db = FirebaseFirestore.instance.collection('pedidos');

  Future insertPedido(String uidDestinatario ,String uidRemetente ,String texto) async{

    return await db.doc().set({
      'uidDestinatario': uidDestinatario,
      'uidRemetente': uidRemetente,
      'estado': 'Waiting',
      'texto': texto,
    });

  }
  
  Future accept(String docID) async {
    await db.doc(docID).set({
      'estado': 'Accepted'
    }, SetOptions(merge: true));
  }

  Future reject(String docID) async {
    await db.doc(docID).set({
      'estado': 'Rejected'
    }, SetOptions(merge: true));
  }

  Future cancel(String docID) async {
    await db.doc(docID).set({
      'estado': 'Canceled'
    }, SetOptions(merge: true));
  }

  Future checkPedido(String uidExplicador, String uidExplicando) async {
    AggregateQuerySnapshot result = await db
        .where('uidDestinatario', isEqualTo: uidExplicador)
        .where('uidRemetente', isEqualTo: uidExplicando)
        .where('estado', isEqualTo: 'Waiting')
        .count().get();
    if(result.count! > 0){
      return true;
    }
    else {
      return false;
    }
  }

  Stream<QuerySnapshot> get streamPedidos {
    return db
        .where('uidDestinatario', isEqualTo: globals.userlogged!.uid)
        .where('estado' , isEqualTo: 'Waiting')
        .snapshots();
  }

  Stream<QuerySnapshot> get streamPedidosPendentes {
    return db
        .where('uidRemetente', isEqualTo: globals.userlogged!.uid)
        .where('estado' , isEqualTo: 'Waiting')
        .snapshots();
  }
}