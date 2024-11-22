import 'dart:async';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import 'package:string_validator/string_validator.dart';
import 'package:projeto_goodstudy/services/espsdatabase.dart' as espsDB;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/explicador.dart';
import 'package:projeto_goodstudy/objects/explicando.dart';
import 'package:projeto_goodstudy/services/auth.dart';
import '../globais/colorsglobal.dart';
import '../globais/stylesglobal.dart';
import '../services/files/avatar.dart';
import '../services/userdatabase.dart' as userDB;
import '../widget/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CriarConta extends StatefulWidget {
  const CriarConta({super.key});

  @override
  CriarContaState createState() => CriarContaState();
}

class CriarContaState extends State<CriarConta> {
  final AuthService auth = AuthService();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final descController = TextEditingController();
  final anosExpController = TextEditingController();
  final hrprecoController = TextEditingController();
  final mprecoController = TextEditingController();
  final aprecoController = TextEditingController();

  final formkey = GlobalKey<FormState>();
  String res = '';


  List<String> choices = [
    'Explicador',
    'Explicando'
  ];

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

  @override
  void initState() {
    super.initState();
    getEsps();
  }

  List<String> esps = [];

  Future<void> getEsps() async {
    final espsDB.EspDatabaseService espsdb = espsDB.EspDatabaseService();
    QuerySnapshot snapshot = await espsdb.getData();
    setState(() {
      esps = snapshot.docs.map((doc) => doc['nome'] as String).toList();
    });
  }

  String? selectedEsp;
  String? selectedEnsino;
  String? selectedAno;

  String selectedValue = 'Explicando';

  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
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

  String valT = '';
  String erro = '';
  String? photoUrl;

  bool loading = false;

