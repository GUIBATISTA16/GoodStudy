import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/screens/grupoficheiros.dart';
import 'package:projeto_goodstudy/screens/videocall.dart';
import 'package:projeto_goodstudy/services/msgsgrupodatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/widget/home/grupos/mensagens/msglist.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../globais/colorsglobal.dart';
import '../globais/functionsglobal.dart';
import '../globais/stylesglobal.dart';
import '../objects/grupo.dart';
import 'call.dart';

class Grupo extends StatefulWidget {
  final GrupoObject grupo;
  final List<FUser> listUsers;
  final FUser explicador;
  const Grupo({super.key, required this.explicador,required this.grupo,required this.listUsers,});

  @override
  State<Grupo> createState() => _GrupoState();
}

class _GrupoState extends State<Grupo> {

  final msgController = TextEditingController();
  String txtTemp = '';

  Future sendMessage() async{
    MsgsGrupoDatabaseService db = MsgsGrupoDatabaseService(grupoId: widget.grupo.docId);
    await db.sendMensage(globals.userlogged!.uid, txtTemp);
  }

  Future sendImage(File file) async{
    MsgsGrupoDatabaseService db = MsgsGrupoDatabaseService(grupoId: widget.grupo.docId);
    dynamic result = await db.sendImage(globals.userlogged!.uid, file);
    if (result == false){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: secondary,
          content: const Text(
            'Erro ao enviar a foto',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  Future sendFile(File file) async{
    MsgsGrupoDatabaseService db = MsgsGrupoDatabaseService(grupoId: widget.grupo.docId);
    dynamic result = await db.sendFile(globals.userlogged!.uid, file);
    if (result == false){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: secondary,
          content: const Text(
            'Erro ao enviar o ficheiro',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  Future sendVideo(File file) async{
    MsgsGrupoDatabaseService db = MsgsGrupoDatabaseService(grupoId: widget.grupo.docId);
    dynamic result = await db.sendVideo(globals.userlogged!.uid, file);
    if (result == false){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: secondary,
          content: const Text(
            'Erro ao enviar o ficheiro',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  List<File?> selectedFiles = [];
  List<File?> selectedTempFiles = [];

  Future<void> pickImage() async {
    /*FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
    );
    if (result != null) {
      setState(() {
        selectedImage = File(result.files.single.path!);
      });
    }*/

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true
    );
    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        selectedFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> takeVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        selectedFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  bool loading = false;
  final FocusNode focusNode = FocusNode();

  String? thumbnailpath;
  Future generateThumbnail(File file) async {
    thumbnailpath = null;
    thumbnailpath = await VideoThumbnail.thumbnailFile(
      video: file.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 130,
      quality: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButao(
            color: textoPrincipal,
          ),
          title: GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => FicheirosGrupo(origem: 'Membros',grupo: widget.grupo,listUsers: widget.listUsers,explicador: widget.explicador,)
                  )
              );
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(child: SizedBox(width: 35,height: 35,child: FotoPerfil(photoUrl: widget.explicador.photoUrl,size: 30,loading: false),)),
                    Positioned(left: 10,top: 10,child: SizedBox(child: FotoPerfil(photoUrl: widget.listUsers[0].photoUrl,size: 30,loading: false), width: 35,height: 35,),),
                  ],
                            ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextoPrincipal(text: widget.grupo.nome,
                      maxLines: 2,
                    ),
                  )
                ),
              ],
            ),
          ),
          backgroundColor: principal,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => FicheirosGrupo(origem: 'Ficheiros',grupo: widget.grupo,listUsers: widget.listUsers,explicador: widget.explicador,)
                  )
                );
              },
              icon: const Icon(Icons.folder_copy, color: Colors.white,)
            ),
            IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                String channel = '';
                channel = '${removeDiacritics(widget.grupo.docId)}call';
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GroupCallPage(channel: channel,)),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.greenAccent[400])
              ),
              icon: const Icon(Icons.phone, color: Colors.white,)
            ),
            IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                String channel = '';
                channel = '${removeDiacritics(widget.grupo.docId)}video';
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VideoGroupCallPage(channel: channel,)),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.greenAccent[400])
              ),
              icon: const Icon(Icons.videocam, color: Colors.white,)
            ),
          ],
        ),
        backgroundColor: Colors.grey[300],
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ContainerBordasFinas(
                  child: MsgsLista(grupo: widget.grupo, listUsers: widget.listUsers,),
                )
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: bordaFina,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: selectedFiles.isNotEmpty ? 150 : 1,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedFiles.length,
                      itemBuilder: (context,index){
                        if(selectedFiles.isNotEmpty){
                          if(typeOfFile(selectedFiles[index]!) == 2) {
                            return Stack(
                              clipBehavior: Clip.none,
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8,8,0,3),
                                  child: SizedBox(
                                    height: 130,
                                    width: 130,
                                    child: Image.file(selectedFiles[index]!,fit: BoxFit.cover,),
                                  ),
                                ),
                                Positioned(
                                  left: 105,
                                  bottom: 97,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        selectedFiles.remove(selectedFiles[index]);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black.withOpacity(0.1),
                                      padding: const EdgeInsets.all(4.0),
                                      minimumSize: const Size(20, 20),
                                    ),
                                    child: const Icon(size: 23,Icons.close,color: Colors.white,),
                                  ),
                                ),
                              ],
                            );
                          }
                          if(typeOfFile(selectedFiles[index]!) == 3) {
                            return Stack(
                              clipBehavior: Clip.none,
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8,8,0,3),
                                  child: SizedBox(
                                      height: 130,
                                      width: 130,
                                      child: FutureBuilder(
                                        future: generateThumbnail(selectedFiles[index]!),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError){
                                            return Center(
                                              child: Text(
                                                  snapshot.error.toString()
                                              ),
                                            );
                                          }
                                          else if(thumbnailpath != null) {
                                            return Image.file(File(thumbnailpath!),fit: BoxFit.cover,);
                                          }
                                          else{
                                            return const Center(child: Loading(),);
                                          }
                                        },
                                      )
                                  ),
                                ),
                                Positioned(
                                  left: 105,
                                  bottom: 97,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        selectedFiles.remove(selectedFiles[index]);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black.withOpacity(0.1),
                                      padding: const EdgeInsets.all(4.0),
                                      minimumSize: const Size(20, 20),
                                    ),
                                    child: const Icon(size: 23,Icons.close,color: Colors.white,),
                                  ),
                                ),
                              ],
                            );
                          }
                          if (typeOfFile(selectedFiles[index]!) == 1) {
                            return Stack(
                              clipBehavior: Clip.none,
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 3),
                                  child: Container(
                                    color: Colors.grey[200],
                                    height: 130,
                                    width: 130,
                                    child: Icon(
                                      Icons.file_present,
                                      size: 80,
                                      color: selectedFiles[index]!.path.split('.').last == 'docx' ||
                                          selectedFiles[index]!.path.split('.').last == 'doc'
                                          ? Colors.blue[900]
                                          : selectedFiles[index]!.path.split('.').last == 'pdf'
                                          ? Colors.red[700]
                                          : selectedFiles[index]!.path.split('.').last == 'xls' ||
                                          selectedFiles[index]!.path.split('.').last == 'xlsx'
                                          ? Colors.green[600]
                                          : selectedFiles[index]!.path.split('.').last == 'ppt' ||
                                          selectedFiles[index]!.path.split('.').last == 'pptx'
                                          ? Colors.orange[600]
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 105,
                                  bottom: 97,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedFiles.remove(selectedFiles[index]);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black.withOpacity(0.1),
                                      padding: const EdgeInsets.all(4.0),
                                      minimumSize: const Size(20, 20),
                                    ),
                                    child: const Icon(
                                        size: 23, Icons.close, color: Colors.white),
                                  ),
                                ),
                                Positioned(
                                  top: 105,
                                  child: Container(
                                    width: 130,
                                    child: Text(
                                      selectedFiles[index]!.path.split('/').last,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                        else{
                          return null;
                        }
                      },
                    ),
                  ),
                  if(loading)
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Loading(),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: PopupMenuButton(
                          color: fundoMenus,
                          onOpened: (){
                            FocusScope.of(context).unfocus();
                          },
                          onCanceled: (){
                            FocusScope.of(context).unfocus();
                          },
                          onSelected: (val){
                            FocusScope.of(context).unfocus();
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                takeVideo();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    size: 30,
                                    Icons.video_camera_back,
                                    color: Colors.black,
                                  ),
                                  Text('Video')
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                pickVideo();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    size: 30,
                                    Icons.video_library,
                                    color: Colors.black,
                                  ),
                                  Text('Vídeos')
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                await pickImage();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    size: 30,
                                    Icons.image,
                                    color: Colors.black,
                                  ),
                                  Text('Imagens')
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                await takePhoto();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    size: 30,
                                    Icons.camera_alt,
                                    color: Colors.black,
                                  ),
                                  Text('Camâra')
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                await pickFile();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    size: 30,
                                    Icons.file_present,
                                    color: Colors.black,
                                  ),
                                  Text('Ficheiros')
                                ],
                              ),
                            ),
                          ],
                          child: CircleAvatar(
                            radius: 23,
                            backgroundColor: principal,
                            child: Icon(
                              size: 40,
                              Icons.add,
                              color: textoPrincipal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextField(
                          onTapOutside: (val){
                            FocusScope.of(context).unfocus();
                          },
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (val){
                            if(msgController.text.trim().length <= 1){
                              setState(() {

                              });
                            }
                          },
                          controller: msgController,
                          focusNode: focusNode,
                          maxLines: 6,
                          minLines: 1,
                          cursorColor: preto,
                          decoration: const InputDecoration(
                            hintText: 'Mensagem...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if(msgController.text.trim().isNotEmpty || selectedFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if(msgController.text != ''){
                              txtTemp = msgController.text;
                              setState(() {
                                msgController.clear();
                              });
                              await sendMessage();
                              txtTemp = '';
                            }
                            if(selectedFiles.isNotEmpty){
                              selectedTempFiles.addAll(selectedFiles);
                              setState(() {
                                loading = true;
                                selectedFiles.clear();
                              });
                              selectedTempFiles.forEach((file) async {
                                if(typeOfFile(file!) == 1){
                                  await sendFile(file);
                                }
                                else if(typeOfFile(file) == 2){
                                  await sendImage(file);
                                }
                                else if(typeOfFile(file) == 3){
                                  await sendVideo(file);
                                }
                                setState(() {
                                  loading = false;
                                });
                              });
                              selectedTempFiles.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: principal,
                            padding: const EdgeInsets.all(8.0),
                            minimumSize: const Size(40, 40),
                          ),
                          child: Icon(size: 30,Icons.send,color: textoPrincipal,),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
  }
}
