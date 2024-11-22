import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart'as globals;
import 'package:projeto_goodstudy/widget/home/pedidos/pedidoslistapendentes.dart';
import 'package:projeto_goodstudy/widget/home/pesquisa/widgetlista.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import '../../../globais/colorsglobal.dart';
import '../../../globais/stylesglobal.dart';
import '../../../objects/fuser.dart';
import '../../../services/espsdatabase.dart';
import '../../../services/userdatabase.dart';
import '../../loading.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {

  final nomeController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  String? selectedEsp;

  Future<void> getEsps() async {
    final EspDatabaseService db = EspDatabaseService();
    QuerySnapshot snapshot = await db.getData();
    //setState(() {
      globals.esps = snapshot.docs.map((doc) => doc['nome'] as String).toList();
      globals.esps.add('Nenhuma');
      selectedEsp = 'Nenhuma';
    //});
  }

  String selectedOrd = 'Alfabética';
  List<String> possibleOrd = [
    'Alfabética','Preço Ascendente','Preço Decrescente','Avaliação'
  ];

  late Future<List<FUser>>? listExplicadores;
  Future<List<FUser>> pesquisaInicial() async {
    final UserDatabaseService db = UserDatabaseService(uid: globals.userlogged!.uid);
    return await db.getExplicadoresPesquisa('', 'Nenhuma',0.0,50.0,'Alfabética');
  }

  Future<List<FUser>> pesquisa() async {
    final UserDatabaseService db = UserDatabaseService(uid: globals.userlogged!.uid);
    return await db.getExplicadoresPesquisa(nomeController.text.trimRight(), selectedEsp!,rangeValues.start,rangeValues.end,
        selectedOrd);
  }

  double _roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
  RangeValues rangeValues = const RangeValues(0.0, 50.0);

  @override
  Widget build(BuildContext context) {
    RangeLabels rangeLabels = RangeLabels(
      '${_roundToTwoDecimals(rangeValues.start).toString()}€',
      '${_roundToTwoDecimals(rangeValues.end).toString()}€',
    );
    return Expanded(
      child:
      Column(
        children: [
          IntrinsicHeight(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                        color: Colors.black
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpansionTile(
                        collapsedBackgroundColor: textoPrincipal,
                        backgroundColor: textoPrincipal,
                        title: const Text('Filtros'),
                        collapsedIconColor: Colors.black,
                        iconColor: Colors.black,
                        children: [
                          FormField<String>(
                            //autovalidateMode: AutovalidateMode.always,
                            initialValue: selectedEsp,
                            builder: (formState) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(color: preto),
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
                                  value: formState.value ?? 'Nenhuma',
                                  onChanged: (val) {
                                    setState(() {
                                      selectedEsp=val.toString();
                                      listExplicadores = pesquisa();
                                    });

                                    formState.didChange(val);
                                  } ,
                                  items: globals.esps.map<DropdownMenuItem<String>>((String choice) {
                                    return DropdownMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              controller: nomeController,
                              cursorColor: preto,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: preto),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: preto)
                                ),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: preto)
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: preto)
                                ),
                                labelText: 'Pesquisar por Nome',
                                suffixIcon: const Icon(
                                  Icons.search,
                                ),
                              ),
                              onChanged: (val){
                                setState(() {
                                  listExplicadores = pesquisa();
                                });
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 0,horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Preço',
                                      style: TextStyle(
                                        fontSize: 18
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: startController,
                                    cursorColor: preto,
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(color: preto),
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(color: preto)
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: preto)
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: preto)
                                      ),
                                      suffix: Text('€',style: TextStyle(color: preto),),
                                      labelText: 'Min',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      double? value = double.tryParse(val);
                                      if (value != null && value <= rangeValues.end && value >= 0.0 && value <= 50.0) {
                                        setState(() {
                                          rangeValues = RangeValues(value, rangeValues.end);
                                        });
                                      }
                                      else if (value != null && value > 50){
                                        setState(() {
                                          startController.text = '50';
                                          rangeValues = RangeValues(50, rangeValues.end);
                                        });
                                      }
                                      else if (value != null && value < 0){
                                        setState(() {
                                          startController.text = '0';
                                          rangeValues = RangeValues(0, rangeValues.end);
                                        });
                                      }
                                      setState(() {
                                        listExplicadores = pesquisa();
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: endController,
                                    cursorColor: preto,
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(color: preto),
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(color: preto)
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: preto)
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: preto)
                                      ),
                                      suffix: const Text('€'),
                                      labelText: 'Max',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      double? value = double.tryParse(val);
                                      if (value != null && value >= rangeValues.start && value >= 0.0 && value <= 50.0) {
                                        setState(() {
                                          rangeValues = RangeValues(rangeValues.start, value);
                                        });
                                      }
                                      else if (value != null && value > 50){
                                        setState(() {
                                          endController.text = '50';
                                          rangeValues = RangeValues(rangeValues.start, 50);
                                        });
                                      }
                                      else if (value != null && value < 0){
                                        setState(() {
                                          endController.text = '0';
                                          rangeValues = RangeValues(rangeValues.start, 0);
                                        });
                                      }
                                      setState(() {
                                        listExplicadores = pesquisa();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RangeSlider(
                            values: rangeValues,
                            labels: rangeLabels,
                            inactiveColor: secondary,
                            activeColor: principal,
                            min: 0.0,
                            max: 50.0,
                            divisions: 50,
                            onChanged: (val) {
                              setState(() {
                                rangeValues = RangeValues(
                                  _roundToTwoDecimals(val.start),
                                  _roundToTwoDecimals(val.end),
                                );
                                startController.text = rangeValues.start.toString();
                                endController.text = rangeValues.end.toString();
                                listExplicadores = pesquisa();
                              });
                            },
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                  child: ElevatedButton(
                                    style: buttonPrincipalSquare,
                                    onPressed: () async {
                                      setState(() {
                                        listExplicadores = pesquisa();
                                      });
                                    },
                                    child: Container(
                                      width: 100,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.search, color: Colors.white),
                                          TextoPrincipal(
                                            text: 'Pesquisar',
                                            fontSize: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FormField<String>(
                                  //autovalidateMode: AutovalidateMode.always,
                                  initialValue: selectedOrd,
                                  builder: (formState) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelStyle: TextStyle(color: preto),
                                          labelText: 'Ordenar',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: preto),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: preto),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: preto),
                                          ),
                                        ),
                                        value: formState.value,
                                        onChanged: (val) {
                                          setState(() {
                                            selectedOrd=val.toString();
                                            listExplicadores = pesquisa();
                                          });
                                          formState.didChange(val);
                                        } ,
                                        items: possibleOrd.map<DropdownMenuItem<String>>((String choice) {
                                          return DropdownMenuItem<String>(
                                            value: choice,
                                            child: Text(choice),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if(!globals.userlogged!.isAnonymous)
                      Container(
                          decoration: BoxDecoration(
                              border: const Border.symmetric(
                                horizontal: BorderSide(
                                    color: Colors.black
                                ),
                              ),
                              color: fundoMenus
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                  onPressed: (){
                                    showDialog(context: context, builder: (context){
                                      return AlertDialog(
                                        insetPadding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.only(top: 10.0),
                                        title: const Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            BackButao(
                                              color: Colors.black,
                                            ),
                                            Text('Pedidos Pendentes'),
                                          ],
                                        ),
                                        content: Container(
                                          width: MediaQuery.of(context).size.width * 0.9,
                                          height: MediaQuery.of(context).size.height * 0.8,
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                                            maxWidth: MediaQuery.of(context).size.height * 0.9,
                                          ),
                                          child: const PedidosPendentesLista(),
                                        ),
                                      );
                                    });
                                  },
                                  style: buttonPrincipalSquare,
                                  child: const TextoPrincipal(text: 'Pedidos Pendentes'),
                                ),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: listExplicadores,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Loading());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum explicador encontrado.'));
                } else {
                  return Container(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Carde(child: CampoLista(user: snapshot.data![index]));
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getEsps();
    listExplicadores = pesquisaInicial();
    startController.text = _roundToTwoDecimals(rangeValues.start).toString();
    endController.text = _roundToTwoDecimals(rangeValues.end).toString();
  }
}
