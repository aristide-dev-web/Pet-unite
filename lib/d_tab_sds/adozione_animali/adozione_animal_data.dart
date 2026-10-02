import 'dart:io';

class AdozioneAnimalData {
  String? nome;
  String? tipo; 
  String? razza;
  String? sesso;
  List<File>? immagini;
  
  String? coloreDominante;
  String? coloreSecondario;
  String? occhiColore;
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

  // Campi specifici per adozione
  String? eta;
  bool vaccinato;
  String? vaccinatoNote;
  bool sverminato;
  String? sverminatoNote;
  bool sterilizzato;
  String? sterilizzatoNote;
  
  bool haCicatrici;
  String? cicatriciNote;
  bool haAllergie;
  String? allergieNote;

  AdozioneAnimalData({
    this.nome,
    this.tipo,
    this.razza,
    this.sesso,
    this.immagini,
    this.coloreDominante,
    this.coloreSecondario,
    this.occhiColore,
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
    this.eta,
    this.vaccinato = false,
    this.vaccinatoNote,
    this.sverminato = false,
    this.sverminatoNote,
    this.sterilizzato = false,
    this.sterilizzatoNote,
    this.haCicatrici = false,
    this.cicatriciNote,
    this.haAllergie = false,
    this.allergieNote,
  });
}
