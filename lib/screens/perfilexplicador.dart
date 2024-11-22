import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/chat.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/screens/chat.dart';
import 'package:projeto_goodstudy/services/chatdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import '../globais/colorsglobal.dart';
import '../globais/functionsglobal.dart';
import '../services/pedidodatabase.dart';
import '../widget/fotoperfil.dart';
import '../widget/loading.dart';
import '../globais/widgetglobal.dart';

class PerfilExplicador extends StatefulWidget {
  final FUser explicador;
  final String origem;

  const PerfilExplicador({super.key, required this.explicador, required this.origem});

  @override
  State<PerfilExplicador> createState() => _PerfilExplicadorState();
}

class _PerfilExplicadorState extends State<PerfilExplicador> {
  bool loading = false;
  final textoController = TextEditingController();

  Future sendPedido() async {
    setState(() {
      loading = true;
    });
    final PedidoDatabaseService db = PedidoDatabaseService();
    await db.insertPedido(widget.explicador.uid, globals.userlogged!.uid, textoController.text);
    setState(() {
      loading = false;
    });
  }

  bool hasChat = false;
  Future checkChat() async {
    final ChatDatabaseService db = ChatDatabaseService();
    hasChat = await db.checkChat(widget.explicador.uid, globals.userlogged!.uid);
    setState(() {});
  }

  bool hasPedido = false;
  Future checkPedido() async {
    final PedidoDatabaseService db = PedidoDatabaseService();
    hasPedido = await db.checkPedido(widget.explicador.uid, globals.userlogged!.uid);
    setState(() {});
  }

  void showmodal() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        contentPadding: const EdgeInsets.only(top: 10.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Enviar Pedido a", style: TextStyle(fontSize: 24.0)),
                const Expanded(child: SizedBox()),
                FotoPerfil(photoUrl: widget.explicador.photoUrl,size: 50,),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Text(widget.explicador.nome!, style: const TextStyle(fontSize: 21)),
                ),
              ],
            )
          ],
        ),
        content: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text("Pedido"),
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
                    labelText: 'Texto (opcional)',
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    sendPedido();
                    setState(() {
                      hasPedido = true;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                  ),
                  child: const Text(
                    "Enviar Pedido",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Caso o Explicador aceite o pedido será criado um chat entre os dois automaticamente',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              loading ? const Loading() : Container(),
            ],
          ),
        ),
      );
    });
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
    return Scaffold(
      appBar: AppBar(
        leading: BackButao(
          color: textoPrincipal,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        title: Text('Perfil de ${widget.explicador.nome}',
          style: const TextStyle(
              color: Colors.white
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8),
                    widget.explicador.photoUrl == null
                        ? const CircleAvatar(
                      radius: 70,
                      child: Icon(Icons.person, size: 110),
                    )
                        : CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(widget.explicador.photoUrl!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.explicador.nome!, style: const TextStyle(fontSize: 26)),
                            Text(widget.explicador.especialidade!, style: const TextStyle(fontSize: 19)),
                            Text('Anos de Experiência: ${widget.explicador.anosexp}', style: const TextStyle(fontSize: 15)),
                            Text(widget.explicador.descricao!, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                widget.explicador.avaliacao != null
                ? Padding(
                  padding: const EdgeInsets.fromLTRB(8.0,2,8,2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Avaliação: ${widget.explicador.avaliacao!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18
                        ),
                      ),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Avaliacao(rating: widget.explicador.avaliacao!),
                      )),
                    ],
                  ),
                )
                : const Padding(
                  padding: EdgeInsets.fromLTRB(8.0,2,8,2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Avaliação: ainda sem avaliação',
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      /*Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Avaliacao(rating: 0),
                      )),*/
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  height: 2,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade700,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                    columnWidths: const <int, TableColumnWidth>{
                      0: FixedColumnWidth(111.0),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        children: [
                          Text(
                            'Tipo',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Preço',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (widget.explicador.precohr != null)
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por hora'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${widget.explicador.precohr}€'),
                            ),
                          ],
                        ),
                      if (widget.explicador.precomes != null)
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por mês'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${widget.explicador.precomes}€'),
                            ),
                          ],
                        ),
                      if (widget.explicador.precoano != null)
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por ano '),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${widget.explicador.precoano}€'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Padding(
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
                      ChatObject chat = ChatObject(docID: '${widget.explicador.uid.substring(0,3)}_${globals.userlogged!.uid.substring(0,3)}'
                        , uidExplicador: widget.explicador.uid, uidExplicando: globals.userlogged!.uid,);
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Chat(user: widget.explicador, chat: chat))
                      );
                    },
                    child: const Text(
                      'Ir para Chat',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
