import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import 'package:projeto_goodstudy/services/pedidodatabase.dart';
import 'package:projeto_goodstudy/widget/fotoperfil.dart';

import '../../../objects/fuser.dart';
import '../../../objects/pedido.dart';
import '../../../screens/perfilexplicador.dart';


class PedidoPendente extends StatefulWidget {
  final Pedido pedido;
  final FUser user;

  const PedidoPendente({super.key, required this.pedido, required this.user});

  @override
  State<PedidoPendente> createState() => _PedidoPendenteState();
}

class _PedidoPendenteState extends State<PedidoPendente> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerfilExplicador(explicador: widget.user, origem: 'Chat',)),
          );
        },
        child: Carde(
          child: ListTile(
            leading: FotoPerfil(photoUrl: widget.user.photoUrl, size: 50),
            title: Text(widget.user.nome!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.especialidade!,
                  style: const TextStyle(fontSize: 15),
                ),
                if (widget.pedido.texto != null && widget.pedido.texto!.isNotEmpty)
                  const Divider(
                    color: Colors.grey,
                    height: 2,
                    thickness: 1,
                  ),
                if (widget.pedido.texto != null && widget.pedido.texto!.isNotEmpty)
                  Text(widget.pedido.texto!),
              ],
            ),
            trailing: IconButton(
              onPressed: (){
                PedidoDatabaseService().cancel(widget.pedido.docID);
              },
              icon: const Icon(Icons.cancel,color: Colors.red,),
            ),
          )
        ),
      ),
    );
  }
}
