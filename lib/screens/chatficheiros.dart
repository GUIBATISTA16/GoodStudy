import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/screens/perfilexplicador.dart';
import 'package:projeto_goodstudy/screens/perfilexplicando.dart';
import 'package:projeto_goodstudy/widget/home/chats/ficheiros/ficheirolist.dart';
import 'package:projeto_goodstudy/widget/home/chats/ficheiros/imagemlist.dart';
import 'package:projeto_goodstudy/widget/home/chats/ficheiros/videolist.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import '../globais/colorsglobal.dart';
import '../globais/stylesglobal.dart';
import '../objects/chat.dart';
import '../objects/fuser.dart';
import '../widget/fotoperfil.dart';

class FicheirosChat extends StatefulWidget {
  final FUser user;
  final ChatObject chat;
  const FicheirosChat({super.key, required this.user, required this.chat});

  @override
  State<FicheirosChat> createState() => _FicheirosChatState();
}

class _FicheirosChatState extends State<FicheirosChat> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButao(
          color: textoPrincipal,
        ),
        title: Row(
          children: [
            GestureDetector(
                onTap: () {
                  widget.user.tipo == 'Explicador'
                      ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PerfilExplicador(
                            explicador: widget.user, origem: 'Chat')),
                  )
                      : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PerfilExplicando(explicando: widget.user)),
                  );
                },
                child: FotoPerfil(photoUrl: widget.user.photoUrl,size: 50,)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: TextoPrincipal(text: '${widget.user.nome}',),
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
                child: Text(
                  'Imagens',
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
                        child: ImagensLista(
                          chat: widget.chat,
                          destinatarioPhotoUrl: widget.user.photoUrl,
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
                        chat: widget.chat,
                        destinatarioPhotoUrl: widget.user.photoUrl,
                      ),
                    ),
                  )
                ),
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
                          border: bordaFina,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: FicheirosLista(
                          chat: widget.chat,
                          destinatarioPhotoUrl: widget.user.photoUrl,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: principal,
        selectedItemColor: textoPrincipal,
        unselectedItemColor: Colors.white30,
        items: const [
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
            curve: Curves.easeInOut,);
        },
      ),
    );
  }
}
