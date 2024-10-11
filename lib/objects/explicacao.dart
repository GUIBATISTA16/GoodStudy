class ExplicacaoObject {
  String docId;
  DateTime data;
  int duracao;
  bool minutos;
  String especialidade;
  String titulo;
  List<dynamic> listUtilizadores;

  ExplicacaoObject({
    required this.docId,
    required this.data,
    required this.duracao,
    required this.minutos,
    required this.especialidade,
    required this.titulo,
    required this.listUtilizadores,
  });
}