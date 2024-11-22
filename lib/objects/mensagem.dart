class MensagemObject {
  String remetente;
  String tipo;
  String data;
  String? texto;
  String? fileUrl;
  String? filename;
  int? width;
  double? aspectRatio;

  MensagemObject({required this.remetente,required this.tipo,required this.data,
    required this.texto,required this.fileUrl, required this.filename, required this.width, required this.aspectRatio });
}