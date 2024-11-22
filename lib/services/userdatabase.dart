import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/objects/explicador.dart';
import 'package:projeto_goodstudy/objects/explicando.dart';
import 'package:projeto_goodstudy/services/avaliacaodatabase.dart';

class UserDatabaseService {

  late final String uid;

  UserDatabaseService({required this.uid});

  final CollectionReference db = FirebaseFirestore.instance.collection('users');

  Future updateExplicadorData(Explicador user, {double? avaliacao = null}) async{
    return await db.doc(uid).set({
      'nome': user.nome,
      'tipo': user.tipo,
      'descricao': user.descricao,
      'especialidade': user.especialidade,
      'anosexp': user.anosExp,
      'precohora': user.precohr,
      'precomes': user.precomes,
      'precoano': user.precoano,
      'avaliacao': avaliacao
    }, SetOptions(merge: true));

  }
  Future updateExplicandoData(Explicando user) async{
    return await db.doc(uid).set({
      'nome': user.nome,
      'tipo': user.tipo,
      'nivel': user.nivel,
      'ano':user.ano
    }, SetOptions(merge: true));
  }

  Future setPhotoUrl(String uid, String? photoUrl) async{
    return await db.doc(uid).set({
      'photoUrl': photoUrl,
    }, SetOptions(merge: true));
  }

  Future getDataWithUid(String uid) async {
    return db.doc(uid).get();
  }

  Future<List<FUser>> getExplicadoresPesquisa(String nome, String especialidade,double min, double max, String ord) async {

    String sort = 'nome';
    bool ascending = true;
    if(ord == 'Alfabética'){
      sort = 'nome';
      ascending = true;
    }
    else if(ord == 'Preço Ascendente'){
      sort = 'precohora';
      ascending = true;
    }
    else if(ord == 'Preço Decrescente'){
      sort = 'precohora';
      ascending = false;
    }
    else if(ord == 'Avaliação') {
      sort = 'avaliacao';
      ascending = false;
    }


    List<FUser> explicadores = [];
    String start = nome;
    String end = nome + '\uf8ff';
    if(especialidade == 'Nenhuma'){
       await db
          .where('tipo', isEqualTo: 'Explicador')
          .where('nome', isGreaterThanOrEqualTo: start)
          .where('nome', isLessThan: end)
          .where('precohora', isGreaterThanOrEqualTo: min)
          .where('precohora', isLessThanOrEqualTo: max)
          .orderBy(sort,descending: !ascending)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          FUser user = FUser(uid: doc.id, isAnonymous: false);
          user.especialidade = doc['especialidade'];
          user.nome = doc['nome'];
          user.anosexp = doc['anosexp'];
          user.precohr = doc['precohora'];
          user.precomes = doc['precomes'];
          user.precoano = doc['precoano'];
          user.descricao = doc['descricao'];
          user.tipo = 'Explicador';
          user.photoUrl = doc['photoUrl'];
          user.avaliacao = double.tryParse(doc['avaliacao'].toString());
          explicadores.add(user);
        });
      });
    }
    else{
       await db
          .where('tipo', isEqualTo: 'Explicador')
          .where('especialidade',isEqualTo: especialidade)
          .where('nome', isGreaterThanOrEqualTo: start)
          .where('nome', isLessThanOrEqualTo: end)
          .where('precohora', isGreaterThanOrEqualTo: min)
          .where('precohora', isLessThanOrEqualTo: max)
          .orderBy(sort,descending: !ascending)
          .get()
           .then((QuerySnapshot querySnapshot) {
         querySnapshot.docs.forEach((doc) async {
           FUser user = FUser(uid: doc.id, isAnonymous: false);
           user.especialidade = doc['especialidade'];
           user.nome = doc['nome'];
           user.anosexp = doc['anosexp'];
           user.precohr = doc['precohora'];
           user.precomes = doc['precomes'];
           user.precoano = doc['precoano'];
           user.descricao = doc['descricao'];
           user.tipo = 'Explicador';
           user.photoUrl = doc['photoUrl'];
           user.avaliacao = double.tryParse(doc['avaliacao'].toString()) ;
           explicadores.add(user);
         });
       });
    }
    return await explicadores;
  }

  Future updateAvaliacao(String explicador) async{
    double avaliacao = await AvaliacaoDatabaseService().getAvaliacao(explicador);
    return await db.doc(explicador).set({
      'avaliacao': avaliacao
    }, SetOptions(merge: true));
  }


  Stream<QuerySnapshot>get user {
    return db.snapshots();
  }


}