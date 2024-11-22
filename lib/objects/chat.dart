class ChatObject {
  String docID;
  String uidExplicador;
  String uidExplicando;
  String? estado;
  bool? hasAnswered;

  ChatObject({required this.docID ,required this.uidExplicador , required this.uidExplicando, this.estado, this.hasAnswered});
}