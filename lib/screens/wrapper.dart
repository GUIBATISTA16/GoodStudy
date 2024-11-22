import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/screens/home.dart';
import 'package:projeto_goodstudy/screens/login.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:provider/provider.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

import '../objects/fuser.dart';
import '../services/userdatabase.dart';

class Wrapper extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const Wrapper({super.key, required this.navigatorKey});

  Future preencheFUser (dynamic result) async {

    final UserDatabaseService db = UserDatabaseService(uid: result.uid);
    DocumentSnapshot snapshot = await db.getDataWithUid(result.uid);
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    globals.userlogged = FUser(uid: result.uid, isAnonymous: result.isAnonymous);
    globals.userlogged?.nome = data['nome'];
    globals.userlogged?.tipo = data['tipo'];
    globals.userlogged?.photoUrl = data['photoUrl'];
    if(data['tipo'] == 'Explicador'){
      globals.userlogged?.anosexp = data['anosexp'];
      globals.userlogged?.especialidade = data['especialidade'];
      globals.userlogged?.descricao = data['descricao'];
      globals.userlogged?.precohr = data['precohora'];
      globals.userlogged?.precomes = data['precomes'];
      globals.userlogged?.precoano = data['precoano'];
      globals.userlogged?.avaliacao = double.tryParse(data['avaliacao'].toString());
    }
    else{
      globals.userlogged?.nivel = data['nivel'];
      globals.userlogged?.ano = data['ano'];
    }
  }

  Future preencheAUser (dynamic result) async {
    globals.userlogged = FUser(uid: result.uid, isAnonymous: result.isAnonymous);
    globals.userlogged?.tipo='Explicando';
    globals.userlogged?.photoUrl = null;
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);

    return user == null
      ? const Login()
      : FutureBuilder(
          future: user.isAnonymous
            ? preencheAUser(user)
            : preencheFUser(user),
          builder: (context,snapshot){
            if(globals.userlogged == null){
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.blue[900],
                  title: const Text('GoodStudy',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
                body: const Center(child: Loading(),),
              );
            }
            else{
              return Home(navigatorKey: navigatorKey,);
            }
          },
        );
  }
}
