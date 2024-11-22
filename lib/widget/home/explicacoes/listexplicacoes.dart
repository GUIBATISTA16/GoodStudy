import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/globais/colorsglobal.dart';
import 'package:projeto_goodstudy/services/explicacaodatabase.dart';
import 'package:projeto_goodstudy/widget/home/explicacoes/explicacaoitem.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:projeto_goodstudy/globais/varGlobal.dart' as globals;
import '../../../globais/stylesglobal.dart';
import '../../../objects/explicacao.dart';
import '../../../globais/widgetglobal.dart';
import 'criarmarcacao.dart';

class ExplicacoesLista extends StatefulWidget {
  const ExplicacoesLista({super.key});

  @override
  State<ExplicacoesLista> createState() => _ExplicacoesListaState();
}

class _ExplicacoesListaState extends State<ExplicacoesLista> {

  Future<List<ExplicacaoObject>>?  listExplicacoes;
  Future getExplicacoes(String especialidade) async {
    listExplicacoes = ExplicacaoDatabaseService().getExplicacoes(especialidade);
  }

  String selectedEsp = 'Nenhuma';
  List<String> listEspecialidades = [];
  Future getEspecialidades() async {
    listEspecialidades = await ExplicacaoDatabaseService().getEspecialidades();
  }


  @override
  void initState() {
    super.initState();
    getExplicacoes('Nenhuma');
    getEspecialidades();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                  color: Colors.black
              ),
            ),
          ),
          child: ExpansionTile(
            title: const Text('Explicações'),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        showDuration: Duration(seconds: 2),
                        message: 'Ao clicar em uma  Explicação marcada pode adiciona-la á agenda do telemovel',
                        child: Icon(Icons.info_outline,color: Colors.black87,)
                    ),
                  ),
                  if(globals.userlogged!.tipo == 'Explicador')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      child: ElevatedButton(
                        style: buttonPrincipalSquare,
                        onPressed: () {
                          setState(() {
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
                                    Text('Marcar Explicação'),
                                  ],
                                ),
                                content: Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                                    maxWidth: MediaQuery.of(context).size.height * 0.9,
                                  ),
                                  child: const Criarmarcacao(),
                                ),
                              );
                            });
                          });
                        },
                        child: Container(
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.edit_calendar, color: Colors.white),
                              SizedBox(width: 4,),
                              TextoPrincipal(
                                text: 'Marcar Explicação',
                                fontSize: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if(globals.userlogged!.tipo != 'Explicador')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormField<String>(
                  //autovalidateMode: AutovalidateMode.always,
                  initialValue: selectedEsp,
                  builder: (formState) {
                    return DropdownButtonFormField<String>(
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
                          getExplicacoes(selectedEsp);
                        });
                        formState.didChange(val);
                      } ,
                      items: listEspecialidades.map<DropdownMenuItem<String>>((String choice) {
                        return DropdownMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: ExplicacaoDatabaseService().streamExplicacoes,
            builder: (context,snapshot){
              getEspecialidades();
              getExplicacoes(selectedEsp);
              return FutureBuilder(
                future: listExplicacoes,
                builder: (context,snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Loading());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhuma explicação marcada.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Explicacaoitem(explicacao: snapshot.data![index]);
                      },
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
