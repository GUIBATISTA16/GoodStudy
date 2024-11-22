import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../globais/functionsglobal.dart';
import '../../../../objects/mensagem.dart';
import '../../../loading.dart';
import '../../../videoplayer.dart';

class ItemFicheiroChat extends StatefulWidget {
  final MensagemObject msg;
  final String? destinatarioPhotoUrl;
  final String cId;

  const ItemFicheiroChat({
    super.key,
    required this.msg,
    required this.destinatarioPhotoUrl,
    required this.cId,
  });

  @override
  State<ItemFicheiroChat> createState() => _ItemFicheiroChatState();
}

class _ItemFicheiroChatState extends State<ItemFicheiroChat> {
  Future<String?>? _thumbnailFuture;
  static final Map<String, String?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.msg.tipo == 'video') {
      _thumbnailFuture = generateThumbnail(widget.msg.fileUrl!);
    }
  }

  Future<void> checkAndRequestPermissions() async {
    var statusS = await Permission.storage.status;
    if (!statusS.isGranted) {
      await Permission.storage.request();
    }
    var statusN = await Permission.notification.status;
    if (!statusN.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> downloadImage(String url, String filename) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.lightBlue[200],
        content: const Text(
          'Download Iniciado',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/$filename';
    await Dio().download(url, path);
    await GallerySaver.saveImage(path, albumName: 'GoodStudy', toDcim: true);
    showNotification(path);
  }

  Future<void> downloadVideo(String url, String filename) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.lightBlue[200],
        content: const Text(
          'Download Iniciado',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/$filename';
    await Dio().download(url, path);
    await GallerySaver.saveVideo(path, albumName: 'GoodStudy', toDcim: true);
    showNotification(path);
  }

  void showModalImagem() {
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: Text(widget.msg.filename!)),
              GestureDetector(
                onTap: () async {
                  await downloadImage(widget.msg.fileUrl!, widget.msg.filename!);
                },
                child: const Icon(
                  size: 30,
                  Icons.download,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Container(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: InteractiveViewer(
                  child: Image.network(
                    widget.msg.fileUrl!,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Loading(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showModalVideo() {
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: Text(widget.msg.filename!)),
              GestureDetector(
                onTap: () async {
                  await downloadVideo(widget.msg.fileUrl!, widget.msg.filename!);
                },
                child: const Icon(
                  size: 30,
                  Icons.download,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Videoplayer(url: widget.msg.fileUrl!,)
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> generateThumbnail(String videoUrl) async {
    if (_thumbnailCache.containsKey(videoUrl)) {
      return _thumbnailCache[videoUrl];
    } else {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxWidth: widget.msg.width! ,
        quality: 100,
      );
      _thumbnailCache[videoUrl] = thumbnail;
      return thumbnail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.msg.tipo == 'imagem')
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  showModalImagem();
                },
                child: Image.network(
                  widget.msg.fileUrl!,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.97,
                        height: MediaQuery.of(context).size.width * 0.97 / widget.msg.aspectRatio!,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Loading(),
                        ),
                      );
                    }
                  },
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.97,
                      height: MediaQuery.of(context).size.width * 0.97 / widget.msg.aspectRatio!,
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
        if (widget.msg.tipo == 'video')
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  showModalVideo();
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    FutureBuilder<String?>(
                      future: _thumbnailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.97,
                            height: MediaQuery.of(context).size.width * 0.97 / widget.msg.aspectRatio!,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Loading(),
                            ),
                          );
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.97,
                            height: MediaQuery.of(context).size.width * 0.97 / widget.msg.aspectRatio!,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Error generating thumbnail'),
                            ),
                          );
                        } else {
                          return Image.file(
                            File(snapshot.data!),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width ,
                            height: MediaQuery.of(context).size.height ,
                          );
                        }
                      },
                    ),
                    const Icon(size: 30, Icons.play_arrow, color: Colors.white),
                  ],
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
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 0.5,
                    color: Colors.black,
                  ),
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
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
