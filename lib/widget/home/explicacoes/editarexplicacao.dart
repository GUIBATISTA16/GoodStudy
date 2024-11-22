import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:projeto_goodstudy/objects/explicacao.dart';
import 'package:string_validator/string_validator.dart';

import '../../../globais/colorsglobal.dart';
import '../../../globais/stylesglobal.dart';
import '../../../globais/varGlobal.dart';
import '../../../globais/widgetglobal.dart';
import '../../../objects/fuser.dart';
import '../../../screens/perfil.dart';
import '../../../services/chatdatabase.dart';
import '../../../services/explicacaodatabase.dart';
import '../../../services/userdatabase.dart';
import '../../fotoperfil.dart';
import '../../loading.dart';

class EditarExplicacao extends StatefulWidget {
  final ExplicacaoObject explicacao;
  const EditarExplicacao({super.key, required this.explicacao});

  @override
  State<EditarExplicacao> createState() => _EditarExplicacaoState();
}

class _EditarExplicacaoState extends State<EditarExplicacao> {

  List<FUser> listUsers = [];
  List<String> selectedUsers = [];
  late Future<List<FUser>> _futureUsers;

  @override
  void initState() {
    super.initState();
    for(String uid in widget.explicacao.listUtilizadores){
      if(uid != userlogged!.uid){
        selectedUsers.add(uid);
      }
    }
    _futureUsers = getUsers();
    dateTime = widget.explicacao.data;
    duracaoController.text = widget.explicacao.duracao.toString();
    minutos = widget.explicacao.minutos;
  }

  Future<List<FUser>> getUsers() async {
    final ChatDatabaseService chatDb = ChatDatabaseService();
    final UserDatabaseService userDb = UserDatabaseService(uid: userlogged!.uid);

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

  bool erro = false;
  String erroT = '';
  bool loading = false;
  final formkey = GlobalKey<FormState>();
  late DateTime dateTime;
  final duracaoController = TextEditingController();
  bool minutos = true;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      contentPadding: const EdgeInsets.only(top: 10.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const BackButao(
            color: Colors.black,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Editar Explicação'),
                Text(widget.explicacao.titulo,maxLines: 2,style: const TextStyle(fontSize: 16),),
              ],
            ),
          ),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.height * 0.9,
        ),
        child: !loading ? Form(
          key: formkey,
          child: Column(
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
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,4,8,0),
                child: ElevatedButton(
                  onPressed: (){
                    DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (date) {
                          setState(() {
                            dateTime = date;
                          });
                        },
                        currentTime: dateTime, locale: LocaleType.pt
                    );
                  },
                  style: buttonPrincipalSquare,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextoPrincipal(text: 'Escolher data e hora',fontSize: 16,),
                    ],
                  ),
                ),
              ),
              Text('Data selecionada: ${DateFormat('dd/MM/yyyy kk:mm').format(dateTime)}'),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0,0,8,2),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        validator: (val) {
                          if(isFloat(val!) && val.isNotEmpty && double.parse(val) > 0){
                            return null;
                          }
                          return 'Insira a duração da explicação válida';
                        },
                        controller: duracaoController,
                        cursorColor: preto,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: 'Insira a duração ',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              minutos = !minutos;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            width: 100,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                minutos ? 'Minutos' : 'Horas', textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: !erro ? const EdgeInsets.fromLTRB(8,4,8,8) : const EdgeInsets.fromLTRB(8,4,8,0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: buttonPrincipalSquare,
                      onPressed: () async {
                        if(selectedUsers.isNotEmpty && formkey.currentState!.validate()){
                          setState(() {
                            erro = false;
                            loading = true;
                          });
                          await ExplicacaoDatabaseService().editExplicacao(selectedUsers, dateTime,int.parse(duracaoController.text),minutos,widget.explicacao.docId);
                          selectedUsers.insert(0, userlogged!.uid);
                          widget.explicacao.data = dateTime;
                          widget.explicacao.duracao = int.parse(duracaoController.text.trim());
                          widget.explicacao.minutos = minutos;
                          widget.explicacao.listUtilizadores = selectedUsers;
                          Navigator.pop(context);
                          setState(() {
                            erro = false;
                            loading = false;
                          });
                        }
                        else if(selectedUsers.isEmpty && !formkey.currentState!.validate()){
                          setState(() {
                            erroT = 'Selecione pelo menos 1 explicando para marcar uma explicação e meta uma duração válida';
                            erro = true;
                          });
                        }
                        else if(selectedUsers.isEmpty ){
                          setState(() {
                            erroT = 'Selecione pelo menos 1 explicando para marcar uma explicação';
                            erro = true;
                          });
                        }
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: textoPrincipal),
                            const TextoPrincipal(
                              text: 'Guardar',
                              fontSize: 16,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: buttonRedSquare,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined, color: textoPrincipal),
                            const TextoPrincipal(
                              text: 'Cancelar',
                              fontSize: 16,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: erro,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8,0,8,8),
                  child: Text(erroT,
                    style: const TextStyle(
                        color: Colors.red
                    ),
                  ),
                ),
              )
            ],
          ),
        ) : const Center(child: Loading(),),
      ),
    );
  }
}
