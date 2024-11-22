import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/chat.dart';
import 'package:projeto_goodstudy/screens/chat.dart';
import 'package:projeto_goodstudy/screens/perfilexplicador.dart';
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import '../../../../objects/fuser.dart';
import '../../../../objects/mensagem.dart';
import '../../../../screens/perfilexplicando.dart';
import '../../../../services/msgschatdatabase.dart';

class ItemListaC extends StatelessWidget {
  final ChatObject chat;
  final FUser? user;

  const ItemListaC({super.key, required this.chat, this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(user: user!, chat: chat)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        /*decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
        ),*/
        child: Carde(
          color: chat.estado! == 'Ativo' ? Colors.green[50]! : Colors.red[50]!,
          child: ListTile(
            leading: GestureDetector(
              onTap: () {
                user?.tipo == 'Explicador'
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PerfilExplicador(explicador: user!, origem: 'Chat',)),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PerfilExplicando(explicando: user!)),
                    );
              },
              child: FotoPerfil(photoUrl: user!.photoUrl,size: 50,)
            ),
            title: Text(user!.nome!),
            subtitle: StreamBuilder(
              stream: MsgsChatDatabaseService(chatId: chat.docID).streamMsgs,
                builder: (context, snapshot) {
                  try{
                    if (!snapshot.hasData) {
                      return const Text('');
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

                      if(listMsgs.last.remetente != '1'){
                        if(listMsgs.last.remetente != globals.userlogged?.uid){
                          if(listMsgs.last.tipo == 'texto'){
                            return Text('${user!.nome}: ${listMsgs.last.texto!}', maxLines: 2,);
                          }
                          else if(listMsgs.last.tipo == 'imagem'){
                            return Text('${user!.nome} enviou uma imagem', maxLines: 2,);
                          }
                          else if(listMsgs.last.tipo == 'video'){
                            return Text('${user!.nome} enviou um video', maxLines: 2,);
                          }
                          else{
                            return Text('${user!.nome} enviou um documento', maxLines: 2,);
                          }
                        }
                        else{
                          if(listMsgs.last.tipo == 'texto'){
                            return Text('Você: ${listMsgs.last.texto!}', maxLines: 2,);
                          }
                          else if(listMsgs.last.tipo == 'imagem'){
                            return const Text('Você enviou uma imagem', maxLines: 2,);
                          }
                          else if(listMsgs.last.tipo == 'video'){
                            return const Text('Você enviou um video', maxLines: 2,);
                          }
                          else{
                            return const Text('Você enviou um documento', maxLines: 2,);
                          }
                        }
                      }
                      else{
                        return Text(listMsgs.last.texto!, maxLines: 2,);
                      }

                    }
                  } catch(e){
                    return const Text('');
                  }
                }
            ),
          ),
        ),
      ),
    );
  }
}
