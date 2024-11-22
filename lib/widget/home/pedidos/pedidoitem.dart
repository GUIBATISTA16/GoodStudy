import 'package:projeto_goodstudy/screens/perfilexplicando.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/objects/pedido.dart';
import 'package:projeto_goodstudy/services/chatdatabase.dart';
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import '../../../services/msgschatdatabase.dart';
import '../../../services/pedidodatabase.dart';


class ItemListaP extends StatelessWidget {
  final Pedido pedido;
  final FUser? user;

  const ItemListaP({super.key, required this.pedido, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                child: FotoPerfil(photoUrl: user!.photoUrl,size: 50,),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PerfilExplicando(explicando: user!)),
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.nome!,
                        style: const TextStyle(fontSize: 19),
                      ),
                      Row(
                        children: [
                          Text(
                            user!.nivel!,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 8,),
                          Text(
                            user!.ano!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      if (pedido.texto != null && pedido.texto!.isNotEmpty)
                        const Divider(
                          color: Colors.grey,
                          height: 2,
                          thickness: 1,
                        ),
                      if (pedido.texto != null && pedido.texto!.isNotEmpty)
                        Text(pedido.texto!),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green),
                  ),
                  onPressed: () {
                    PedidoDatabaseService().accept(pedido.docID);
                    ChatDatabaseService().createChat(globals.userlogged!.uid, user!.uid);
                    MsgsChatDatabaseService(chatId:'${globals.userlogged!.uid.substring(0,3)}_${user!.uid.substring(0,3)}')
                        .sendMensage('1', 'Este chat foi iniciado');
                  },
                  child: Container(
                    width: 100,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        Text(
                          'Aceitar',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                  ),
                  onPressed: () {
                    final PedidoDatabaseService db = PedidoDatabaseService();
                    db.reject(pedido.docID);
                  },
                  child: Container(
                    width: 100,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.clear, color: Colors.white),
                        Text(
                          'Recusar',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}