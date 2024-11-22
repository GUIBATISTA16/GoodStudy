import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/pedido.dart';
import 'package:projeto_goodstudy/widget/home/pedidos/pedidoitem.dart';
import 'package:projeto_goodstudy/widget/loading.dart';

import '../../../objects/fuser.dart';
import '../../../services/pedidodatabase.dart';
import '../../../services/userdatabase.dart';

class PedidosLista extends StatefulWidget {
  const PedidosLista({super.key});

  @override
  _PedidosListaState createState() => _PedidosListaState();
}

class _PedidosListaState extends State<PedidosLista> {
  List<Pedido> listPedido = [];
  Map<String, FUser> pedidoUsers = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    primeirosDados();
  }

  Future<void> primeirosDados() async {
    setState(() {
      loading = true;
    });

    final snapshot = await PedidoDatabaseService().streamPedidos.first;
    final List<Pedido> pedidos = snapshot.docs.map((doc) {
      return Pedido(
        docID: doc.id,
        uidDestinatario: doc['uidDestinatario'],
        uidRemetente: doc['uidRemetente'],
        texto: doc['texto'],
      );
    }).toList();

    for (var pedido in pedidos) {
      final user = await getUser(pedido.uidRemetente);
      pedidoUsers[pedido.uidRemetente] = user;
    }

    setState(() {
      listPedido = pedidos;
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
    u.ano = data['ano'];
    u.nivel = data['nivel'];
    u.photoUrl = data['photoUrl'];
    return u;
  }

  void updatePedidoUsers(Pedido pedido) async {
    final user = await getUser(pedido.uidRemetente);
    setState(() {
      pedidoUsers[pedido.uidRemetente] = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: PedidoDatabaseService().streamPedidos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && loading) {
          return const Expanded(child: Center(child: Loading()));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Expanded(child: Center(child: Text('Não tem Pedidos atualmente')));
        } else {
          final List<Pedido> pedidos = snapshot.data!.docs.map((doc) {
            return Pedido(
              docID: doc.id,
              uidDestinatario: doc['uidDestinatario'],
              uidRemetente: doc['uidRemetente'],
              texto: doc['texto'],
            );
          }).toList();

          for (var pedido in pedidos) {
            if (!pedidoUsers.containsKey(pedido.uidRemetente)) {
              updatePedidoUsers(pedido);
            }
          }

          listPedido = pedidos;
          loading = false;

          return Expanded(
            child: ListView.builder(
              itemCount: listPedido.length,
              itemBuilder: (context, index) {
                final pedido = listPedido[index];
                final user = pedidoUsers[pedido.uidRemetente];

                return user == null
                    ? Container(height: 100, child: const Center(child: Loading()))
                    : ItemListaP(
                  pedido: pedido,
                  user: user,
                );
              },
            ),
          );
        }
      },
    );
  }
}
