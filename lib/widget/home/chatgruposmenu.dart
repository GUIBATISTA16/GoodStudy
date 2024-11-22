import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/globais/colorsglobal.dart';
import '../../globais/varGlobal.dart' as globals;
import '../../globais/stylesglobal.dart';
import '../../globais/widgetglobal.dart';
import 'chats/menu/chatlistaalu.dart';
import 'chats/menu/chatlistaexp.dart';
import 'grupos/menu/criargrupo.dart';
import 'grupos/menu/grupolistalu.dart';
import 'grupos/menu/grupolistexp.dart';

class ChatsGruposMenu extends StatefulWidget {
  const ChatsGruposMenu({super.key});

  @override
  State<ChatsGruposMenu> createState() => _ChatsGruposMenuState();
}

class _ChatsGruposMenuState extends State<ChatsGruposMenu> {
  PageController pageController = PageController(initialPage: globals.viewGrupos);

  void onPageChanged(int index) {
    setState(() {
      globals.viewGrupos = index;
    });
  }

  void onItemTapped(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onItemTapped(0),
                child: Container(
                  child: Text(
                    "Chats",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: globals.viewGrupos == 0 ? principal : preto,
                    ),
                  ),
                ),
              ),
            ),
            //SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: () => onItemTapped(1),
                child: Container(
                  child: Text(
                    "Grupos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: globals.viewGrupos == 1 ? principal : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (globals.viewGrupos == 1 && globals.userlogged!.tipo == 'Explicador')
          Container(
            height: 60,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.black),
              ),
            ),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  child: ElevatedButton(
                    style: buttonPrincipalSquare,
                    onPressed: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (context) {
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
                                  BackButao(
                                    color: preto,
                                  ),
                                  const Text('Criar grupo'),
                                ],
                              ),
                              content: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.height * 0.8,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                                  maxWidth: MediaQuery.of(context).size.height * 0.9,
                                ),
                                child: const CriarGrupo(),
                              ),
                            );
                          },
                        );
                      });
                    },
                    child: Container(
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          TextoPrincipal(
                            text: 'Criar Grupo',
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: [
              globals.userlogged!.tipo == 'Explicador' ? const ChatslistaExp() : const ChatslistaAlu(),
              globals.userlogged!.tipo == 'Explicador' ? const GruposListaExp() : const GruposListaAlu(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}