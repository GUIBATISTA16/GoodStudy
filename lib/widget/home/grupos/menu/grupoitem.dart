import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/grupo.dart';
import 'package:projeto_goodstudy/services/msgsgrupodatabase.dart';
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import '../../../../objects/fuser.dart';
import '../../../../objects/mensagem.dart';
import '../../../../screens/grupo.dart';
import '../../../../globais/widgetglobal.dart';
import '../../../../services/userdatabase.dart';

class ItemListaG extends StatefulWidget {

  final GrupoObject grupo;
  final List<FUser> listUsers;
  final FUser explicador;

  const ItemListaG({super.key, required this.grupo, required this.listUsers, required this.explicador});

  @override
  State<ItemListaG> createState() => _ItemListaGState();
}

class _ItemListaGState extends State<ItemListaG> {

  FUser? user;

  Future getUser(String uid) async {
    DocumentSnapshot doc = await UserDatabaseService(uid: globals.userlogged!.uid).getDataWithUid(uid);
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    user = FUser(uid: doc.id, isAnonymous: false);
    user!.nome = data['nome'];
    user!.tipo = data['tipo'];
    user!.photoUrl = data['photoUrl'];
    user!.nivel = data['nivel'];
    user!.ano = data['ano'];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Grupo(grupo: widget.grupo, listUsers: widget.listUsers, explicador: widget.explicador,)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        /*decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
        ),*/
        child: Carde(
          child: ListTile(
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(child: SizedBox(width: 35,height: 35,child: FotoPerfil(photoUrl: widget.explicador.photoUrl,size: 30,loading: false,),)),
                Positioned(left: 10,top: 10,child: SizedBox(child: FotoPerfil(photoUrl: widget.listUsers[0].photoUrl,size: 30,loading: false), width: 35,height: 35,),),
              ],
            ),
            title: Text(widget.grupo.nome),
            subtitle: StreamBuilder(
                stream: MsgsGrupoDatabaseService(grupoId: widget.grupo.docId).streamMsgs,
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
                      String nome = '';
                      if(listMsgs.last.remetente != '1'){
                        if(listMsgs.last.remetente != globals.userlogged?.uid){
                          int i;
                          for(i = 0; i< widget.listUsers.length; i++){
                            if(widget.listUsers[i].uid == listMsgs.last.remetente){
                              nome = widget.listUsers[i].nome!;
                              break;
                            }
                          }
                          if(i == widget.listUsers.length){
                            return FutureBuilder(
                                future: getUser(listMsgs.last.remetente),
                                builder: (context,snapshot){
                                  if(user == null){
                                    return const Text('',);
                                  }
                                  else {
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
                                }
                            );
                          }
                          else{
                            if(listMsgs.last.tipo == 'texto'){
                              return Text('$nome: ${listMsgs.last.texto!}', maxLines: 2,);
                            }
                            else if(listMsgs.last.tipo == 'imagem'){
                              return Text('$nome enviou uma imagem', maxLines: 2,);
                            }
                            else if(listMsgs.last.tipo == 'video'){
                              return Text('$nome enviou um video', maxLines: 2,);
                            }
                            else{
                              return Text('$nome enviou um documento', maxLines: 2,);
                            }
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

