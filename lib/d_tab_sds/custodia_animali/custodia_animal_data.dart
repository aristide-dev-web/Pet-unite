import 'dart:io';

class CustodiaAnimalData {
  String? nome;
  String? tipo;
  String? razza;
  String? sesso;
  List<File>? immagini;
  
  String? coloreDominante;
  String? coloreSecondario;
  String? occhiColore;
  String? occhiForma;
  String? orecchieGrandezza;
  String? codaGrandezza;
  
  String? via;
  String? citta;
  String? regione;
  double? lat;
  double? lng;
  
  String? raccontoDettagliato;
  String? microchip;
  String? microchipNumero;
  
  DateTime? dataInizio;
  DateTime? dataFine;

  bool isAnimalFound;
  bool haCicatrici;
  String? noteParticolari;

  CustodiaAnimalData({
    this.nome,
    this.tipo,
    this.razza,
    this.sesso,
    this.immagini,
    this.coloreDominante,
    this.coloreSecondario,
    this.occhiColore,
    this.occhiForma,
    this.orecchieGrandezza,
    this.codaGrandezza,
    this.via,
    this.citta,
    this.regione,
    this.lat,
    this.lng,
    this.raccontoDettagliato,
    this.microchip,
    this.microchipNumero,
    this.dataInizio,
    this.dataFine,
    this.isAnimalFound = true,
    this.haCicatrici = false,
    this.noteParticolari,
  });
}
