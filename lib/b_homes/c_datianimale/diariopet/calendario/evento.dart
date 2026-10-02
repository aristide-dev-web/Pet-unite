import 'package:easy_localization/easy_localization.dart';

class Evento {
  final String id;
  final String animalId;

  // Base
  final String categoria;
  final String titolo;
  final String descrizione;
  final DateTime data;
  final int? durataGiorni; // Quanti giorni deve durare la ripetizione
  final String ripetizione;
  final List<int> notifiche;
  final bool completato;
  final DateTime creatoIl;

  // Veterinario
  final String? veterinario;
  final String? motivoVisita;
  final String? diagnosi;
  final DateTime? followUpData;
  final double? peso;
  final List<String>? allegati;

  // Terapie
  final String? farmaco;
  final String? dose;
  final String? durataTerapia;
  final String? effettiOsservati;
  final String? istruzioni;
  final int? frequenza; // Quante volte al giorno
  final List<String>? orari; // Es: ["08:00", "16:00", "22:00"]

  // Cura quotidiana
  final String? toelettatura;
  final String? alimentazione;
  final String? comportamento;
  final String? attivitaFisica;

  // Documenti
  final String? documento;
  final DateTime? scadenzaDocumento;
  final List<String>? allegatiDocumento;
  final String? nomeAnimale;
  // Note
  final String? noteExtra;

  Evento({
    required this.id,
    required this.animalId,
    required this.categoria,
    required this.titolo,
    required this.descrizione,
    required this.data,
    this.durataGiorni,
    required this.ripetizione,
    required this.notifiche,
    required this.completato,
    required this.creatoIl,
    this.nomeAnimale,
    this.veterinario,
    this.motivoVisita,
    this.diagnosi,
    this.followUpData,
    this.peso,
    this.allegati,
    this.farmaco,
    this.dose,
    this.durataTerapia,
    this.effettiOsservati,
    this.istruzioni,
    this.frequenza,
    this.orari,
    this.toelettatura,
    this.alimentazione,
    this.comportamento,
    this.attivitaFisica,
    this.documento,
    this.scadenzaDocumento,
    this.allegatiDocumento,
    this.noteExtra,
  });

  // --- OPZIONI CENTRALIZZATE ---
  static Map<String, List<String>> get opzioniPerCategoria => {
    "salute": ["cal_opt_vaccine".tr(), "cal_opt_vet_visit".tr(), "cal_opt_deworming".tr(), "cal_opt_vet_op".tr(), "cal_opt_antiparasitic".tr(), "cal_opt_weight".tr(), "cal_opt_blood".tr()],
    "terapie": ["cal_opt_therapy".tr(), "cal_opt_medicine".tr(), "cal_opt_supplement".tr(), "cal_opt_injection".tr(), "cal_opt_drops".tr(), "cal_opt_ointment".tr()],
    "cura": ["cal_opt_bath".tr(), "cal_opt_grooming".tr(), "cal_opt_nails".tr(), "cal_opt_ears".tr(), "cal_opt_teeth".tr()],
    "impegni": ["cal_opt_walk".tr(), "cal_opt_training".tr(), "cal_opt_park".tr(), "cal_opt_appointment".tr(), "cal_opt_travel".tr()],
    "documenti": ["cal_opt_passport".tr(), "cal_opt_insurance".tr(), "cal_opt_microchip".tr(), "cal_opt_renewal".tr()],
    "altro": [], 
  };

  static String getLabelCategoria(String cat) {
    switch (cat) {
      case "salute": return "cal_cat_salute".tr();
      case "terapie": return "cal_cat_terapie".tr();
      case "cura": return "cal_cat_cura".tr();
      case "impegni": return "cal_cat_impegni".tr();
      case "documenti": return "cal_cat_documenti".tr();
      case "altro": return "cal_cat_altro".tr();
      default: return "cal_cat_default".tr();
    }
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    'nomeAnimale': nomeAnimale,
    "animalId": animalId,
    "categoria": categoria,
    "titolo": titolo,
    "descrizione": descrizione,
    "data": data.toIso8601String(),
    "durataGiorni": durataGiorni,
    "ripetizione": ripetizione,
    "notifiche": notifiche,
    "completato": completato,
    "creatoIl": creatoIl.toIso8601String(),
    "veterinario": veterinario,
    "motivoVisita": motivoVisita,
    "diagnosi": diagnosi,
    "followUpData": followUpData?.toIso8601String(),
    "peso": peso,
    "allegati": allegati,
    "farmaco": farmaco,
    "dose": dose,
    "durataTerapia": durataTerapia,
    "effettiOsservati": effettiOsservati,
    "istruzioni": istruzioni,
    "frequenza": frequenza,
    "orari": orari,
    "toelettatura": toelettatura,
    "alimentazione": alimentazione,
    "comportamento": comportamento,
    "attivitaFisica": attivitaFisica,
    "documento": documento,
    "scadenzaDocumento": scadenzaDocumento?.toIso8601String(),
    "allegatiDocumento": allegatiDocumento,
    "noteExtra": noteExtra,
  };

  static Evento fromMap(Map<String, dynamic> map) => Evento(
    id: map["id"],
    nomeAnimale: map['nomeAnimale'],
    animalId: map["animalId"],
    categoria: map["categoria"],
    titolo: map["titolo"],
    descrizione: map["descrizione"],
    data: DateTime.parse(map["data"]),
    durataGiorni: map["durataGiorni"],
    ripetizione: map["ripetizione"],
    notifiche: List<int>.from(map["notifiche"]),
    completato: map["completato"] ?? false,
    creatoIl: DateTime.parse(map["creatoIl"]),
    veterinario: map["veterinario"],
    motivoVisita: map["motivoVisita"],
    diagnosi: map["diagnosi"],
    followUpData: map["followUpData"] != null ? DateTime.parse(map["followUpData"]) : null,
    peso: map["peso"],
    allegati: map["allegati"] != null ? List<String>.from(map["allegati"]) : null,
    farmaco: map["farmaco"],
    dose: map["dose"],
    durataTerapia: map["durataTerapia"],
    effettiOsservati: map["effettiOsservati"],
    istruzioni: map["istruzioni"],
    frequenza: map["frequenza"],
    orari: map["orari"] != null ? List<String>.from(map["orari"]) : null,
    toelettatura: map["toelettatura"],
    alimentazione: map["alimentazione"],
    comportamento: map["comportamento"],
    attivitaFisica: map["attivitaFisica"],
    documento: map["documento"],
    scadenzaDocumento: map["scadenzaDocumento"] != null ? DateTime.parse(map["scadenzaDocumento"]) : null,
    allegatiDocumento: map["allegatiDocumento"] != null ? List<String>.from(map["allegatiDocumento"]) : null,
    noteExtra: map["noteExtra"],
  );
}
