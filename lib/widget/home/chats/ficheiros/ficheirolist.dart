import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/chat.dart';
import 'package:projeto_goodstudy/objects/mensagem.dart';
import 'package:projeto_goodstudy/services/msgschatdatabase.dart';

import '../../ficheiroitem.dart';

class FicheirosLista extends StatefulWidget {
  final ChatObject chat;
  final String? destinatarioPhotoUrl;
  const FicheirosLista({super.key,
    required this.chat,
    required this.destinatarioPhotoUrl,
  });

  @override
  _FicheirosListaState createState() => _FicheirosListaState();
}

class _FicheirosListaState extends State<FicheirosLista> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MsgsChatDatabaseService(chatId: widget.chat.docID).streamMsgs,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text(''));
        }
        List<MensagemObject> listMsgs = snapshot.data!.docs
            .where((doc) => doc['tipo'] == 'ficheiro')
            .map((doc) {
          return MensagemObject(
            remetente: doc['remetente'],
            tipo: doc['tipo'],
            data: doc['data'],
            texto: doc['texto'],
            fileUrl: doc['ficheiro'],
            filename: doc['filename'],
            width: doc['width'],
            aspectRatio: doc['aspectRatio'],
          );
        }).toList();
        listMsgs = listMsgs.reversed.toList();
        return ListView.builder(
          //cacheExtent: 999999,
          controller: scrollController,
          itemCount: listMsgs.length,
          itemBuilder: (context, index) {
            return ItemFicheiro(
              msg: listMsgs[index],
            );
          },
        );
      },
    );
  }
}