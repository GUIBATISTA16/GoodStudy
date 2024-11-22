import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/chat.dart';
import 'package:projeto_goodstudy/objects/mensagem.dart';
import 'package:projeto_goodstudy/services/msgschatdatabase.dart';

import '../../ficheiroitem.dart';

class VideosLista extends StatefulWidget {
  final ChatObject chat;
  final String? destinatarioPhotoUrl;
  const VideosLista({super.key,
    required this.chat,
    required this.destinatarioPhotoUrl,
  });

  @override
  _VideosListaState createState() => _VideosListaState();
}

class _VideosListaState extends State<VideosLista> {
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
            .where((doc) => doc['tipo'] == 'video')
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
        return GridView.builder(
          //cacheExtent: 999999,
          controller: scrollController,
          itemCount: listMsgs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 1,
          ),
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