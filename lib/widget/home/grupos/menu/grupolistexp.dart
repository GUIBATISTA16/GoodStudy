import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/grupo.dart';
import 'package:projeto_goodstudy/services/gruposdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/widget/home/grupos/menu/grupoitem.dart';
import '../../../../objects/fuser.dart';
import '../../../../services/userdatabase.dart';
import '../../../loading.dart';

class GruposListaExp extends StatefulWidget {
  const GruposListaExp({super.key});

  @override
  State<GruposListaExp> createState() => _GruposListaExpState();
}

class _GruposListaExpState extends State<GruposListaExp> {
  List<GrupoObject> listGrupos = [];
  Map<String, List<FUser>> grupoUsers = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    primeirosDados();
  }

  Future<void> primeirosDados() async {
    setState(() {
      loading = true;
    });

    final snapshot = await GruposDatabaseService().streamExpGrupos.first;
    final List<GrupoObject> grupos = snapshot.docs.map((doc) {
      return GrupoObject(
          docId: doc.id,
          uidExplicador: doc['uidExplicador'],
          listExplicandos: doc['listExplicandos'],
          nome: doc['nome'],
      );
    }).toList();

    for (var grupo in grupos) {
      final users = await getUsers(grupo.listExplicandos);
      grupoUsers[grupo.docId] = users;
    }

    setState(() {
      listGrupos = grupos;
      loading = false;
    });
  }

  Future<List<FUser>> getUsers(List<dynamic> listUid) async {
    final UserDatabaseService userDb = UserDatabaseService(uid: globals.userlogged!.uid);

    List<FUser> users = [];
    for (String uid in listUid) {
      DocumentSnapshot snapshot = await userDb.getDataWithUid(uid);
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      FUser u = FUser(
        uid: uid,
        isAnonymous: false,
      );
      u.nome = data['nome'];
      u.tipo = data['tipo'];
      u.photoUrl = data['photoUrl'];
      u.nivel = data['nivel'];
      u.ano = data['ano'];
      users.add(u);
    }

    return users;
  }

  void updateGrupoUsers(GrupoObject grupo) async {
    final users = await getUsers(grupo.listExplicandos);
    setState(() {
      grupoUsers[grupo.docId] = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: GruposDatabaseService().streamExpGrupos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && loading) {
          return const Center(child: Loading());
        } else if (snapshot.hasError) {
          return Expanded(child: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Expanded(child: Center(child: Text('Não tem Grupos atualmente')));
        } else {
          final List<GrupoObject> grupos = snapshot.data!.docs.map((doc) {
            return GrupoObject(
                docId: doc.id,
                uidExplicador: doc['uidExplicador'],
                listExplicandos: doc['listExplicandos'],
                nome: doc['nome'],
            );
          }).toList();

          // Update the list of groups and users in memory
          for (var grupo in grupos) {
            if (!grupoUsers.containsKey(grupo.docId)) {
              updateGrupoUsers(grupo);
            }
          }
          listGrupos = grupos;
          loading = false;
          return ListView.builder(
            itemCount: listGrupos.length,
            itemBuilder: (context, index) {
              final grupo = listGrupos[index];
              final users = grupoUsers[grupo.docId];

              return users == null
                  ? Container(height: 100, child: const Center(child: Loading()))
                  : ItemListaG(grupo: grupo, listUsers: users, explicador: globals.userlogged!);
            },
          );
        }
      },
    );
  }
}
