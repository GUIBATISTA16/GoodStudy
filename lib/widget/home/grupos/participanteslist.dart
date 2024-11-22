import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/screens/perfil.dart';
import 'package:projeto_goodstudy/services/gruposdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/services/msgsgrupodatabase.dart';
import '../../../globais/colorsglobal.dart';
import '../../../globais/functionsglobal.dart';
import '../../../globais/stylesglobal.dart';
import '../../../objects/fuser.dart';
import '../../../objects/grupo.dart';
import '../../../screens/perfiluser/perfiluserlogged.dart';
import '../../fotoperfil.dart';
import '../../../globais/widgetglobal.dart';

class ParticipantesLista extends StatefulWidget {
  final GrupoObject grupo;
  final List<FUser> listUsers;
  final FUser explicador;
  const ParticipantesLista({super.key, required this.grupo, required this.listUsers, required this.explicador});

  @override
  State<ParticipantesLista> createState() => _ParticipantesListaState();
}

class _ParticipantesListaState extends State<ParticipantesLista> {
  Future<void> removeFromGroup(FUser user) async {
    if(widget.listUsers.length > 1){
      await GruposDatabaseService().removeFromGroup(widget.grupo.docId, user.uid);
      MsgsGrupoDatabaseService(grupoId: widget.grupo.docId).sendMensage('1', 'Utilizador ${user.nome!} foi removido do grupo');
      setState(() {
        widget.listUsers.remove(user);
      });
    }
    else{
      showCustomSnackBar(context,'O grupo tem de ter pelo menos 1 utilizador');
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
              decoration: BoxDecoration(
                color: fundoMenus,
                border: bordaFina,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListView.builder(
                  itemCount: widget.listUsers.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          widget.listUsers[index].uid == globals.userlogged!.uid
                            ? MaterialPageRoute(
                              builder: (context) => const PerfilUserLogged()
                            )
                            : MaterialPageRoute(
                              builder: (context) => PerfilWrapper(user: widget.listUsers[index], origem: 'Chat',)
                            )

                        );
                      },
                      child: Carde(
                        child: ListTile(
                          leading: FotoPerfil(photoUrl: widget.listUsers[index].photoUrl,size: 50,),
                          title: Text(widget.listUsers[index].nome!),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(widget.listUsers[index].tipo == 'Explicando')
                                Text(widget.listUsers[index].nivel!),
                              if(widget.listUsers[index].tipo == 'Explicando')
                                Text(widget.listUsers[index].ano!),
                              if(widget.listUsers[index].tipo == 'Explicador')
                                Text('Especialidade: ${widget.listUsers[index].especialidade!}'),
                            ],
                          ),
                          trailing: globals.userlogged!.tipo == 'Explicador'
                              ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            color: fundoMenus,
                            onSelected: (value) {
                              if (value == 'remove') {
                                removeFromGroup(widget.listUsers[index]);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem<String>(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      const Text('Remover do Grupo'),
                                      Icon(Icons.delete,color: Colors.redAccent[700],)
                                    ],
                                  ),
                                ),
                              ];
                            },
                          )
                          : null,
                        ),
                      ),
                    );
                  }
              )
          ),
        )
    );
  }
}
