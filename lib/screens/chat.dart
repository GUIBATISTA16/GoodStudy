import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_goodstudy/globais/functionsglobal.dart';
import 'package:projeto_goodstudy/objects/chat.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:projeto_goodstudy/screens/chatficheiros.dart';
import 'package:projeto_goodstudy/screens/perfil.dart';
import 'package:projeto_goodstudy/services/avaliacaodatabase.dart';
import 'package:projeto_goodstudy/services/chatdatabase.dart';
import 'package:projeto_goodstudy/services/msgschatdatabase.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:projeto_goodstudy/widget/fotoperfil.dart';
import 'package:projeto_goodstudy/widget/home/chats/mensagens/msglist.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
//import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../globais/colorsglobal.dart';
import '../globais/stylesglobal.dart';

class Chat extends StatefulWidget {
  final FUser user;
  final ChatObject chat;
  const Chat({super.key, required this.user, required this.chat});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  final msgController = TextEditingController();
  String txtTemp = '';

  Future sendMessage() async{
    MsgsChatDatabaseService db = MsgsChatDatabaseService(chatId: widget.chat.docID);
    await db.sendMensage(globals.userlogged!.uid, txtTemp);
  }

  Future sendImage(File file) async{
    MsgsChatDatabaseService db = MsgsChatDatabaseService(chatId: widget.chat.docID);
    dynamic result = await db.sendImage(globals.userlogged!.uid, file);
    if (result == false){
      showCustomSnackBar(context, 'Erro ao enviar');
    }
  }

  Future sendFile(File file) async{
    MsgsChatDatabaseService db = MsgsChatDatabaseService(chatId: widget.chat.docID);
    dynamic result = await db.sendFile(globals.userlogged!.uid, file);
    if (result == false){
      showCustomSnackBar(context, 'Erro ao enviar');
    }
  }

