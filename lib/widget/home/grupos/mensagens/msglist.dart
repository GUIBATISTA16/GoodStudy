import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/mensagem.dart';
import 'package:projeto_goodstudy/services/msgsgrupodatabase.dart';
import 'package:projeto_goodstudy/widget/home/grupos/mensagens/msggrupoitem.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

import '../../../../objects/fuser.dart';
import '../../../../objects/grupo.dart';

class MsgsLista extends StatefulWidget {
  final GrupoObject grupo;
  final List<FUser> listUsers;
  const MsgsLista({super.key,
    required this.grupo,
    required this.listUsers,
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
      stream: MsgsGrupoDatabaseService(grupoId: widget.grupo.docId).streamMsgs,
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
                  if(listMsgs[index].remetente != globals.userlogged?.uid){
                    int user = -1;
                    for(int i = 0; i< widget.listUsers.length; i++){
                      if(widget.listUsers[i].uid == listMsgs[index].remetente){
                        user = i;
                        break;
                      }
                    }
                    if(user == -1){
                      return MensagemGrupo(
                        msg: listMsgs[index],
                        user: null,
                        cId: widget.grupo.docId,
                      );
                    }
                    return MensagemGrupo(
                      msg: listMsgs[index],
                      user: widget.listUsers[user],
                      cId: widget.grupo.docId,
                    );
                  }
                  else{
                    return MensagemGrupo(
                      msg: listMsgs[index],
                      user: globals.userlogged!,
                      cId: widget.grupo.docId,
                    );
                  }
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