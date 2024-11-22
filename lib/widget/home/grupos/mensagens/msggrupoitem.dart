import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_goodstudy/globais/stylesglobal.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/objects/mensagem.dart';
import 'package:projeto_goodstudy/services/userdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../globais/colorsglobal.dart';
import '../../../../globais/functionsglobal.dart';
import '../../../../globais/widgetglobal.dart';

class MensagemGrupo extends StatefulWidget {
  final MensagemObject msg;
  final FUser? user;
  final String cId;
  MensagemGrupo({
    super.key,
    required this.msg,
    this.user,
    required this.cId,
  });

  @override
  _MensagemGrupoState createState() => _MensagemGrupoState();
}

class _MensagemGrupoState extends State<MensagemGrupo> {
  FUser? secondU;
  Future<String?>? _thumbnailFuture;


  bool firstTime = true;

  Future getUser() async {
    DocumentSnapshot doc = await UserDatabaseService(uid: widget.msg.remetente).getDataWithUid(widget.msg.remetente);
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    secondU = FUser(uid: widget.msg.remetente, isAnonymous: false);
    secondU!.nome = data['nome'];
    secondU!.tipo = data['tipo'];
    secondU!.photoUrl = data['photoUrl'];
    secondU!.nivel = data['nivel'];
    secondU!.ano = data['ano'];
  }

  static final Map<String, String?> _thumbnailCache = {};
  @override
  void initState() {
    super.initState();
    if(widget.user == null && widget.msg.remetente != '1'){
      getUser();
    }
    if (widget.msg.tipo == 'video') {
      _thumbnailFuture = generateThumbnail(widget.msg.fileUrl!,widget.msg.filename!);
    }
  }

  @override
  void didUpdateWidget(MensagemGrupo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.msg.tipo == 'video') {
      _thumbnailFuture = generateThumbnail(widget.msg.fileUrl!,widget.msg.filename!);
    }
  }

  Future<String?> generateThumbnail(String videoUrl, String videoName) async {
    if (_thumbnailCache.containsKey(videoName)) {
      return _thumbnailCache[videoName];
    } else {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 100,
      );
      _thumbnailCache[videoName] = thumbnail;
      return thumbnail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: widget.msg.remetente != '1' ? Column(
        crossAxisAlignment: widget.msg.remetente != globals.userlogged?.uid
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if(widget.msg.remetente != globals.userlogged?.uid)
            FutureBuilder(
              future: getUser(),
              builder: (context,snapshot){
                if(widget.user == null && secondU == null){
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      '',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }
                else if(widget.user != null){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      widget.user!.nome!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      secondU!.nome!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
              }
            ),
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Row(
              mainAxisAlignment: widget.msg.remetente != globals.userlogged?.uid
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.msg.remetente != globals.userlogged?.uid)
                FutureBuilder(
                  future: getUser(),
                  builder: (context,snapshot){
                    if(widget.user == null && secondU == null){
                      return const Padding(
                        padding: EdgeInsets.all(3),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: FotoPerfil(photoUrl: null,size: 20,),
                        ),
                      );
                    }
                    else if(widget.user != null){
                      return Padding(
                        padding: const EdgeInsets.all(3),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: FotoPerfil(photoUrl: widget.user!.photoUrl,size: 30,),
                        ),
                      );
                    }
                    else{
                      return Padding(
                        padding: const EdgeInsets.all(3),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: FotoPerfil(photoUrl: secondU!.photoUrl,size: 30,),
                        ),
                      );
                    }
                  }
                ),
                if (widget.msg.tipo == 'texto')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: IntrinsicWidth(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.msg.remetente == globals.userlogged!.uid ? msguser : msgoutrouser,
                            border: bordaFina,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextoPrincipal(
                              text:  widget.msg.texto!,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.msg.tipo == 'imagem')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        showModalImagem(context, widget.msg);
                      },
                      child: IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65,
                            //maxHeight: 400
                          ),
                          child: Image.network(
                            widget.msg.fileUrl!,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Container(
                                  width: double.parse(widget.msg.width.toString()),
                                  height: widget.msg.width! < MediaQuery.of(context).size.width * 0.65
                                      ? widget.msg.width! / widget.msg.aspectRatio!
                                      : MediaQuery.of(context).size.width * 0.65/ widget.msg.aspectRatio!,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Loading(),
                                  ),
                                );
                              }
                            },
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Container(
                                width: double.parse(widget.msg.width.toString()),
                                height: widget.msg.width! < MediaQuery.of(context).size.width * 0.65
                                    ? widget.msg.width! / widget.msg.aspectRatio!
                                    : MediaQuery.of(context).size.width * 0.65/ widget.msg.aspectRatio!,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text('Erro ao carregar imagem', style: TextStyle(color: Colors.red)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.msg.tipo == 'video')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        showModalVideo(context, widget.msg);
                      },
                      child: IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65,
                            //maxHeight: 400
                          ),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: [
                              FutureBuilder<String?>(
                                future: _thumbnailFuture,
                                builder: (context, snapshot) {
                                   if (snapshot.hasError || !snapshot.hasData) {
                                    return Container(
                                      width: double.parse(widget.msg.width.toString()),
                                      height: widget.msg.width! < MediaQuery.of(context).size.width * 0.65
                                          ? widget.msg.width! / widget.msg.aspectRatio!
                                          : MediaQuery.of(context).size.width * 0.65/ widget.msg.aspectRatio!,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Loading(),
                                      ),
                                    );
                                  } else {
                                     try{
                                       return Image.file(
                                         File(_thumbnailCache[widget.msg.filename]!),
                                         fit: BoxFit.cover,
                                       );
                                     }
                                     catch(e){
                                       return Container(
                                         width: double.parse(widget.msg.width.toString()),
                                         height: widget.msg.width! < MediaQuery.of(context).size.width * 0.65
                                             ? widget.msg.width! / widget.msg.aspectRatio!
                                             : MediaQuery.of(context).size.width * 0.65/ widget.msg.aspectRatio!,
                                         color: Colors.grey[300],
                                         child: const Center(
                                           child: Loading(),
                                         ),
                                       );
                                     }
                                  }
                                },
                              ),
                              const Icon(size: 30, Icons.play_arrow, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.msg.tipo == 'ficheiro')
                  GestureDetector(
                    onTap: () async {
                      await checkAndRequestPermissions();
                      await downloadFile(widget.msg.fileUrl!, widget.msg.filename!,context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65,
                          ),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: widget.msg.remetente == globals.userlogged!.uid ? msguser : msgoutrouser,
                              border: bordaFina,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.file_present,
                                  size: 50,
                                  color: widget.msg.filename!.split('.').last == 'docx' || widget.msg.filename!.split('.').last == 'doc'
                                      ? Colors.blue[900]
                                      : widget.msg.filename!.split('.').last == 'pdf'
                                      ? Colors.red[700]
                                      : widget.msg.filename!.split('.').last == 'xls' || widget.msg.filename!.split('.').last == 'xlsx'
                                      ? Colors.green[600]
                                      : widget.msg.filename!.split('.').last == 'ppt' || widget.msg.filename!.split('.').last == 'pptx'
                                      ? Colors.orange[600]
                                      : Colors.black,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      widget.msg.filename!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              widget.msg.data,
              style: const TextStyle(fontSize: 12),
            ),
          )
        ],
      )
      : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.msg.texto!,style: const TextStyle(fontSize: 11),)
          ],
      ),
    );
  }
}
