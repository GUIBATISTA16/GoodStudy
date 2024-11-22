import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/globais/functionsglobal.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart';
import '../services/auth.dart';

class Logout extends StatelessWidget {
  const Logout ({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    return ElevatedButton(
      onPressed: () async {
        onUserLogout();
        await auth.signOut();
        userlogged = null;
      },
      style: ElevatedButton.styleFrom( backgroundColor: Colors.red,),
      child: const Icon(Icons.logout,color: Colors.black,),
    );

  }
}