  Future cconta(BuildContext context) async {
    if(formkey.currentState!.validate()) {
      if(selectedValue == 'Explicador'){
        setState(() {
          loading = true;
          valT = '';
        });

        Explicador user = Explicador(nome: nomeController.text.trimRight(), descricao: descController.text,
            especialidade: selectedEsp.toString(), tipo: 'Explicador', precohr: double.parse(hrprecoController.text.trim())
            , anosExp: int.parse(anosExpController.text.trim()));
        if(mprecoController.text.isNotEmpty){
          user.precomes = double.parse(mprecoController.text);
        }
        if(aprecoController.text.isNotEmpty){
          user.precoano = double.parse(aprecoController.text);
        }

        dynamic result = await auth.registerEmailPassword(emailController.text.trimRight(),
          passwordController.text.trimRight(),user, null);
        if(result == null){
          setState(() {
            loading = false;
            erro = 'Este email não é valido';
          });
        }
        else{
          final userDB.UserDatabaseService db = userDB.UserDatabaseService(uid: result.uid);
          if(selectedImage != null){
            photoUrl = await uploadImagem(result);
            db.setPhotoUrl(result.uid, photoUrl!);
          }
          else{
            db.setPhotoUrl(result.uid, null);
          }
          //await auth.signOut();
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()), // Replace with your home screen widget
          );*/
          /*setState(() {
            loading = false;
            erro = '';
          });*/
        }
      }
      else{
        setState(() {
          loading = true;
          valT = '';
        });
        Explicando user = Explicando(nome: nomeController.text.trimRight(),tipo: 'Explicando', nivel: selectedEnsino! , ano: selectedAno!);
        dynamic result = await auth.registerEmailPassword(emailController.text.trimRight(),
          passwordController.text.trimRight(),null, user);
        if(result == null){
          setState(() {
            loading = false;
            erro = 'Este email não é valido';
          });
        }
        else{
          final userDB.UserDatabaseService db = userDB.UserDatabaseService(uid: result.uid);
          if(selectedImage != null){
            photoUrl = await uploadImagem(result);
            db.setPhotoUrl(result.uid, photoUrl!);
          }
          else{
            db.setPhotoUrl(result.uid, null);
          }
          //await auth.signOut();
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );*/
          /*setState(() {
            loading = false;
            erro = '';
          });*/
        }
      }
    }
  }

  Future<String?> uploadImagem (dynamic result) async {
    final AvatarStorageService storageService = AvatarStorageService();
    return await storageService.uploadAvatar(selectedImage!,result.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButao(
          color: textoPrincipal,
        ),
        centerTitle: true,
        backgroundColor: principal,
        title: const TextoPrincipal(text: 'Criar Conta',),
      ),
      body: loading ? const Loading() : SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null ? const Icon(Icons.person, size: 80) : null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: ElevatedButton(
                      style: buttonPrincipalRound,
                      onPressed: showImageSourceOptions,
                      child: const TextoPrincipal(text: 'Escolher Foto Perfil'),
                    ),
                  ),
                  if(selectedImage != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedImage = null;
                      });
                    },
                    style: ElevatedButton.styleFrom( backgroundColor: Colors.red,),
                    child: const Icon(Icons.highlight_remove,color: Colors.black,),
                  ),
                ],
              ),
              FormField<String>(
                //autovalidateMode: AutovalidateMode.always,
                initialValue: selectedValue,
                builder: (formState) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: preto
                            ),
                            labelText: 'Tipo de Conta',
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          value: formState.value,
                          onChanged: (val) {
                            setState(() {
                              selectedValue=val.toString();
                              selectedEsp=null;
                            });
                            formState.didChange(val);
                          } ,
                          items: choices.map<DropdownMenuItem<String>>((String choice) {
                            return DropdownMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if(selectedValue == 'Explicador')
                FormField<String>(
                  //autovalidateMode: AutovalidateMode.always,
                  initialValue: selectedEsp,
                  builder: (formState) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  color: preto
                              ),
                              labelText: 'Especialidade',
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  validator: (val) => val!.isEmpty ? 'Insira um Nome' : null,
                  controller: nomeController,
                  cursorColor: preto,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: preto
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Nome',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: TextFormField(
                  validator: (val) => val!.isEmpty ? 'Insira um Email' : null,
                  controller: emailController,
                  cursorColor: preto,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: preto
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Email',
                  ),
                ),
              ),
              if(res.isNotEmpty)
                Text(res,style: const TextStyle(
                    color: Colors.red
                ),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: TextFormField(
                  validator: (val) => val!.length < 6 ? 'Insira uma Password com mais de 6 caracteres' : null,
                  controller: passwordController,
                  cursorColor: preto,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: preto
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Password',
                  ),
                ),
              ),
              if (selectedValue == 'Explicando')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: preto
                      ),
                      labelText: 'Nivel de Ensino',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
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
              if (selectedValue == 'Explicando' && selectedEnsino == 'Ensino Básico')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: preto
                      ),
                      labelText: 'Ano de Ensino',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
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
              if (selectedValue == 'Explicando' && selectedEnsino == 'Ensino Secundário')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: preto
                      ),
                      labelText: 'Ano de Ensino',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
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
              if (selectedValue == 'Explicando' && selectedEnsino == 'Ensino Superior')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                          color: preto
                      ),
                      labelText: 'Nivel de Ensino',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
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
              if(selectedValue=='Explicador')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: TextFormField(
                  validator: (val) => !isInt(val!) || int.parse(val) < 0 ? 'Insira um número válido' : null,
                  controller: anosExpController,
                  cursorColor: preto,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                        color: preto
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Anos de Experiência',
                  ),
                ),
              ),
              if(selectedValue=='Explicador')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  controller: descController,
                  cursorColor: preto,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: preto
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: preto),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: preto),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: preto),
                    ),
                    labelText: 'Descrição(opcional)',
                  ),
                ),
              ),
              if(selectedValue=='Explicador')
              const Padding(
                padding: EdgeInsets.fromLTRB(0,8,0,0),
                child: Text('Tabela de Preços'),
              ),
              if(selectedValue=='Explicador')
              const Padding(
                padding: EdgeInsets.fromLTRB(0,0,0,0),
                child: Text('(precisa inserir pelo menos o preço por hora)'),
              ),
              if(selectedValue=='Explicador')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,0,8,0),
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
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por hora'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                validator: (val) {
                                  if(isFloat(val!) && val.isNotEmpty && double.parse(val) > 0){
                                    return null;
                                  }
                                  return 'Insira um custo válido ex: 20.00';
                                },
                                keyboardType: TextInputType.number,
                                controller: hrprecoController,
                                cursorColor: preto,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Insira o preço por hora,Ex: 20.00',
                                  suffix: Text('€',style: TextStyle(color: preto),)
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por mês'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                validator: (val) {
                                  if(isFloat(val!)){
                                    return null;
                                  }
                                  return 'Insira um custo válido ex: 20.00';
                                },
                                keyboardType: TextInputType.number,
                                controller: mprecoController,
                                cursorColor: preto,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Insira o preço por hora,Ex: 20.00',
                                    suffix: Text('€',style: TextStyle(color: preto),)
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Preço por ano '),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                validator: (val) {
                                  if(isFloat(val!)){
                                    return null;
                                  }
                                  return 'Insira um custo válido ex: 20.00';
                                },
                                keyboardType: TextInputType.number,
                                controller: aprecoController,
                                cursorColor: preto,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Insira o preço por hora,Ex: 20.00',
                                    suffix: Text('€',style: TextStyle(color: preto),)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if(valT != '')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8,0,0,0),
                      child: Text(valT,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: ElevatedButton(
                  style: buttonPrincipalRound,
                  onPressed: () async {
                    await cconta(context);
                  },
                  child: const TextoPrincipal(text: 'Criar Conta'),
                ),
              ),
              if(erro != '')
                Padding(
                  padding: const EdgeInsets.fromLTRB(8,0,0,0),
                  child: Text(erro,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

    );
  }

}