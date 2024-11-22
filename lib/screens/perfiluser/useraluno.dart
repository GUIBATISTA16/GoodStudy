import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto_goodstudy/objects/explicando.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;

import '../../globais/colorsglobal.dart';
import '../../globais/functionsglobal.dart';
import '../../globais/stylesglobal.dart';
import '../../services/files/avatar.dart';
import '../../services/userdatabase.dart';
import '../../globais/widgetglobal.dart';

class EditarAluno extends StatefulWidget {
  const EditarAluno({super.key});

  @override
  State<EditarAluno> createState() => _EditarAlunoState();
}

class _EditarAlunoState extends State<EditarAluno> {

  final nomeController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  bool editing = false;

  List<String> nivelEnsino = [
    'Ensino Básico',
    'Ensino Secundário',
    'Ensino Superior'
  ];

  List<String> ensinoBasico = [
    '1ºAno',
    '2ºAno',
    '3ºAno',
    '4ºAno',
    '5ºAno',
    '6ºAno',
    '7ºAno',
    '8ºAno',
    '9ºAno',
  ];

  List<String> ensinoSecundario = [
    '10ºAno',
    '11ºAno',
    '12ºAno',
  ];

  List<String> ensinoSuperior = [
    'Licenciatura',
    'Mestrado',
    'Doutoramento',
  ];

