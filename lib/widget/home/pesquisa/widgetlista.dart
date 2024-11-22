import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/screens/perfilexplicador.dart';
import 'package:projeto_goodstudy/services/pedidodatabase.dart';
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/widget/loading.dart';

import '../../../globais/colorsglobal.dart';
import '../../../globais/functionsglobal.dart';
import '../../../objects/chat.dart';
import '../../../screens/chat.dart';
import '../../../services/chatdatabase.dart';
import '../../../globais/widgetglobal.dart';


class CampoLista extends StatefulWidget {
  final FUser user;
  const CampoLista({super.key, required this.user});

  @override
  State<CampoLista> createState() => _CampoListaState(user: user);
}

class _CampoListaState extends State<CampoLista> {
  final FUser user;
  _CampoListaState({required this.user});

  bool loading = false;
  Future sendPedido() async {
    setState(() {
      loading = true;
    });
    final PedidoDatabaseService db = PedidoDatabaseService();
    await db.insertPedido(user.uid, globals.userlogged!.uid, textoController.text);
    setState(() {
      loading = false;
    });
  }

  final textoController = TextEditingController();

  void showmodal(){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              20.0,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.only(
          top: 10.0,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Enviar Pedido a",
                  style: TextStyle(fontSize: 24.0),
                ),
                const Expanded(child: SizedBox()),
                FotoPerfil(photoUrl: user.photoUrl,size: 50,),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Text(
                    user.nome!,
                    style: const TextStyle(
                      fontSize: 21
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        content: Container (
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16,0,8,8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8,8,8,0),
                  child: Text(
                    "Pedido",
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: null,
                    controller: textoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: preto),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: preto),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: preto),
                      ),
                      labelStyle: TextStyle(color: preto),
                      hintText: 'Texto para mandar no pedido',
                      labelText: 'Texto (opcional)'),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      sendPedido();
                      hasPedido = true;
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      // fixedSize: Size(250, 50),
                    ),
                    child: const Text(
                      "Enviar Pedido",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Nota'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Caso o Explicador aceite o pedido será criado um chat entre os dois automaticamente',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                loading ? const Loading() : Container()
              ],
            ),
          ),
        ),
      );
    });
  }

  bool hasChat = false;
  Future checkChat() async {
    final ChatDatabaseService db = ChatDatabaseService();
    hasChat = await db.checkChat(user.uid, globals.userlogged!.uid);
    setState(() {});
  }

  bool hasPedido = false;
  Future checkPedido() async {
    final PedidoDatabaseService db = PedidoDatabaseService();
    hasPedido = await db.checkPedido(user.uid, globals.userlogged!.uid);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkChat();
    if(!hasChat){
      checkPedido();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PerfilExplicador(explicador: user, origem: 'Pesquisa',)),
          );
        },
        child: Container(
          child: Row(
            children: [
              FotoPerfil(photoUrl: user.photoUrl,size: 50,),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                              user.nome!,
                              textAlign: TextAlign.start
                          ),
                        ),
                        const SizedBox(width: 10,),
                        user.precohr != null
                            ? Container(
                          child: Text(
                            '${user.precohr.toString()}€/hr',
                            textAlign: TextAlign.start,
                          ),
                        )
                            : user.precomes != null
                            ? Container(
                          child: Text(
                            '${user.precomes.toString()}€/mes',
                            textAlign: TextAlign.start,
                          ),
                        )
                            : Container(
                          child: Text(
                            '${user.precoano.toString()}€/ano',
                            textAlign: TextAlign.start,
                          ),
                        )

                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 2,
                      thickness: 1,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            user.especialidade!,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        //SizedBox(width: 10,),
                        SizedBox(width: 80, child:Avaliacao(rating: user.avaliacao != null ? user.avaliacao! : 0,size: 15,))
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: !hasChat
                      ? !hasPedido
                          ? ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
                              ),
                              onPressed: !globals.userlogged!.isAnonymous
                                  ? () {
                                showmodal();
                              }
                                  : () {
                                showCustomSnackBar(context, 'Para enviar um pedido tem de fazer login!');
                              },
                              child: Text('Enviar Pedido',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: !globals.userlogged!.isAnonymous
                                        ? textoPrincipal
                                        : deactivatedButton
                                ),
                              ),
                            )
                          : ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
                              ),
                              onPressed: () {
                                showCustomSnackBar(context, 'Já tem um pedido enviado');
                              },
                              child: Text('Enviar Pedido',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: deactivatedButton
                                ),
                              ),
                            )
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                    ),
                    onPressed: () {
                      ChatObject chat = ChatObject(docID: '${user.uid.substring(0,3)}_${globals.userlogged!.uid.substring(0,3)}'
                        , uidExplicador: user.uid, uidExplicando: globals.userlogged!.uid,);
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Chat(user: user, chat: chat))
                      );
                    },
                    child: const Text(
                      'Ir para Chat',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
