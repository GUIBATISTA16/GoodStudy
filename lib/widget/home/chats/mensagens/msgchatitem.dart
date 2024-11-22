import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_goodstudy/globais/colorsglobal.dart';
import 'package:projeto_goodstudy/globais/stylesglobal.dart';
import 'package:projeto_goodstudy/objects/mensagem.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../globais/functionsglobal.dart';
import '../../../../globais/widgetglobal.dart';

class MensagemChat extends StatefulWidget {
  final MensagemObject msg;
  final String? destinatarioPhotoUrl;
  final String cId;
  MensagemChat({
    super.key,
    required this.msg,
    required this.destinatarioPhotoUrl,
    required this.cId,
  });

  @override
  _MensagemChatState createState() => _MensagemChatState();
}

class _MensagemChatState extends State<MensagemChat> {
  Future<String?>? _thumbnailFuture;
  static final Map<String, String?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.msg.tipo == 'video') {
      _thumbnailFuture = generateThumbnail(widget.msg.fileUrl!,widget.msg.filename!);
    }
  }

  @override
  void didUpdateWidget(MensagemChat oldWidget) {
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
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Row(
              mainAxisAlignment: widget.msg.remetente != globals.userlogged?.uid
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.msg.remetente != globals.userlogged?.uid)
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FotoPerfil(photoUrl: widget.destinatarioPhotoUrl,size: 33,),
                    ),
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