import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/chat.dart';
import 'package:projeto_goodstudy/objects/mensagem.dart';
import 'package:projeto_goodstudy/services/msgschatdatabase.dart';
import 'package:projeto_goodstudy/widget/home/chats/mensagens/msgchatitem.dart';

class MsgsLista extends StatefulWidget {
  final ChatObject chat;
  final String? destinatarioPhotoUrl;
  const MsgsLista({super.key,
    required this.chat,
    required this.destinatarioPhotoUrl,
  });

  @override
  _MsgsListaState createState() => _MsgsListaState();
}

class _MsgsListaState extends State<MsgsLista> {
  ScrollController scrollController = ScrollController();

  bool botaoscroll = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.position.pixels >
        scrollController.position.minScrollExtent + 100 && !botaoscroll) {
      setState(() {
        botaoscroll = true;
      });
    }
    if(scrollController.position.pixels <=
        scrollController.position.minScrollExtent + 100 && botaoscroll) {
      setState(() {
        botaoscroll = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MsgsChatDatabaseService(chatId: widget.chat.docID).streamMsgs,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text(''));
        }
        else{
          List<MensagemObject> listMsgs = snapshot.data!.docs.map((doc) {
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
          return Stack(
            children: [
              ListView.builder(
                cacheExtent: 999999,
                controller: scrollController,
                reverse: true,
                itemCount: listMsgs.length,
                itemBuilder: (context, index) {
                  return MensagemChat(
                    msg: listMsgs[index],
                    destinatarioPhotoUrl: widget.destinatarioPhotoUrl,
                    cId: widget.chat.docID,
                  );
                },
              ),
              if (botaoscroll)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      scrollController.animateTo(
                        scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        size: 20,
                        Icons.keyboard_double_arrow_down,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}