  Future sendVideo(File file) async{
    MsgsChatDatabaseService db = MsgsChatDatabaseService(chatId: widget.chat.docID);
    dynamic result = await db.sendVideo(globals.userlogged!.uid, file);
    if (result == false){
      showCustomSnackBar(context, 'Erro ao enviar');
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

  void showModalEndChat() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              20.0,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.only(
          top: 10.0,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Terminar Chat com",
                  style: TextStyle(fontSize: 20.0),
                ),
                const Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FotoPerfil(photoUrl: widget.user.photoUrl,size: 50,),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Text(
                    widget.user.nome!,
                    style: const TextStyle(
                        fontSize: 21
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                await ChatDatabaseService().endChat(widget.chat.docID,widget.user.uid);
                MsgsChatDatabaseService(chatId: widget.chat.docID).sendMensage('1', 'Este chat foi termindado');
                setState(() {
                  widget.chat.estado=='Inativo';
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom( backgroundColor: Colors.red,),
              child: const TextoPrincipal(text: 'Terminar',),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom( backgroundColor: principal,),
              child: const TextoPrincipal(text: 'Cancelar',),
            )
          ],
        )
      );
    });
  }

  int rating = 0;

  void showModalAvaliacao() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                contentPadding: const EdgeInsets.only(top: 10.0),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Avaliação",
                          style: TextStyle(fontSize: 20.0),
                        ),
                        const Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FotoPerfil(
                            photoUrl: widget.user.photoUrl,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: Text(
                            widget.user.nome!,
                            style: const TextStyle(fontSize: 21),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'O explicador terminou o chat consigo, dê uma avaliação ao serviço prestado pelo explicador',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color: index < rating ? Colors.orange : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10), // Espaçamento opcional entre as estrelas e o botão
                    ElevatedButton(
                      onPressed: () async {
                        if(rating >= 1 && rating <= 5){
                          await AvaliacaoDatabaseService().createAvaliacao(widget.user.uid, rating);
                          await ChatDatabaseService().hasAnswered(widget.chat.docID);
                          setState(() {
                            widget.chat.hasAnswered = true;
                            // Aqui você pode enviar a avaliação para onde for necessário
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: buttonPrincipalSquare,
                      child: const TextoPrincipal(text: 'Enviar'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future getEstado() async{
    ChatDatabaseService db = ChatDatabaseService();
    DocumentSnapshot documentSnapshot = await db.getEstado(widget.chat.docID);
    widget.chat.estado = documentSnapshot.get('estado');
    if(widget.chat.estado == 'Inativo') {
      widget.chat.hasAnswered = documentSnapshot.get('hasAnswered');
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.chat.estado == null){
      getEstado();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(globals.userlogged!.tipo == 'Explicando' && widget.chat.hasAnswered == false){
        showModalAvaliacao();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ChatDatabaseService(chatId: widget.chat.docID).logChat,
      builder: (context, snapshot) {
        if(snapshot.data != null){
          String estado = snapshot.data!['estado'];
          if(estado != widget.chat.estado){
            widget.chat.estado = estado;
            if(estado == 'Inativo'){
              widget.chat.hasAnswered = snapshot.data!['hasAnswered'];
              if(snapshot.data!['hasAnswered'] == false && globals.userlogged!.tipo == 'Explicando'){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    showModalAvaliacao();
                });
              }
            }
          }
        }
        return Scaffold(
            appBar: AppBar(
              leading: BackButao(
                color: textoPrincipal,
              ),
              title: Row(
                children: [
                  GestureDetector(
                      onTap:(){
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PerfilWrapper(user: widget.user, origem: 'Chat')),
                        );
                      },
                      child: FotoPerfil(photoUrl: widget.user.photoUrl,size: 50,)
                  ),
                  Expanded(child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => FicheirosChat(user: widget.user, chat: widget.chat)
                        )
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: TextoPrincipal(text: '${widget.user.nome}',
                        maxLines: 2,
                      ),
                    ),
                  )),
                ],
              ),
              backgroundColor: principal,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => FicheirosChat(user: widget.user, chat: widget.chat)
                        )
                      );
                    },
                    icon: const Icon(Icons.folder_copy, color: Colors.white,)
                ),
                /*Padding(
                  padding: const EdgeInsets.only(right: 8),
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
                          if(widget.chat.estado == 'Ativo'){
                            String channel = '';
                            if(globals.userlogged!.tipo == 'Explicador'){
                              channel = '${globals.userlogged!.uid.substring(0, 3)}_${widget.user.uid.substring(0,3)}video';
                            }
                            else{
                              channel = '${widget.user.uid.substring(0,3)}_${globals.userlogged!.uid.substring(0, 3)}video';
                            }
                            print('Channel: ' + channel);
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => VideoCallPage(channel: channel,)),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              size: 30,
                              Icons.videocam,
                              color: Colors.black,
                            ),
                            Text('Chamada de Video')
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if(widget.chat.estado == 'Ativo'){
                            String channel = '';
                            if(globals.userlogged!.tipo == 'Explicador'){
                              channel = '${globals.userlogged!.uid.substring(0, 3)}_${widget.user.uid.substring(0,3)}call';
                            }
                            else{
                              channel = '${widget.user.uid.substring(0,3)}_${globals.userlogged!.uid.substring(0, 3)}call';
                            }
                            print('Channel: ' + channel);
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => CallPage(channel: channel,)),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              size: 30,
                              Icons.phone,
                              color: Colors.black,
                            ),
                            Text('Chamada de Voz')
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.videocam, color: Colors.white,)
                  ),
                ),*/
                if(widget.chat.estado == 'Ativo')
                CallButton(isVideoCall: false, user: widget.user),
                if(widget.chat.estado == 'Ativo')
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CallButton(isVideoCall: true, user: widget.user),
                ),
              ],
            ),
            backgroundColor: Colors.grey[300],
            body: FutureBuilder(
              future: getEstado(),
              builder: (context, snapshot){
                if(widget.chat.estado == null){
                  return const Center(child: Loading());
                }
                else{
                  return Column(
                    children: [
                      if(widget.chat.estado == 'Inativo')
                      Container(
                        width: double.infinity,
                        color: principal,
                        child: const Center(
                          child: TextoPrincipal(
                            text: 'Este Chat está inativo',
                          ),
                        )
                      ),
                      if(globals.userlogged!.tipo == 'Explicador' && widget.chat.estado == 'Ativo')
                      Container(
                        color: principal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1,horizontal: 4),
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalEndChat();
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.redAccent[700]),
                                  shape: WidgetStateProperty.all(
                                    const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                ),
                                child: const TextoPrincipal(
                                  text: 'Terminar chat',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ContainerBordasFinas(
                              child: MsgsLista(chat: widget.chat, destinatarioPhotoUrl: widget.user.photoUrl,),
                            )
                        ),
                      ),
                      if(widget.chat.estado == 'Ativo')
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
                                  padding: const EdgeInsets.symmetric(vertical:  2.0),
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
                                        setState(() {});
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
                                if((msgController.text.trim().isNotEmpty || selectedFiles.isNotEmpty)
                                    && widget.chat.estado == 'Ativo')
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical:  2.0),
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
                  );
                }
              },
            ),
          );
      }
    );
  }
}
