import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/widget/home/grupos/adicionarparticipantes.dart';
import 'package:projeto_goodstudy/widget/home/grupos/ficheiros/ficheirolist.dart';
import 'package:projeto_goodstudy/widget/home/grupos/ficheiros/imagemlist.dart';
import 'package:projeto_goodstudy/widget/home/grupos/ficheiros/videolist.dart';
import 'package:projeto_goodstudy/widget/home/grupos/participanteslist.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import '../globais/colorsglobal.dart';
import '../globais/stylesglobal.dart';
import '../objects/fuser.dart';
import '../objects/grupo.dart';
import '../widget/fotoperfil.dart';

class FicheirosGrupo extends StatefulWidget {
  final String origem;
  final GrupoObject grupo;
  final List<FUser> listUsers;
  final FUser explicador;
  const FicheirosGrupo({super.key,required this.origem, required this.grupo, required this.listUsers, required this.explicador});

  @override
  State<FicheirosGrupo> createState() => _FicheirosGrupoState();
}

class _FicheirosGrupoState extends State<FicheirosGrupo> {
  int _selectedIndex = 0;
  late final PageController _pageController ;

  List<FUser> listUsers = [];
  @override
  void initState() {
    super.initState();
    listUsers = widget.listUsers;
    if(widget.origem == 'Ficheiros'){
      _selectedIndex = 1;
    }
    else{
      _selectedIndex = 0;
    }
    _pageController = PageController(initialPage: _selectedIndex);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButao(
          color: textoPrincipal,
        ),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(child: SizedBox(width: 35,height: 35,child: FotoPerfil(photoUrl: widget.explicador.photoUrl,size: 30,loading: false),)),
                  Positioned(left: 10,top: 10,child: SizedBox(child: FotoPerfil(photoUrl: widget.listUsers[0].photoUrl,size: 30,loading: false), width: 35,height: 35,),),
                ],
              ),
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(widget.grupo.nome,
                    maxLines: 2,
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  ),
                )
            ),
          ],
        ),
        backgroundColor: principal,
      ),
      backgroundColor: Colors.grey[300],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: principal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Membros do Grupo',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20,color: textoPrincipal),
                        ),
                      ),
                      if(globals.userlogged!.tipo == 'Explicador')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1,horizontal: 4),
                        child: IconButton(
                          onPressed: () async {
                            await showDialog(context: context, builder: (context){
                              return AlertDialog(
                                insetPadding: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.only(top: 10.0),
                                title: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    BackButao(
                                      color: Colors.black,
                                    ),
                                    Text('Adicionar Utilizadores'),
                                  ],
                                ),
                                content: Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                                    maxWidth: MediaQuery.of(context).size.height * 0.9,
                                  ),
                                  child: AdicionarParticipantes(grupo: widget.grupo, listUsers: widget.listUsers),
                                ),
                              );
                            });
                            setState(() {listUsers = widget.listUsers;});
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(principal),
                          ),
                          icon: Icon(Icons.group_add,color: textoPrincipal,),
                        ),
                      ),
                    ],
                  )),
              Expanded(
                child: ParticipantesLista(grupo: widget.grupo,listUsers: widget.listUsers,explicador: widget.explicador,)
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: principal,
                child: Text(
                  'Imagens',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20,color: textoPrincipal),
                )
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: bordaFina,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ImagensLista(
                          grupo: widget.grupo,
                        )
                      ),
                    )),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: principal,
                  child: Text(
                    'Vídeos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20,color: textoPrincipal),
                  )),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: bordaFina,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: VideosLista(
                          grupo: widget.grupo,
                        ),
                      ),
                    )),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: principal,
                  child: Text(
                    'Ficheiros',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20,color: textoPrincipal),
                  )),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 0.5, color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: FicheirosLista(
                          grupo: widget.grupo,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: principal,
        selectedItemColor: textoPrincipal,
        unselectedItemColor: Colors.white30,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.group), label: 'Membros'),
          BottomNavigationBarItem(
              icon: Icon(Icons.image), label: 'Imagens'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_library), label: 'Vídeos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_present), label: 'Ficheiros'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
