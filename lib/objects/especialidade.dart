class Especialidade{
  int id;
  String especialidade;

  Especialidade({required this.especialidade, required this.id});

  factory Especialidade.fromJson(Map<String, dynamic> json) {
    return Especialidade(
      id: json['idEsp'],
      especialidade: json['especialidade'],
    );
  }
}