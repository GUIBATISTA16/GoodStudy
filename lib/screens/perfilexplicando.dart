import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import '../globais/colorsglobal.dart';
import '../objects/chat.dart';
import '../services/chatdatabase.dart';
import 'chat.dart';

class PerfilExplicando extends StatefulWidget {
  final FUser explicando;
  const PerfilExplicando({super.key, required this.explicando});

  @override
  State<PerfilExplicando> createState() => _PerfilExplicandoState();
}

class _PerfilExplicandoState extends State<PerfilExplicando> {

  bool hasChat = false;
  Future checkChat() async {
    final ChatDatabaseService db = ChatDatabaseService();
    hasChat = await db.checkChat(globals.userlogged!.uid, widget.explicando.uid);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if(globals.userlogged!.tipo == 'Explicador'){
      checkChat();
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
        title: Text('Perfil de ${widget.explicando.nome}',
          style: const TextStyle(
              color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 8,),
                widget.explicando.photoUrl == null
                    ? const CircleAvatar(
                    radius: 70,
                    child: Icon(Icons.person, size: 110)
                )
                    : CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                      '${widget.explicando.photoUrl}'),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.explicando.nome!,
                          style: const TextStyle(
                              fontSize: 26
                          ),
                        ),
                        const Text('Nivel de escolaridade atual: ',
                          style: TextStyle(
                              fontSize: 15
                          ),
                        ),
                        Text(widget.explicando.nivel!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),
                        const Text('Ano de escolaridade atual: ',
                          style: TextStyle(
                              fontSize: 15
                          ),
                        ),
                        Text(widget.explicando.ano!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
              height: 2,
              thickness: 1,
            ),
            if (hasChat == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                  ),
                  onPressed: () {
                    ChatObject chat = ChatObject(docID: '${globals.userlogged!.uid.substring(0,3)}_${widget.explicando.uid.substring(0,3)}'
                      , uidExplicador: globals.userlogged!.uid, uidExplicando: widget.explicando.uid,);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Chat(user: widget.explicando, chat: chat))
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
      ),
    );
  }
}