  String? selectedEnsino;
  String? selectedAno;

  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        tempPhotoUrl = null;
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        tempPhotoUrl = null;
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  pickImage();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Tirar Foto'),
                onTap: () {
                  takePhoto();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? tempPhotoUrl;

  Future<String?> uploadImagem (String uid) async {
    final AvatarStorageService storageService = AvatarStorageService();
    return await storageService.uploadAvatar(selectedImage!,uid);
  }

  @override
  void initState() {
    super.initState();
    nomeController.text = globals.userlogged!.nome!;
    selectedEnsino = globals.userlogged!.nivel!;
    selectedAno = globals.userlogged!.ano!;
    tempPhotoUrl = globals.userlogged!.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        leading: BackButao(
          color: textoPrincipal,
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        title: const TextoPrincipal(text: 'O seu Perfil',
          maxLines: 2,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(principal),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  editing = true;
                });
              },
              child: const Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  const SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8,),
                      if(!editing)
                      globals.userlogged!.photoUrl == null
                          ? const CircleAvatar(
                          radius: 70,
                          child: Icon(Icons.person, size: 110)
                      )
                          : CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(
                            '${globals.userlogged!.photoUrl}'),
                      ),
                      Column(
                        children: [
                          if(tempPhotoUrl == null && editing)
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: AlignmentDirectional.topEnd,
                            children: [
                              CircleAvatar(
                                radius: 70,
                                backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                                child: selectedImage == null ? const Icon(Icons.person, size: 80) : null,
                              ),
                              if(selectedImage != null || tempPhotoUrl != null)
                              Positioned(
                                left: 105,
                                bottom: 97,
                                child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      tempPhotoUrl = null;
                                      selectedImage = null;
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
                          ),
                          if(tempPhotoUrl != null && editing)
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: AlignmentDirectional.topEnd,
                            children: [
                              CircleAvatar(
                                radius: 70,
                                backgroundImage: NetworkImage(
                                  '${tempPhotoUrl}'
                                ),
                              ),
                              if(selectedImage != null || tempPhotoUrl != null)
                              Positioned(
                                left: 105,
                                bottom: 97,
                                child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      tempPhotoUrl = null;
                                      selectedImage = null;
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
                          ),
                          if(editing)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: ElevatedButton(
                                  onPressed: showImageSourceOptions,
                                  child: const TextoPrincipal(text: 'Escolher Foto'),
                                  style: buttonPrincipalRound,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(width: 8,),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            !editing
                              ? Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(globals.userlogged!.nome!,
                                    style: const TextStyle(
                                      fontSize: 26
                                    ),
                                  ),
                              )
                              : Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextFormField(
                                    textCapitalization: TextCapitalization.words,
                                    validator: (val) => val!.isEmpty ? 'Insira um Nome' : null,
                                    controller: nomeController,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Nome',
                                    ),
                                  ),
                              ),

                            const Padding(
                              padding: EdgeInsets.fromLTRB(0,8,8,5),
                              child: Text('Nivel de escolaridade atual: ',
                                style: TextStyle(
                                    fontSize: 15
                                ),
                              ),
                            ),
                            !editing
                            ? Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(globals.userlogged!.nivel!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                            )
                            : Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Nivel de Ensino',
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedEnsino,
                                onChanged: (val) {
                                  setState(() {
                                    selectedEnsino = val;
                                    selectedAno = null;
                                  });
                                },
                                items: nivelEnsino.map<DropdownMenuItem<String>>((String choice) {
                                  return DropdownMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um nivel de escolaridade';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 4,),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0,0,8,5),
                              child: Text('Ano de escolaridade atual: ',
                                style: TextStyle(
                                    fontSize: 15
                                ),
                              ),
                            ),
                            if(!editing)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(globals.userlogged!.ano!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                            ),
                            if(editing && selectedEnsino == 'Ensino Básico')
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Ano de Ensino',
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedAno,
                                onChanged: (val) {
                                  setState(() {
                                    selectedAno = val;
                                  });
                                },
                                items: ensinoBasico.map<DropdownMenuItem<String>>((String choice) {
                                  return DropdownMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um ano de escolaridade';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if(editing && selectedEnsino == 'Ensino Secundário')
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Ano de Ensino',
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedAno,
                                onChanged: (val) {
                                  setState(() {
                                    selectedAno = val;
                                  });
                                },
                                items: ensinoSecundario.map<DropdownMenuItem<String>>((String choice) {
                                  return DropdownMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um ano de escolaridade';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if(editing && selectedEnsino == 'Ensino Superior')
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Nivel de Ensino',
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedAno,
                                onChanged: (val) {
                                  setState(() {
                                    selectedAno = val;
                                  });
                                },
                                items: ensinoSuperior.map<DropdownMenuItem<String>>((String choice) {
                                  return DropdownMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione um nivel de escolaridade';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 4,),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 2,
                    thickness: 1,
                  ),
                  if(editing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if(formkey.currentState!.validate()){
                            String? photoUrl = globals.userlogged!.photoUrl;
                            final UserDatabaseService db = UserDatabaseService(uid: globals.userlogged!.uid);
                            await db.updateExplicandoData(Explicando(
                                nome: nomeController.text.trimRight(),
                                tipo: 'Explicando',
                                nivel: selectedEnsino!,
                                ano: selectedAno!));
                            if(globals.userlogged!.photoUrl == null){
                              if(selectedImage != null){
                                photoUrl = await uploadImagem(globals.userlogged!.uid);
                                await db.setPhotoUrl(globals.userlogged!.uid, photoUrl);
                              }
                            }
                            else{
                              if(selectedImage != null && tempPhotoUrl == null){
                                photoUrl = await uploadImagem(globals.userlogged!.uid);
                                await db.setPhotoUrl(globals.userlogged!.uid, photoUrl);
                              }
                              if(selectedImage == null && tempPhotoUrl == null){
                                photoUrl = null;
                                await db.setPhotoUrl(globals.userlogged!.uid, photoUrl);
                              }
                            }
                            showCustomSnackBar(context,'Perfil atualizado');
                            setState(() {
                              globals.userlogged!.photoUrl = photoUrl;
                              globals.userlogged!.nome = nomeController.text.trimRight();
                              globals.userlogged!.nivel = selectedEnsino;
                              globals.userlogged!.ano = selectedAno;
                              editing = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom( backgroundColor: Colors.green,),
                        child: Row(
                          children: [
                            const TextoPrincipal(text: 'Guardar',),
                            Icon(Icons.save,color: textoPrincipal,),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            nomeController.text = globals.userlogged!.nome!;
                            selectedEnsino = globals.userlogged!.nivel!;
                            selectedAno = globals.userlogged!.ano!;
                            tempPhotoUrl = globals.userlogged!.photoUrl;
                            editing = false;
                          });
                        },
                        style: ElevatedButton.styleFrom( backgroundColor: Colors.red,),
                        child: Row(
                          children: [
                            const TextoPrincipal(text: 'Cancelar',),
                            Icon(Icons.clear,color: textoPrincipal,),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
