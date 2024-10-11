import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/screens/perfiluser/useraluno.dart';
import 'package:projeto_goodstudy/screens/perfiluser/userexplicador.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

class PerfilUserLogged extends StatelessWidget {
  const PerfilUserLogged({super.key});

  @override
  Widget build(BuildContext context) {
    return globals.userlogged!.tipo == 'Explicador'
      ? const EditarExplicador()
      : const EditarAluno();
  }
}
