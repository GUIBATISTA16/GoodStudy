import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_goodstudy/objects/explicacao.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart';

class ExplicacaoDatabaseService {
  final CollectionReference db = FirebaseFirestore.instance.collection('explicacoes');

  Future createExplicacao(List<String> listUtilizadores,DateTime data,int duracao,bool minutos) async {
    listUtilizadores.insert(0,userlogged!.uid);
    return await db.doc().set({
      'listUtilizadores': listUtilizadores,
      'data': data,
      'duracao': duracao,
      'minutos': minutos,
      'especialidade': userlogged!.especialidade,
      'titulo': 'Explicação de ${userlogged!.especialidade} com ${userlogged!.nome}'
    });
  }

  Future editExplicacao(List<String> listUtilizadores,DateTime data,int duracao,bool minutos,String docId) async {
    listUtilizadores.insert(0,userlogged!.uid);
    return await db.doc(docId).set({
      'listUtilizadores': listUtilizadores,
      'data': data,
      'duracao': duracao,
      'minutos': minutos,
      'especialidade': userlogged!.especialidade,
      'titulo': 'Explicação de ${userlogged!.especialidade} com ${userlogged!.nome}'
    });
  }

  Future<void> chatEnded(String aluno) async {
    QuerySnapshot querySnapshot = await db
        .where('listUtilizadores', arrayContains: userlogged!.uid)
        .get();
    for (var doc in querySnapshot.docs) {
      List<String> listAtual = List<String>.from(doc['listUtilizadores']);
      if(listAtual.contains(aluno)){
        listAtual.remove(aluno);
        await db.doc(doc.id).set({
          'listUtilizadores': listAtual,
        }, SetOptions(merge: true));
      }
    }
    return;
  }

  Future<List<String>> getEspecialidades() async {
    List<String> list = [];
    list.add('Nenhuma');
    await db
        .where('listUtilizadores', arrayContains: userlogged!.uid)
        .where('data', isGreaterThanOrEqualTo: DateTime.now())
        .get()
        .then((QuerySnapshot snapshot){
          snapshot.docs.forEach((doc){
            if(!list.contains(doc['especialidade'])){
              list.add(doc['especialidade']);
            }
          });
        });
    return list;
  }

  Future<List<ExplicacaoObject>> getExplicacoes(String especialidade) async {
    List<ExplicacaoObject> list = [];
    if(especialidade == 'Nenhuma'){
      await db
          .where('listUtilizadores', arrayContains: userlogged!.uid)
          .where('data', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('data')
          .get()
          .then((QuerySnapshot snapshot){
        snapshot.docs.forEach((doc){
          ExplicacaoObject explicacao = ExplicacaoObject(
              docId: doc.id,
              data: (doc['data'] as Timestamp).toDate(),
              duracao: doc['duracao'],
              minutos: doc['minutos'],
              especialidade: doc['especialidade'],
              titulo: doc['titulo'],
              listUtilizadores: doc['listUtilizadores']
          );
          list.add(explicacao);
        });
      });
    }
    else{
      await db
          .where('listUtilizadores', arrayContains: userlogged!.uid)
          .where('especialidade', isEqualTo: especialidade)
          .where('data', isGreaterThanOrEqualTo: DateTime.now())
          .get()
          .then((QuerySnapshot snapshot){
        snapshot.docs.forEach((doc){
          ExplicacaoObject explicacao = ExplicacaoObject(
              docId: doc.id,
              data: (doc['data'] as Timestamp).toDate(),
              duracao: doc['duracao'],
              minutos: doc['minutos'],
              especialidade: doc['especialidade'],
              titulo: doc['titulo'],
              listUtilizadores: doc['listUtilizadores']
          );
          list.add(explicacao);
        });
      });
    }

    return list;
  }

  Stream<QuerySnapshot> get streamExplicacoes {
    return db
        .where('listUtilizadores', arrayContains: userlogged!.uid)
        .snapshots();
  }

}