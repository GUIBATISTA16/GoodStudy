import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

class GruposDatabaseService {

  final CollectionReference db = FirebaseFirestore.instance.collection('grupos');

  Future createGrupo(String uidExplicador, List<String> listExplicandos, String nomeGrupo) async {

    if(nomeGrupo.isEmpty){
      int? count = await countGrupos(uidExplicador);
      if(count != null){
        count++;
      }
      else{
        count = 0;
      }
      nomeGrupo = 'Grupo do ${globals.userlogged!.nome} $count';
    }

    return await db.doc( ).set({
      'nome': nomeGrupo,
      'uidExplicador': uidExplicador,
      'listExplicandos': listExplicandos,
      'sort': FieldValue.serverTimestamp(),
    });
  }

  Future removeFromGroup(String docId, String removedAluno) async{
    await db.doc(docId).get().then((DocumentSnapshot doc) async {
      List<dynamic> list = doc['listExplicandos'];
      list.remove(removedAluno);
      await db.doc(docId).set({'listExplicandos': list}, SetOptions(merge: true));
    });
  }

  Future addToGroup(String docId, List<FUser> addedAlunos) async{
    await db.doc(docId).get().then((DocumentSnapshot doc) async {
      List<dynamic> list = doc['listExplicandos'];
      addedAlunos.forEach((user){
        list.add(user.uid);
      });
      await db.doc(docId).set({'listExplicandos': list}, SetOptions(merge: true));
    });
  }

  Future updateSort(String grupoId) async {
    return await db.doc(grupoId).set({
      'sort': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> chatEnded(String aluno) async {
    QuerySnapshot querySnapshot = await db
        .where('uidExplicador', isEqualTo: globals.userlogged!.uid)
        .where('listExplicandos', arrayContains: aluno)
        .get();
    for (var doc in querySnapshot.docs) {
      List<String> listAtual = List<String>.from(doc['listExplicandos']);
      listAtual.remove(aluno);
      if(listAtual.isNotEmpty){
        await db.doc(doc.id).set({
          'listExplicandos': listAtual,
        }, SetOptions(merge: true));
      }
      else{
        await db.doc(doc.id).delete();
      }
    }
    return;
  }

  Future<int?> countGrupos(String uidExplicador) async {
    AggregateQuerySnapshot result = await db
        .where('uidExplicador', isEqualTo: uidExplicador)
        .count().get();
    return result.count;
  }

  Stream<QuerySnapshot> get streamExpGrupos {
    return db
        .where('uidExplicador' , isEqualTo: globals.userlogged!.uid)
        .orderBy('sort', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> get streamAluGrupos {
    return db
        .where('listExplicandos' , arrayContains: globals.userlogged!.uid)
        .orderBy('sort', descending: true)
        .snapshots();
  }

}