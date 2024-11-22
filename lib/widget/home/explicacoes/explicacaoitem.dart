import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projeto_goodstudy/objects/explicacao.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/widget/home/explicacoes/editarexplicacao.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import '../../../globais/varGlobal.dart';
import '../../../screens/perfil.dart';
import '../../../screens/perfiluser/perfiluserlogged.dart';
import '../../../services/userdatabase.dart';

class Explicacaoitem extends StatefulWidget {
  final ExplicacaoObject explicacao;
  const Explicacaoitem({super.key, required this.explicacao});

  @override
  State<Explicacaoitem> createState() => _ExplicacaoitemState();
}

class _ExplicacaoitemState extends State<Explicacaoitem> {

  List<FUser> listUsers = [];

  Future<List<FUser>> getUsers(List<dynamic> listUid) async {
    final UserDatabaseService userDb = UserDatabaseService(uid: userlogged!.uid);

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
      if(u.tipo == 'Explicando'){
        u.nivel = data['nivel'];
        u.ano = data['ano'];
      }
      else{
        u.especialidade = data['especialidade'];
        u.avaliacao = data['avaliacao'];
        u.anosexp = data['anosexp'];
        u.descricao = data['descricao'];
        u.precohr = data['precohora'];
        u.precomes = data['precomes'];
        u.precoano = data['precoano'];
      }
      users.add(u);
    }
    listUsers = users;
    return users;
  }

  @override
  void initState() {
    super.initState();
    getUsers(widget.explicacao.listUtilizadores);
  }


  @override
  Widget build(BuildContext context) {
    DateTime inicio = widget.explicacao.data;
    String formattedDateInico = DateFormat('kk:mm').format(inicio);
    DateTime fim;
    if(widget.explicacao.minutos){
      fim = inicio.add(Duration(minutes: widget.explicacao.duracao));
    }
    else{
      fim = inicio.add(Duration(hours: widget.explicacao.duracao));
    }
    String formattedDateFim = DateFormat('kk:mm').format(fim);
    String diasemana = '';
    switch (widget.explicacao.data.weekday){
      case 1 : diasemana = 'Segunda-feira';break;
      case 2 : diasemana = 'Terça-feira';break;
      case 3 : diasemana = 'Quarta-feira';break;
      case 4 : diasemana = 'Quinta-feira';break;
      case 5 : diasemana = 'Sexta-feira';break;
      case 6 : diasemana = 'Sábado';break;
      case 7 : diasemana = 'Domingo';break;
    }

    return InkWell(
      onTap: () async {
        var statusS = await Permission.calendarFullAccess.status;
        if (!statusS.isGranted) {
          await Permission.calendarFullAccess.request();
        }
        var statusC = await Permission.calendarFullAccess.status;
        if (!statusC.isGranted) {
          await Permission.calendarFullAccess.request();
        }
        var event = Event(
          title: widget.explicacao.titulo,
          description: widget.explicacao.titulo,
          startDate: inicio,
          endDate: fim,
        );
        Add2Calendar.addEvent2Cal(event);
      },
      child: Carde(
        child: ListTile(
          title: Text(widget.explicacao.titulo),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data: ${widget.explicacao.data.day}/${widget.explicacao.data.month}/${widget.explicacao.data.year} - $diasemana'),
                      Text('Hora de inicio: $formattedDateInico'),
                      Text('Hora de fim: $formattedDateFim'),
                    ],
                  ),
                  userlogged!.tipo == 'Explicador' ? IconButton(
                    onPressed: (){
                      showDialog(context: context, builder: (context){
                        return EditarExplicacao(explicacao: widget.explicacao,);
                      });
                    },
                    icon: const Icon(Icons.edit_calendar)) : const Text(''),
                ],
              ),
              ExpansionTile(
                title: const Text('Participantes'),
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: FutureBuilder(
                      future: getUsers(widget.explicacao.listUtilizadores),
                      builder: (context,snapshot){
                        if(listUsers.isEmpty){
                          return const Center(child: Loading(),);
                        }
                        else{
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: listUsers.length,
                            itemBuilder: (context,index){
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      listUsers[index].uid == userlogged!.uid
                                          ? MaterialPageRoute(
                                          builder: (context) => const PerfilUserLogged()
                                      )
                                          : MaterialPageRoute(
                                          builder: (context) => PerfilWrapper(user: listUsers[index], origem: 'Chat',)
                                      )
                                  );
                                },
                                child: ListTile(
                                  leading: FotoPerfil(photoUrl: listUsers[index].photoUrl, size: 50),
                                  title: Text(listUsers[index].nome!),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if(listUsers[index].tipo == 'Explicando')
                                        Text('${listUsers[index].nivel!}'),
                                      if(listUsers[index].tipo == 'Explicando')
                                        Text('${listUsers[index].ano!}'),
                                      if(listUsers[index].tipo == 'Explicador')
                                        Text('Especialidade: ${listUsers[index].especialidade!}'),
                                    ],
                                  ),
                                ),
                              );
                            }
                          );
                        }
                      }
                    ),
                  )
                ]
              ),
            ],
          ),
        )
      ),
    );
  }
}
