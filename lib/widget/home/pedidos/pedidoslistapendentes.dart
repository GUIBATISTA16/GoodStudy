import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/pedido.dart';
import 'package:projeto_goodstudy/widget/home/pedidos/pedidopendenteitem.dart';
import 'package:projeto_goodstudy/widget/loading.dart';

import '../../../objects/fuser.dart';
import '../../../services/pedidodatabase.dart';
import '../../../services/userdatabase.dart';

class PedidosPendentesLista extends StatefulWidget {
  const PedidosPendentesLista({super.key});

  @override
  _PedidosPendentesListaState createState() => _PedidosPendentesListaState();
}

class _PedidosPendentesListaState extends State<PedidosPendentesLista> {
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

    final snapshot = await PedidoDatabaseService().streamPedidosPendentes.first;
    final List<Pedido> pedidos = snapshot.docs.map((doc) {
      return Pedido(
        docID: doc.id,
        uidDestinatario: doc['uidDestinatario'],
        uidRemetente: doc['uidRemetente'],
        texto: doc['texto'],
      );
    }).toList();

    for (var pedido in pedidos) {
      final user = await getUser(pedido.uidDestinatario);
      pedidoUsers[pedido.uidDestinatario] = user;
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

  void updatePedidoUsers(Pedido pedido) async {
    final user = await getUser(pedido.uidDestinatario);
    setState(() {
      pedidoUsers[pedido.uidDestinatario] = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: PedidoDatabaseService().streamPedidosPendentes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && loading) {
          return const Expanded(child: Center(child: Loading()));
        } else if (snapshot.hasError) {
          return Expanded(child: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Expanded(child: Center(child: Text('Não tem Pedidos pendentes')));
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
            if (!pedidoUsers.containsKey(pedido.uidDestinatario)) {
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
                final user = pedidoUsers[pedido.uidDestinatario];

                return user == null
                    ? Container(height: 100, child: const Center(child: Loading()))
                    : PedidoPendente(
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
