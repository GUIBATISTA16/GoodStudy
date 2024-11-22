import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/chat.dart';
import 'package:projeto_goodstudy/services/chatdatabase.dart';
import 'package:projeto_goodstudy/widget/home/chats/menu/chatitem.dart';

import '../../../../objects/fuser.dart';
import '../../../../services/userdatabase.dart';
import '../../../loading.dart';

class ChatslistaAlu extends StatefulWidget {
  const ChatslistaAlu({super.key});

  @override
  _ChatslistaAluState createState() => _ChatslistaAluState();
}

class _ChatslistaAluState extends State<ChatslistaAlu> {
  List<ChatObject> listChat = [];
  Map<String, FUser> chatUsers = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      loading = true;
    });

    final snapshot = await ChatDatabaseService().streamAluChats.first;
    final List<ChatObject> chats = snapshot.docs.map((doc) {
      return ChatObject(
        docID: doc.id,
        uidExplicador: doc['uidExplicador'],
        uidExplicando: doc['uidExplicando'],
      );
    }).toList();

    for (var chat in chats) {
      final user = await getUser(chat.uidExplicador);
      chatUsers[chat.uidExplicador] = user;
    }

    setState(() {
      listChat = chats;
      loading = false;
    });
  }

  Future<FUser> getUser(String uidRemetente) async {
    final UserDatabaseService db = UserDatabaseService(uid: uidRemetente);
    DocumentSnapshot snapshot = await db.getDataWithUid(uidRemetente);
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    FUser u = FUser(uid: uidRemetente, isAnonymous: false);
    u.nome = data['nome'];
    u.tipo = data['tipo'];
    u.photoUrl = data['photoUrl'];
    u.especialidade = data['especialidade'];
    u.anosexp = data['anosexp'];
    u.precohr = data['precohora'];
    u.precomes = data['precomes'];
    u.precoano = data['precoano'];
    u.descricao = data['descricao'];
    u.avaliacao = double.tryParse(data['avaliacao'].toString());
    return u;
  }

  void updateChatUsers(ChatObject chat) async {
    final user = await getUser(chat.uidExplicador);
    setState(() {
      chatUsers[chat.uidExplicador] = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ChatDatabaseService().streamAluChats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && loading) {
          return const Center(child: Loading());
        } else if (snapshot.hasError) {
          return Expanded(child: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Expanded(child: Center(child: Text('Não tem Chats atualmente')));
        } else {
          final List<ChatObject> chats = snapshot.data!.docs.map((doc) {
            return ChatObject(
              docID: doc.id,
              uidExplicador: doc['uidExplicador'],
              uidExplicando: doc['uidExplicando'],
              estado: doc['estado'],
              hasAnswered: doc['estado'] == 'Inativo'
                ? doc['hasAnswered'] : null
            );
          }).toList();

          for (var chat in chats) {
            if (!chatUsers.containsKey(chat.uidExplicador)) {
              updateChatUsers(chat);
            }
          }

          listChat = chats;
          loading = false;

          return ListView.builder(
            itemCount: listChat.length,
            itemBuilder: (context, index) {
              final chat = listChat[index];
              final user = chatUsers[chat.uidExplicador];

              return user == null
                  ? Container(height: 100, child: const Center(child: Loading()))
                  : ItemListaC(
                chat: chat,
                user: user,
              );
            },
          );
        }
      },
    );
  }
}
