import 'dart:io';

class LostAnimalData {
  String? petId; 

  // Step 1: Anagrafica e Foto
  String? nome;
  String? tipo; 
  String? razza;
  String? sesso;
  List<File>? immagini;

  // Step 2: Segni di Riconoscimento
  String? coloreDominante; 
  String? coloreSecondario;
  String? occhiColore; 
  String? occhiForma;
  String? orecchieGrandezza;
  String? codaGrandezza;
  String? microchip; // Sì/No
  String? microchipNumero; // Codice numerico
  bool haCicatrici = false;
  String? noteCicatrici;

  // Step 3: Ultimo Avvistamento e Contesto
  String? dataSmarrimento;
  String? via;
  String? citta;
  String? regione;
  double? lat;
  double? lng;
  String? raccontoDettagliato;
  String? ricompensa;

  // Step 4: Contatti Privacy
  List<String> telefoni = [];
  List<String> email = [];
  String? whatsapp; 
  bool mostraContattiPrivati = false;

  LostAnimalData({
    this.petId,
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
    this.microchip,
    this.microchipNumero,
    this.haCicatrici = false,
    this.noteCicatrici,
    this.dataSmarrimento,
    this.via,
    this.citta,
    this.regione,
    this.lat,
    this.lng,
    this.raccontoDettagliato,
    this.ricompensa,
    this.telefoni = const [],
    this.email = const [],
    this.whatsapp,
    this.mostraContattiPrivati = false,
  });
}
