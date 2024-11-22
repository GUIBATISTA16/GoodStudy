import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto_goodstudy/objects/explicador.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import 'package:string_validator/string_validator.dart';

import '../../globais/colorsglobal.dart';
import '../../globais/functionsglobal.dart';
import '../../globais/stylesglobal.dart';
import '../../services/espsdatabase.dart';
import '../../services/files/avatar.dart';
import '../../services/userdatabase.dart';
import '../../globais/widgetglobal.dart';

class EditarExplicador extends StatefulWidget {

  const EditarExplicador({super.key});

  @override
  State<EditarExplicador> createState() => _EditarExplicadorState();
}

class _EditarExplicadorState extends State<EditarExplicador> {
  bool editing = false;

  final nomeController = TextEditingController();
  final descController = TextEditingController();
  final anosExpController = TextEditingController();
  final hrprecoController = TextEditingController();
  final mprecoController = TextEditingController();
  final aprecoController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  List<String> esps = [];

  Future<void> getEsps() async {
    final EspDatabaseService espsdb = EspDatabaseService();
    QuerySnapshot snapshot = await espsdb.getData();
    setState(() {
      esps = snapshot.docs.map((doc) => doc['nome'] as String).toList();
    });
  }

  File? selectedImage;
  String? selectedEsp;

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
    tempPhotoUrl = globals.userlogged!.photoUrl;
    getEsps();
    selectedEsp = globals.userlogged!.especialidade;
    nomeController.text = globals.userlogged!.nome!;
    descController.text = globals.userlogged!.descricao!;
    anosExpController.text = globals.userlogged!.anosexp.toString();
    hrprecoController.text = globals.userlogged!.precohr.toString();
    if(globals.userlogged!.precomes.toString() != 'null') {
      mprecoController.text = globals.userlogged!.precomes.toString();
    }
    if(globals.userlogged!.precoano.toString() != 'null') {
      aprecoController.text = globals.userlogged!.precoano.toString();
    }
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
        title: const TextoPrincipal(text: 'O seu Perfil',),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
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
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
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
                      const SizedBox(width: 8),
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
                            !editing
                            ? Text(globals.userlogged!.especialidade!, style: const TextStyle(fontSize: 19))
                            : FormField<String>(
                              //autovalidateMode: AutovalidateMode.always,
                              initialValue: selectedEsp ?? globals.userlogged!.especialidade,
                              builder: (formState) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Especialidade',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: formState.value,
                                        onChanged: (val) {
                                          setState(() {
                                            selectedEsp=val.toString();
                                          });
                                          formState.didChange(val);
                                        } ,
                                        items: esps.map<DropdownMenuItem<String>>((String choice) {
                                          return DropdownMenuItem<String>(
                                            value: choice,
                                            child: Text(choice),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Selecione uma especialidade';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            !editing
                            ? Text('Anos de Experiência: ${globals.userlogged!.anosexp}', style: const TextStyle(fontSize: 15))
                            : Padding(
                              padding: const EdgeInsets.fromLTRB(0,4,8,0),
                              child: TextFormField(
                                validator: (val) => !isInt(val!) || int.parse(val) < 0 ? 'Insira um número válido' : null,
                                controller: anosExpController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Anos de Experiência',
                                ),
                              ),
                            ),
                            !editing
                            ? Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(globals.userlogged!.descricao!, style: const TextStyle(fontSize: 13)),
                            )
                            : Padding(
                              padding: const EdgeInsets.fromLTRB(0,4,8,8),
                              child: TextFormField(
                                textCapitalization: TextCapitalization.sentences,
                                maxLines: null,
                                controller: descController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Descrição(opcional)',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  globals.userlogged!.avaliacao != null
                      ? Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,2,8,2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Avaliação: ${globals.userlogged!.avaliacao!.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18
                          ),
                        ),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Avaliacao(rating: globals.userlogged!.avaliacao!),
                        )),
                      ],
                    ),
                  )
                      : const Padding(
                    padding: EdgeInsets.fromLTRB(8.0,2,8,2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Avaliação: ainda sem avaliação',
                          style: TextStyle(
                              fontSize: 18
                          ),
                        ),
                        /*Expanded(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Avaliacao(rating: 0),
                        )),*/
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 2,
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
                    child: Table(
                      border: TableBorder.all(
                        color: Colors.grey.shade700,
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(111.0),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        const TableRow(
                          children: [
                            Text(
                              'Tipo',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Preço',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (globals.userlogged!.precohr != null || editing)
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por hora'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: !editing
                              ? Text('${globals.userlogged!.precohr}€')
                              : TextFormField(
                                validator: (val) {
                                  if(isFloat(val!) && val.isNotEmpty && double.parse(val) > 0){
                                    return null;
                                  }
                                  return 'Insira um custo válido ex: 20.00';
                                },
                                keyboardType: TextInputType.number,
                                controller: hrprecoController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Insira o preço por hora,Ex: 20.00',
                                    suffix: Text('€')
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (globals.userlogged!.precomes != null || editing)
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por mês'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: !editing
                              ? Text('${globals.userlogged!.precomes}€')
                              : TextFormField(
                                validator: (val) {
                                  if(isFloat(val!)){
                                    return null;
                                  }
                                  return 'Insira um custo válido ex: 20.00';
                                },
                                keyboardType: TextInputType.number,
                                controller: mprecoController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Insira o preço por mês',
                                    suffix: Text('€')
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (globals.userlogged!.precoano != null || editing)
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por ano '),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: !editing
                              ? Text('${globals.userlogged!.precoano}€')
                              : TextFormField(
                                validator: (val) {
                                  if(isFloat(val!)){
                                    return null;
                                  }
                                  return 'Insira um custo válido ex: 20.00';
                                },
                                keyboardType: TextInputType.number,
                                controller: aprecoController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Insira o preço por ano',
                                    suffix: Text('€')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                              Explicador exp = Explicador(nome: nomeController.text.trimRight(),
                                  descricao: descController.text,
                                  especialidade: selectedEsp!,
                                  tipo: 'Explicador',
                                  precohr: double.parse(hrprecoController.text.trim()),
                                  anosExp: int.parse(anosExpController.text));
                              exp.precomes = double.tryParse(mprecoController.text.trim());
                              exp.precoano = double.tryParse(aprecoController.text.trim());
                              db.updateExplicadorData(exp,avaliacao: globals.userlogged!.avaliacao);
                              showCustomSnackBar(context,'Perfil atualizado');
                              setState(() {
                                globals.userlogged!.photoUrl = photoUrl;
                                globals.userlogged!.nome = nomeController.text.trimRight();
                                globals.userlogged!.descricao = descController.text;
                                globals.userlogged!.anosexp = int.parse(anosExpController.text.trimRight());
                                globals.userlogged!.especialidade = selectedEsp;
                                globals.userlogged!.precohr = double.parse(hrprecoController.text.trim());
                                if(mprecoController.text.isNotEmpty) {
                                  globals.userlogged!.precomes = double.parse(mprecoController.text.trim());
                                }
                                else{
                                  globals.userlogged!.precomes = null;
                                }
                                if(aprecoController.text.isNotEmpty) {
                                  globals.userlogged!.precoano = double.parse(aprecoController.text.trim());
                                }
                                else{
                                  globals.userlogged!.precoano = null;
                                }

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
                              descController.text = globals.userlogged!.descricao!;
                              anosExpController.text = globals.userlogged!.anosexp.toString();
                              hrprecoController.text = globals.userlogged!.precohr.toString();
                              if(globals.userlogged!.precomes.toString() != 'null') {
                                mprecoController.text = globals.userlogged!.precomes.toString();
                              }
                              if(globals.userlogged!.precoano.toString() != 'null') {
                                aprecoController.text = globals.userlogged!.precoano.toString();
                              }
                              tempPhotoUrl = globals.userlogged!.photoUrl;
                              selectedEsp = globals.userlogged!.especialidade;
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
        },
      ),
    );
  }
}
