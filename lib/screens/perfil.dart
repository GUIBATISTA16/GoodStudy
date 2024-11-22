import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/screens/perfilexplicador.dart';
import 'package:projeto_goodstudy/screens/perfilexplicando.dart';

class PerfilWrapper extends StatelessWidget {
  final FUser user;
  final String origem;
  const PerfilWrapper({super.key, required this.user, required this.origem});

  @override
  Widget build(BuildContext context) {
    return user.tipo == 'Explicador'
        ? PerfilExplicador(explicador: user, origem: 'Chat',)
        : PerfilExplicando(explicando: user)
      ;
  }
}
