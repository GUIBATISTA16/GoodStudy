import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/globais/colorsglobal.dart';
import 'package:projeto_goodstudy/services/chatdatabase.dart';
import 'package:projeto_goodstudy/services/gruposdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import '../../../../objects/fuser.dart';
import '../../../../screens/perfil.dart';
import '../../../../services/userdatabase.dart';
import '../../../fotoperfil.dart';
import '../../../loading.dart';

class CriarGrupo extends StatefulWidget {
  const CriarGrupo({super.key});

  @override
  State<CriarGrupo> createState() => _CriarGrupoState();
}

class _CriarGrupoState extends State<CriarGrupo> {
  List<FUser> listUsers = [];
  List<String> selectedUsers = [];
  late Future<List<FUser>> _futureUsers;


  @override
  void initState() {
    super.initState();
    _futureUsers = getUsers();
  }

  Future<List<FUser>> getUsers() async {
    final ChatDatabaseService chatDb = ChatDatabaseService();
    final UserDatabaseService userDb = UserDatabaseService(uid: globals.userlogged!.uid);

    final listUid = await chatDb.getListExplicandos();

    List<FUser> users = [];
    for (String uid in listUid) {
      DocumentSnapshot snapshot = await userDb.getDataWithUid(uid);
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
      users.add(u);
    }
    return users;
  }

  final nomeSortController = TextEditingController();

  final nomeController = TextEditingController();
  bool erro = false;
  bool loading = false;

  Future createGrupo() async {
    GruposDatabaseService db = GruposDatabaseService();
    await db.createGrupo(globals.userlogged!.uid, selectedUsers, nomeController.text.trimRight());
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
              return const Expanded(child: Center(child: Text('Não tem Explicandos atualmente')));
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
              else{
                return Expanded(
                  child: ListView.builder(
                    physics: null,
                    shrinkWrap: true,
                    itemCount: listSorted.length,
                    itemBuilder: (context, index) {
                      bool checkBox = selectedUsers.contains(listSorted[index].uid);
                      return CheckboxListTile(
                        checkColor: textoPrincipal,
                        activeColor: principal,
                        value: checkBox,
                        onChanged: (bool? value) {
                          setState(() {
                            value!
                                ? selectedUsers.add(listSorted[index].uid)
                                : selectedUsers.remove(listSorted[index].uid);
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
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: TextFormField(
            textCapitalization: TextCapitalization.words,
            controller: nomeController,
            cursorColor: preto,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: preto),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: preto),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: preto),
              ),
              labelStyle: TextStyle(
                color: preto
              ),
              labelText: 'Nome do Grupo',
              suffixIcon: const Icon(
                Icons.group,
              ),
            ),
          ),
        ),
        Padding(
          padding: !erro ? const EdgeInsets.fromLTRB(8,4,8,8) : const EdgeInsets.fromLTRB(8,4,8,0),
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
              if(selectedUsers.length > 1){
                setState(() {
                  erro = false;
                  loading = true;
                });
                await createGrupo();
                Navigator.pop(context);
                setState(() {
                  erro = false;
                  loading = false;
                });
              }else{
                setState(() {
                  erro = true;
                });
              }
            },
            child: Container(
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  Text(
                    'Criar Grupo',
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
        Visibility(
          visible: erro,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(8,0,8,8),
            child: Text('Selecione pelo menos 2 explicandos para criar um grupo',
              style: TextStyle(
                color: Colors.red
              ),
            ),
          ),
        )
      ],
    )
    : const Center(child: Loading(),);
  }
}
