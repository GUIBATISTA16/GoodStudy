import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/screens/perfiluser/perfiluserlogged.dart';
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/widget/home/chatgruposmenu.dart';
import 'package:projeto_goodstudy/widget/home/explicacoes/listexplicacoes.dart';
import 'package:projeto_goodstudy/widget/home/pedidos/pedidoslista.dart';
import 'package:projeto_goodstudy/widget/logoutbutton.dart';
import 'package:projeto_goodstudy/widget/home/pesquisa/pesquisa.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import '../globais/colorsglobal.dart';
import '../globais/functionsglobal.dart';
import '../globais/varGlobal.dart' as globals;


class Home extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const Home({super.key, required this.navigatorKey});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>{
  late final PageController _pageController;

  @override
  void initState()  {
    super.initState();
    _pageController = PageController(initialPage: globals.opcao);
    if(!globals.userlogged!.isAnonymous){
      onUserLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: preto,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: preto,
          //selectionColor: preto,
          selectionHandleColor: principal,
        ),
      ),
      title: 'Home',
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: !globals.userlogged!.isAnonymous
              ? TextoPrincipal(text:
                  'Seja Bem-Vindo \n${globals.userlogged!.nome}',
              )
              : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoPrincipal(text:
                    'Seja Bem-Vindo',
                  ),
                  TextoPrincipal(text: 'para acessar todas as funcionalidades faça login',
                    fontSize: 12,
                    maxLines: 2,
                  )
                ],
              ),
              backgroundColor: Colors.blue[900],
              actions: [
                GestureDetector(
                  onTap: () {
                    if(!globals.userlogged!.isAnonymous) {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const PerfilUserLogged()),
                      );
                    }
                    else{
                      showCustomSnackBar(context,'Crie uma conta e faça login');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1,vertical: 0),
                    child: FotoPerfil(photoUrl: globals.userlogged!.photoUrl,size: 50,),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4,vertical: 0),
                  child: const Logout(),
                )
              ],
            ),
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  globals.opcao = index;
                });
              },
              children: [
                if(!globals.userlogged!.isAnonymous)
                const ChatsGruposMenu(),
                if(!globals.userlogged!.isAnonymous)
                  const ExplicacoesLista(),
                if(globals.userlogged!.tipo=='Explicando')
                  const Column(
                    children: [
                      Pesquisa(),
                    ],
                  ),
                if(!globals.userlogged!.isAnonymous && globals.userlogged!.tipo=='Explicador')
                  const Column(
                    children: [
                      PedidosLista(),
                    ],
                  ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: principal,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white30,
              items: [
                if (globals.userlogged!.isAnonymous)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Faça login',
                  ),
                if (!globals.userlogged!.isAnonymous)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Os meus chats',
                  ),
                if (!globals.userlogged!.isAnonymous)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month),
                    label: 'Explicações ',
                  ),
                if (globals.userlogged!.tipo != 'Explicador')
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Pesquisar',
                  ),
                if (globals.userlogged!.tipo == 'Explicador')
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.assignment),
                    label: 'Ver Pedidos',
                  ),
                if (globals.userlogged!.isAnonymous)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month),
                    label: 'Faça login',
                  ),
              ],
              currentIndex: globals.userlogged!.isAnonymous
                  ? 1
                  : globals.opcao,
              onTap: (index) {
                setState(() {
                  globals.opcao = index;
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
      ),
    );
  }

}