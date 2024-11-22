import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/widget/loading.dart';

class FotoPerfil extends StatelessWidget {
  final double size;
  final String? photoUrl;
  final bool loading;
  const FotoPerfil({super.key, required this.photoUrl, required this.size, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return photoUrl != null
        ? CircleAvatar(
            radius: 30,
            foregroundImage: NetworkImage('$photoUrl'),
            child: loading? const Loading() : null,
          )

        : CircleAvatar(
            radius: 30,
            child: Icon(Icons.person, size: size)
      )
    ;
  }
}
