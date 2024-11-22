import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/screens/perfil.dart';
import 'package:projeto_goodstudy/services/chatdatabase.dart';
import 'package:projeto_goodstudy/services/gruposdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import '../../../../objects/fuser.dart';
import '../../../../services/userdatabase.dart';
import '../../../globais/colorsglobal.dart';
import '../../../objects/grupo.dart';
import '../../../services/msgsgrupodatabase.dart';
import '../../fotoperfil.dart';
import '../../loading.dart';

class AdicionarParticipantes extends StatefulWidget {
  final GrupoObject grupo;
  final List<FUser> listUsers;
  const AdicionarParticipantes({super.key, required this.grupo, required this.listUsers});

  @override
  State<AdicionarParticipantes> createState() => _AdicionarParticipantesState();
}

class _AdicionarParticipantesState extends State<AdicionarParticipantes> {
  List<FUser> listUsers = [];
  List<FUser> selectedUsers = [];
  late Future<List<FUser>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = getUsers();
  }

  Future<List<FUser>> getUsers() async {

    final listUid = await ChatDatabaseService().getListExplicandos();
    List<String> listparticipantes = [];
    widget.listUsers.forEach((user){
      listparticipantes.add(user.uid);
    });

    List<FUser> users = [];
    for (String uid in listUid) {
      DocumentSnapshot snapshot = await UserDatabaseService(uid: globals.userlogged!.uid).getDataWithUid(uid);
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      FUser u = FUser(
        uid: uid,
        isAnonymous: false,
      );
      u.nome = data['nome'];
      u.tipo = data['tipo'];
      u.photoUrl = data['photoUrl'];
      u.nivel = data['nivel'];
      u.ano = data['ano'];
      if(!listparticipantes.contains(u.uid)){
        users.add(u);
        print(data['nome']);
      }
    }
    return users;
  }
  final nomeSortController = TextEditingController();
  final nomeController = TextEditingController();
  bool loading = false;

  Future addParticipantes() async {
    await GruposDatabaseService().addToGroup(widget.grupo.docId, selectedUsers);
    selectedUsers.forEach((user) async {
      MsgsGrupoDatabaseService(grupoId: widget.grupo.docId).sendMensage('1', 'Utilizador ${user.nome!} foi adicionado ao grupo');
    });

    setState(() {
      widget.listUsers.addAll(selectedUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return !loading ? Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: TextFormField(
            textCapitalization: TextCapitalization.words,
            controller: nomeSortController,
            cursorColor: preto,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: preto),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: preto)
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: preto)
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: preto)
              ),
              labelText: 'Pesquisar por Nome',
              suffixIcon: const Icon(
                Icons.search,
              ),
            ),
            onChanged: (val){
              setState(() {

              });
            },
          ),
        ),
        FutureBuilder<List<FUser>>(
          future: _futureUsers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Expanded(child: Center(child: Loading()));
            } else if (snapshot.hasError) {
              return Expanded(child: Center(child: Text(snapshot.error.toString())));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Expanded(child: Center(child: Text('Não tem Explicandos disponiveis atualmente')));
            } else {
              listUsers = snapshot.data!;
              List<FUser> listSorted = [];
              listUsers.forEach((user){
                if(user.nome!.toLowerCase().startsWith(nomeSortController.text.trim().toLowerCase(),0)){
                  listSorted.add(user);
                }
              });
              if (listSorted.isEmpty) {
                return const Expanded(child: Center(child: Text('Não tem Explicandos atualmente')));
              }
              return Expanded(
                child: ListView.builder(
                  physics: null,
                  shrinkWrap: true,
                  itemCount: listSorted.length,
                  itemBuilder: (context, index) {
                    bool checkBox = selectedUsers.contains(listSorted[index]);
                    return CheckboxListTile(
                      checkColor: textoPrincipal,
                      activeColor: principal,
                      value: checkBox,
                      onChanged: (bool? value) {
                        setState(() {
                          value!
                              ? selectedUsers.add(listSorted[index])
                              : selectedUsers.remove(listSorted[index]);
                        });
                      },
                      secondary: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PerfilWrapper(user: listSorted[index], origem: 'Chat',)
                              ),
                            );
                          },
                          child: FotoPerfil(photoUrl: listSorted[index].photoUrl,size: 50,)
                      ),
                      title: Text(listSorted[index].nome!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nivel de educação: ${listSorted[index].nivel!}'),
                          Text('Ano de educação: ${listSorted[index].ano!}'),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8,4,8,8),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            onPressed: () async {

              setState(() {
                loading = true;
              });
              await addParticipantes();
              Navigator.pop(context);
              setState(() {
                loading = false;
              });
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: textoPrincipal),
                  const TextoPrincipal(
                    text: 'Adicionar Utilizadores',
                    fontSize: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    )
        : const Center(child: Loading(),);
  }
}
