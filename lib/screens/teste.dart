import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projeto_goodstudy/services/auth.dart';
import 'package:projeto_goodstudy/widget/logoutbutton.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import 'package:uuid/uuid.dart';
import '../globais/stylesglobal.dart';
import '../services/files/avatar.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;


class Teste extends StatefulWidget {
  const Teste({super.key});

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {

  final PageController _pageController = PageController(initialPage: globals.opcao);


  @override
  void initState() {
    super.initState();
    //globals.opcao= 1;
  }

  List<File?> selectedFiles = [];

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true
        //allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx' , 'txt' , 'ppt' , 'pptx', 'odt']
    );
    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(

        ),
        actions: [
          //Logout()
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width* 0.95,
              child: ContainerBordasFinas(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFiles!.length,
                  itemBuilder: (context, index){
                    if(selectedFiles.length > 0) {
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
                                selectedFiles[index] = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              padding: EdgeInsets.all(4.0),
                              minimumSize: Size(20, 20),
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
                )
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              pickFile();
            },
            style: buttonPrincipalSquare,
            child: TextoPrincipal(text: 'Escolher ficheiros',),
          )
        ],
      )
    );
  }
}
