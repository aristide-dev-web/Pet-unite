import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'sitter_model.g.dart';

@HiveType(typeId: 7)
class SitterProfile extends HiveObject {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String nome;
  @HiveField(2)
  final String cognome;
  @HiveField(3)
  final String bio;
  @HiveField(4)
  final String fotoUrl;
  @HiveField(5)
  final int eta;
  @HiveField(6)
  final bool verificato;
  @HiveField(7)
  final bool etaVerificata;
  @HiveField(8)
  final String dataNascita;
  @HiveField(9)
  final DateTime? dataVerifica;
  @HiveField(10)
  final String metodoVerifica;

  @HiveField(11)
  final int anniEsperienza;
  @HiveField(12)
  final List<String> specieEsperienza;
  @HiveField(13)
  final bool bisogniSpeciali;
  @HiveField(14)
  final bool somministrazioneFarmaci;
  @HiveField(15)
  final bool gestioneAnimaliDifficili;

  @HiveField(16)
  final Map<String, double> serviziPrezzi;
  @HiveField(17)
  final Map<String, int> maxAnimali;
  @HiveField(18)
  final Map<String, String> orariDisponibili;
  
  @HiveField(19)
  final String tipoCasa;
  @HiveField(20)
  final bool giardino;
  @HiveField(21)
  final List<String> fotoCasa;

  @HiveField(22)
  final List<String> taglieAccettate;
  @HiveField(23)
  final List<String> razzeEscluse;
  @HiveField(24)
  final bool disponibilitaNotte;

  @HiveField(25)
  final double rating;
  @HiveField(26)
  final int numeroRecensioni;

  @HiveField(27)
  final String citta;
  @HiveField(28)
  final String indirizzo;
  @HiveField(29)
  final String telefono;
  @HiveField(30)
  final List<String> fotoChiSei;
  @HiveField(31)
  final bool assenzaPrecedenti;
  @HiveField(32)
  final bool esperienzaProfessionale;
  
  @HiveField(33)
  final List<dynamic> certificazioni; 
  
  @HiveField(34)
  final List<String> competenze;
  @HiveField(35)
  final String descrizioneEsperienza;
  @HiveField(36)
  final String quartiere;
  @HiveField(37)
  final double raggioKm;
  @HiveField(38)
  final List<String> giorniDisponibili;
  @HiveField(39)
  final bool altriAnimali;
  @HiveField(40)
  final bool bambini;

  @HiveField(41)
  final double? lat;
  @HiveField(42)
  final double? lng;

  @HiveField(43)
  final String regione; 
  @HiveField(44)
  final String nazione;

  @HiveField(45)
  final Map<String, double> serviziPrezziAggiuntivi; 
  @HiveField(46)
  final Map<String, String> serviziNote;
  @HiveField(47)
  final Map<String, String> serviziDurata;
  @HiveField(48)
  final Map<String, double> serviziWeekendExtra;
  @HiveField(49)
  final Map<String, double> serviziTaxiPet;
  @HiveField(50)
  final Map<String, String> serviziCheckIn;
  @HiveField(51)
  final Map<String, String> serviziCheckOut;
  @HiveField(52)
  final Map<String, List<String>> serviziTaglie;
  @HiveField(53)
  final Map<String, bool> serviziWeekendAttivi;
  @HiveField(54)
  final Map<String, bool> serviziNotturnoAttivi;
  @HiveField(55)
  final Map<String, double> serviziNotturnoExtra;
  @HiveField(56)
  final Map<String, bool> serviziAsciugaturaAttivi;
  
  @HiveField(57)
  final Map<String, bool> serviziScontoAttivo;
  @HiveField(58)
  final Map<String, double> serviziScontoPerc;
  @HiveField(59)
  final Map<String, int> serviziScontoDal;

  @HiveField(60)
  final List<String> comportamentiEsclusi;
  @HiveField(61)
  final bool ambienteSicuro;
  @HiveField(62)
  final String percheSitter;
  @HiveField(63)
  final String cosaSpeciale;

  @HiveField(64)
  final String email;

  // Pensione (Gestione Bisogni)
  @HiveField(65)
  final int boardingDailyWalks;
  @HiveField(66)
  final List<String> boardingToiletOptions;
  @HiveField(67)
  final String boardingToiletFrequency;
  @HiveField(68)
  final String boardingHygieneDescription;
  @HiveField(69)
  final List<String> boardingSpecialNeeds;

  // Taxi Pet Specific
  @HiveField(70)
  final double taxiBaseFare;
  @HiveField(71)
  final double taxiPricePerKm;
  @HiveField(72)
  final List<String> taxiSpecieAccettate;
  @HiveField(73)
  final double taxiMaxDistance;
  @HiveField(78)
  final double taxiPricePerMin;
  @HiveField(79)
  final double taxiNightSurcharge;
  @HiveField(80)
  final List<String> taxiTransportModes;

  @HiveField(74)
  final Map<String, bool> attrezzatura;
  @HiveField(75)
  final String attrezzaturaAltro;

  @HiveField(76)
  final List<String> serviziAttivi;

  @HiveField(77)
  final String username;

  @HiveField(81) 
  final String geohash;

  // STRIPE CONNECT FIELDS
  @HiveField(82)
  final String? stripeAccountId;
  @HiveField(83)
  final bool stripeOnboardingComplete;

  @HiveField(84)
  final bool prenotazioneLastMinute;

  @HiveField(85)
  final bool emailVerificata;
  @HiveField(86)
  final bool phoneVerificata;

  SitterProfile({
    required this.uid,
    required this.nome,
    required this.cognome,
    this.bio = '',
    this.fotoUrl = '',
    required this.eta,
    this.verificato = false,
    this.etaVerificata = false,
    required this.dataNascita,
    this.dataVerifica,
    this.metodoVerifica = 'AI OCR',
    this.anniEsperienza = 0,
    this.specieEsperienza = const [],
    this.bisogniSpeciali = false,
    this.somministrazioneFarmaci = false,
    this.gestioneAnimaliDifficili = false,
    this.serviziPrezzi = const {},
    this.serviziPrezziAggiuntivi = const {},
    this.maxAnimali = const {},
    this.orariDisponibili = const {},
    this.serviziNote = const {},
    this.serviziDurata = const {},
    this.serviziWeekendExtra = const {},
    this.serviziTaxiPet = const {},
    this.serviziCheckIn = const {},
    this.serviziCheckOut = const {},
    this.serviziTaglie = const {},
    this.serviziWeekendAttivi = const {},
    this.serviziNotturnoAttivi = const {},
    this.serviziNotturnoExtra = const {},
    this.serviziAsciugaturaAttivi = const {},
    this.serviziScontoAttivo = const {},
    this.serviziScontoPerc = const {},
    this.serviziScontoDal = const {},
    this.tipoCasa = '',
    this.giardino = false,
    this.fotoCasa = const [],
    this.taglieAccettate = const [],
    this.razzeEscluse = const [],
    this.comportamentiEsclusi = const [],
    this.ambienteSicuro = false,
    this.percheSitter = '',
    this.cosaSpeciale = '',
    this.disponibilitaNotte = false,
    this.rating = 0.0,
    this.numeroRecensioni = 0,
    this.citta = '',
    this.indirizzo = '',
    this.telefono = '',
    this.fotoChiSei = const [],
    this.assenzaPrecedenti = false,
    this.esperienzaProfessionale = false,
    this.certificazioni = const [],
    this.competenze = const [],
    this.descrizioneEsperienza = '',
    this.quartiere = '',
    this.raggioKm = 5.0,
    this.giorniDisponibili = const [],
    this.altriAnimali = false,
    this.bambini = false,
    this.lat,
    this.lng,
    this.regione = '',
    this.nazione = '',
    this.email = '',
    this.boardingDailyWalks = 3,
    this.boardingToiletOptions = const [],
    this.boardingToiletFrequency = 'Ogni 6 ore',
    this.boardingHygieneDescription = '',
    this.boardingSpecialNeeds = const [],
    this.taxiBaseFare = 0.0,
    this.taxiPricePerKm = 0.0,
    this.taxiPricePerMin = 0.0,
    this.taxiNightSurcharge = 0.0,
    this.taxiSpecieAccettate = const [],
    this.taxiMaxDistance = 0.0,
    this.taxiTransportModes = const [],
    this.attrezzatura = const {},
    this.attrezzaturaAltro = '',
    this.serviziAttivi = const [],
    this.username = '',
    this.geohash = '',
    this.stripeAccountId,
    this.stripeOnboardingComplete = false,
    this.prenotazioneLastMinute = false,
    this.emailVerificata = false,
    this.phoneVerificata = false,
  });

  SitterProfile copyWith({
    String? uid,
    String? nome,
    String? cognome,
    String? bio,
    String? fotoUrl,
    int? eta,
    bool? verificato,
    bool? etaVerificata,
    String? dataNascita,
    DateTime? dataVerifica,
    String? metodoVerifica,
    int? anniEsperienza,
    List<String>? specieEsperienza,
    bool? bisogniSpeciali,
    bool? somministrazioneFarmaci,
    bool? gestioneAnimaliDifficili,
    Map<String, double>? serviziPrezzi,
    Map<String, double>? serviziPrezziAggiuntivi,
    Map<String, int>? maxAnimali,
    Map<String, String>? orariDisponibili,
    Map<String, String>? serviziNote,
    Map<String, String>? serviziDurata,
    Map<String, double>? serviziWeekendExtra,
    Map<String, double>? serviziTaxiPet,
    Map<String, String>? serviziCheckIn,
    Map<String, String>? serviziCheckOut,
    Map<String, List<String>>? serviziTaglie,
    Map<String, bool>? serviziWeekendAttivi,
    Map<String, bool>? serviziNotturnoAttivi,
    Map<String, double>? serviziNotturnoExtra,
    Map<String, bool>? serviziAsciugaturaAttivi,
    Map<String, bool>? serviziScontoAttivo,
    Map<String, double>? serviziScontoPerc,
    Map<String, int>? serviziScontoDal,
    String? tipoCasa,
    bool? giardino,
    List<String>? fotoCasa,
    List<String>? taglieAccettate,
    List<String>? razzeEscluse,
    List<String>? comportamentiEsclusi,
    bool? ambienteSicuro,
    String? percheSitter,
    String? cosaSpeciale,
    bool? disponibilitaNotte,
    double? rating,
    int? numeroRecensioni,
    String? citta,
    String? indirizzo,
    String? telefono,
    List<String>? fotoChiSei,
    bool? assenzaPrecedenti,
    bool? esperienzaProfessionale,
    List<dynamic>? certificazioni,
    List<String>? competenze,
    String? descrizioneEsperienza,
    String? quartiere,
    double? raggioKm,
    List<String>? giorniDisponibili,
    bool? altriAnimali,
    bool? bambini,
    double? lat,
    double? lng,
    String? regione,
    String? nazione,
    String? email,
    int? boardingDailyWalks,
    List<String>? boardingToiletOptions,
    String? boardingToiletFrequency,
    String? boardingHygieneDescription,
    List<String>? boardingSpecialNeeds,
    double? taxiBaseFare,
    double? taxiPricePerKm,
    double? taxiPricePerMin,
    double? taxiNightSurcharge,
    List<String>? taxiSpecieAccettate,
    double? taxiMaxDistance,
    List<String>? taxiTransportModes,
    Map<String, bool>? attrezzatura,
    String? attrezzaturaAltro,
    List<String>? serviziAttivi,
    String? username,
    String? geohash,
    String? stripeAccountId,
    bool? stripeOnboardingComplete,
    bool? prenotazioneLastMinute,
    bool? emailVerificata,
    bool? phoneVerificata,
  }) {
    return SitterProfile(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      bio: bio ?? this.bio,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      eta: eta ?? this.eta,
      verificato: verificato ?? this.verificato,
      etaVerificata: etaVerificata ?? this.etaVerificata,
      dataNascita: dataNascita ?? this.dataNascita,
      dataVerifica: dataVerifica ?? this.dataVerifica,
      metodoVerifica: metodoVerifica ?? this.metodoVerifica,
      anniEsperienza: anniEsperienza ?? this.anniEsperienza,
      specieEsperienza: specieEsperienza ?? this.specieEsperienza,
      bisogniSpeciali: bisogniSpeciali ?? this.bisogniSpeciali,
      somministrazioneFarmaci: somministrazioneFarmaci ?? this.somministrazioneFarmaci,
      gestioneAnimaliDifficili: gestioneAnimaliDifficili ?? this.gestioneAnimaliDifficili,
      serviziPrezzi: serviziPrezzi ?? this.serviziPrezzi,
      serviziPrezziAggiuntivi: serviziPrezziAggiuntivi ?? this.serviziPrezziAggiuntivi,
      maxAnimali: maxAnimali ?? this.maxAnimali,
      orariDisponibili: orariDisponibili ?? this.orariDisponibili,
      serviziNote: serviziNote ?? this.serviziNote,
      serviziDurata: serviziDurata ?? this.serviziDurata,
      serviziWeekendExtra: serviziWeekendExtra ?? this.serviziWeekendExtra,
      serviziTaxiPet: serviziTaxiPet ?? this.serviziTaxiPet,
      serviziCheckIn: serviziCheckIn ?? this.serviziCheckIn,
      serviziCheckOut: serviziCheckOut ?? this.serviziCheckOut,
      serviziTaglie: serviziTaglie ?? this.serviziTaglie,
      serviziWeekendAttivi: serviziWeekendAttivi ?? this.serviziWeekendAttivi,
      serviziNotturnoAttivi: serviziNotturnoAttivi ?? this.serviziNotturnoAttivi,
      serviziNotturnoExtra: serviziNotturnoExtra ?? this.serviziNotturnoExtra,
      serviziAsciugaturaAttivi: serviziAsciugaturaAttivi ?? this.serviziAsciugaturaAttivi,
      serviziScontoAttivo: serviziScontoAttivo ?? this.serviziScontoAttivo,
      serviziScontoPerc: serviziScontoPerc ?? this.serviziScontoPerc,
      serviziScontoDal: serviziScontoDal ?? this.serviziScontoDal,
      tipoCasa: tipoCasa ?? this.tipoCasa,
      giardino: giardino ?? this.giardino,
      fotoCasa: fotoCasa ?? this.fotoCasa,
      taglieAccettate: taglieAccettate ?? this.taglieAccettate,
      razzeEscluse: razzeEscluse ?? this.razzeEscluse,
      comportamentiEsclusi: comportamentiEsclusi ?? this.comportamentiEsclusi,
      ambienteSicuro: ambienteSicuro ?? this.ambienteSicuro,
      percheSitter: percheSitter ?? this.percheSitter,
      cosaSpeciale: cosaSpeciale ?? this.cosaSpeciale,
      disponibilitaNotte: disponibilitaNotte ?? this.disponibilitaNotte,
      rating: rating ?? this.rating,
      numeroRecensioni: numeroRecensioni ?? this.numeroRecensioni,
      citta: citta ?? this.citta,
      indirizzo: indirizzo ?? this.indirizzo,
      telefono: telefono ?? this.telefono,
      fotoChiSei: fotoChiSei ?? this.fotoChiSei,
      assenzaPrecedenti: assenzaPrecedenti ?? this.assenzaPrecedenti,
      esperienzaProfessionale: esperienzaProfessionale ?? this.esperienzaProfessionale,
      certificazioni: certificazioni ?? this.certificazioni,
      competenze: competenze ?? this.competenze,
      descrizioneEsperienza: descrizioneEsperienza ?? this.descrizioneEsperienza,
      quartiere: quartiere ?? this.quartiere,
      raggioKm: raggioKm ?? this.raggioKm,
      giorniDisponibili: giorniDisponibili ?? this.giorniDisponibili,
      altriAnimali: altriAnimali ?? this.altriAnimali,
      bambini: bambini ?? this.bambini,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      regione: regione ?? this.regione,
      nazione: nazione ?? this.nazione,
      email: email ?? this.email,
      boardingDailyWalks: boardingDailyWalks ?? this.boardingDailyWalks,
      boardingToiletOptions: boardingToiletOptions ?? this.boardingToiletOptions,
      boardingToiletFrequency: boardingToiletFrequency ?? this.boardingToiletFrequency,
      boardingHygieneDescription: boardingHygieneDescription ?? this.boardingHygieneDescription,
      boardingSpecialNeeds: boardingSpecialNeeds ?? this.boardingSpecialNeeds,
      taxiBaseFare: taxiBaseFare ?? this.taxiBaseFare,
      taxiPricePerKm: taxiPricePerKm ?? this.taxiPricePerKm,
      taxiPricePerMin: taxiPricePerMin ?? this.taxiPricePerMin,
      taxiNightSurcharge: taxiNightSurcharge ?? this.taxiNightSurcharge,
      taxiSpecieAccettate: taxiSpecieAccettate ?? this.taxiSpecieAccettate,
      taxiMaxDistance: taxiMaxDistance ?? this.taxiMaxDistance,
      taxiTransportModes: taxiTransportModes ?? this.taxiTransportModes,
      attrezzatura: attrezzatura ?? this.attrezzatura,
      attrezzaturaAltro: attrezzaturaAltro ?? this.attrezzaturaAltro,
      serviziAttivi: serviziAttivi ?? this.serviziAttivi,
      username: username ?? this.username,
      geohash: geohash ?? this.geohash,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      stripeOnboardingComplete: stripeOnboardingComplete ?? this.stripeOnboardingComplete,
      prenotazioneLastMinute: prenotazioneLastMinute ?? this.prenotazioneLastMinute,
      emailVerificata: emailVerificata ?? this.emailVerificata,
      phoneVerificata: phoneVerificata ?? this.phoneVerificata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nomeReal': nome,
      'cognomeReal': cognome,
      'eta': eta,
      'dataNascita': dataNascita,
      'verificato': verificato,
      'etaVerificata': etaVerificata,
      'timestampVerifica': dataVerifica != null ? Timestamp.fromDate(dataVerifica!) : FieldValue.serverTimestamp(),
      'metodoVerifica': metodoVerifica,
      'bio': bio,
      'fotoUrl': fotoUrl,
      'anniEsperienza': anniEsperienza,
      'specieEsperienza': specieEsperienza,
      'bisogniSpeciali': bisogniSpeciali,
      'somministrazioneFarmaci': somministrazioneFarmaci,
      'gestioneAnimaliDifficili': gestioneAnimaliDifficili,
      'serviziPrezzi': serviziPrezzi,
      'serviziPrezziAggiuntivi': serviziPrezziAggiuntivi,
      'maxAnimali': maxAnimali,
      'orariDisponibili': orariDisponibili,
      'serviziNote': serviziNote,
      'serviziDurata': serviziDurata,
      'serviziWeekendExtra': serviziWeekendExtra,
      'serviziTaxiPet': serviziTaxiPet,
      'serviziCheckIn': serviziCheckIn,
      'serviziCheckOut': serviziCheckOut,
      'serviziTaglie': serviziTaglie,
      'serviziWeekendAttivi': serviziWeekendAttivi,
      'serviziNotturnoAttivi': serviziNotturnoAttivi,
      'serviziNotturnoExtra': serviziNotturnoExtra,
      'serviziAsciugaturaAttivi': serviziAsciugaturaAttivi,
      'serviziScontoAttivo': serviziScontoAttivo,
      'serviziScontoPerc': serviziScontoPerc,
      'serviziScontoDal': serviziScontoDal,
      'tipoCasa': tipoCasa,
      'giardino': giardino,
      'fotoCasa': fotoCasa,
      'taglieAccettate': taglieAccettate,
      'razzeEscluse': razzeEscluse,
      'comportamentiEsclusi': comportamentiEsclusi,
      'ambienteSicuro': ambienteSicuro,
      'percheSitter': percheSitter,
      'cosaSpeciale': cosaSpeciale,
      'disponibilitaNotte': disponibilitaNotte,
      'rating': rating,
      'numeroRecensioni': numeroRecensioni,
      'citta': citta,
      'indirizzo': indirizzo,
      'regione': regione,
      'nazione': nazione,
      'telefono': telefono,
      'fotoChiSei': fotoChiSei,
      'assenzaPrecedenti': assenzaPrecedenti,
      'esperienzaProfessionale': esperienzaProfessionale,
      'certificazioni': certificazioni,
      'competenze': competenze,
      'descrizioneEsperienza': descrizioneEsperienza,
      'quartiere': quartiere,
      'raggioKm': raggioKm,
      'giorniDisponibili': giorniDisponibili,
      'altriAnimali': altriAnimali,
      'bambini': bambini,
      'lat': lat,
      'lng': lng,
      'email': email,
      'boardingDailyWalks': boardingDailyWalks,
      'boardingToiletOptions': boardingToiletOptions,
      'boardingToiletFrequency': boardingToiletFrequency,
      'boardingHygieneDescription': boardingHygieneDescription,
      'boardingSpecialNeeds': boardingSpecialNeeds,
      'taxiBaseFare': taxiBaseFare,
      'taxiPricePerKm': taxiPricePerKm,
      'taxiPricePerMin': taxiPricePerMin,
      'taxiNightSurcharge': taxiNightSurcharge,
      'taxiSpecieAccettate': taxiSpecieAccettate,
      'taxiMaxDistance': taxiMaxDistance,
      'taxiTransportModes': taxiTransportModes,
      'attrezzatura': attrezzatura,
      'attrezzaturaAltro': attrezzaturaAltro,
      'serviziAttivi': serviziAttivi,
      'username': username,
      'geohash': geohash,
      'stripeAccountId': stripeAccountId,
      'stripeOnboardingComplete': stripeOnboardingComplete,
      'prenotazioneLastMinute': prenotazioneLastMinute,
      'emailVerificata': emailVerificata,
      'phoneVerificata': phoneVerificata,
    };
  }

  factory SitterProfile.fromMap(Map<String, dynamic> data, String id) {
    return SitterProfile(
      uid: id,
      nome: data['nomeReal'] ?? '',
      cognome: data['cognomeReal'] ?? '',
      dataNascita: data['dataNascita'] ?? '',
      verificato: data['verificato'] ?? false,
      etaVerificata: data['etaVerificata'] ?? false,
      dataVerifica: (data['timestampVerifica'] as Timestamp?)?.toDate(),
      bio: data['bio'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      eta: data['eta'] ?? 0,
      anniEsperienza: data['anniEsperienza'] ?? 0,
      specieEsperienza: List<String>.from(data['specieEsperienza'] ?? []),
      bisogniSpeciali: data['bisogniSpeciali'] ?? false,
      somministrazioneFarmaci: data['somministrazioneFarmaci'] ?? false,
      gestioneAnimaliDifficili: data['gestioneAnimaliDifficili'] ?? false,
      serviziPrezzi: Map<String, double>.from(data['serviziPrezzi'] ?? {}),
      serviziPrezziAggiuntivi: Map<String, double>.from(data['serviziPrezziAggiuntivi'] ?? {}),
      maxAnimali: Map<String, int>.from(data['maxAnimali'] ?? {}),
      orariDisponibili: Map<String, String>.from(data['orariDisponibili'] ?? {}),
      serviziNote: Map<String, String>.from(data['serviziNote'] ?? {}),
      serviziDurata: Map<String, String>.from(data['serviziDurata'] ?? {}),
      serviziWeekendExtra: Map<String, double>.from(data['serviziWeekendExtra'] ?? {}),
      serviziTaxiPet: Map<String, double>.from(data['serviziTaxiPet'] ?? {}),
      serviziCheckIn: Map<String, String>.from(data['serviziCheckIn'] ?? {}),
      serviziCheckOut: Map<String, String>.from(data['serviziCheckOut'] ?? {}),
      serviziTaglie: (data['serviziTaglie'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, List<String>.from(v))) ?? {},
      serviziWeekendAttivi: Map<String, bool>.from(data['serviziWeekendAttivi'] ?? {}),
      serviziNotturnoAttivi: Map<String, bool>.from(data['serviziNotturnoAttivi'] ?? {}),
      serviziNotturnoExtra: Map<String, double>.from(data['serviziNotturnoExtra'] ?? {}),
      serviziAsciugaturaAttivi: Map<String, bool>.from(data['serviziAsciugaturaAttivi'] ?? {}),
      serviziScontoAttivo: Map<String, bool>.from(data['serviziScontoAttivo'] ?? {}),
      serviziScontoPerc: Map<String, double>.from(data['serviziScontoPerc'] ?? {}),
      serviziScontoDal: Map<String, int>.from(data['serviziScontoDal'] ?? {}),
      tipoCasa: data['tipoCasa'] ?? '',
      giardino: data['giardino'] ?? false,
      fotoCasa: List<String>.from(data['fotoCasa'] ?? []),
      taglieAccettate: List<String>.from(data['taglieAccettate'] ?? []),
      razzeEscluse: List<String>.from(data['razzeEscluse'] ?? []),
      comportamentiEsclusi: List<String>.from(data['comportamentiEsclusi'] ?? []),
      ambienteSicuro: data['ambienteSicuro'] ?? false,
      percheSitter: data['percheSitter'] ?? '',
      cosaSpeciale: data['cosaSpeciale'] ?? '',
      disponibilitaNotte: data['disponibilitaNotte'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      numeroRecensioni: data['numeroRecensioni'] ?? 0,
      citta: data['citta'] ?? '',
      indirizzo: data['indirizzo'] ?? '',
      regione: data['regione'] ?? '',
      nazione: data['nazione'] ?? '',
      telefono: data['telefono'] ?? '',
      fotoChiSei: List<String>.from(data['fotoChiSei'] ?? []),
      assenzaPrecedenti: data['assenzaPrecedenti'] ?? false,
      esperienzaProfessionale: data['esperienzaProfessionale'] ?? false,
      certificazioni: (data['certificazioni'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      competenze: List<String>.from(data['competenze'] ?? []),
      descrizioneEsperienza: data['descrizioneEsperienza'] ?? '',
      quartiere: data['quartiere'] ?? '',
      raggioKm: (data['raggioKm'] ?? 5.0).toDouble(),
      giorniDisponibili: List<String>.from(data['giorniDisponibili'] ?? []),
      altriAnimali: data['altriAnimali'] ?? false,
      bambini: data['bambini'] ?? false,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      email: data['email'] ?? '',
      boardingDailyWalks: data['boardingDailyWalks'] ?? 3,
      boardingToiletOptions: List<String>.from(data['boardingToiletOptions'] ?? []),
      boardingToiletFrequency: data['boardingToiletFrequency'] ?? 'Ogni 6 ore',
      boardingHygieneDescription: data['boardingHygieneDescription'] ?? '',
      boardingSpecialNeeds: List<String>.from(data['boardingSpecialNeeds'] ?? []),
      taxiBaseFare: (data['taxiBaseFare'] ?? 0.0).toDouble(),
      taxiPricePerKm: (data['taxiPricePerKm'] ?? 0.0).toDouble(),
      taxiPricePerMin: (data['taxiPricePerMin'] ?? 0.0).toDouble(),
      taxiNightSurcharge: (data['taxiNightSurcharge'] ?? 0.0).toDouble(),
      taxiSpecieAccettate: List<String>.from(data['taxiSpecieAccettate'] ?? []),
      taxiMaxDistance: (data['taxiMaxDistance'] ?? 0.0).toDouble(),
      taxiTransportModes: List<String>.from(data['taxiTransportModes'] ?? []),
      attrezzatura: Map<String, bool>.from(data['attrezzatura'] ?? {}),
      attrezzaturaAltro: data['attrezzaturaAltro'] ?? '',
      serviziAttivi: List<String>.from(data['serviziAttivi'] ?? []),
      username: data['username'] ?? data['nickname'] ?? '',
      geohash: data['geohash'] ?? '',
      stripeAccountId: data['stripeAccountId'],
      stripeOnboardingComplete: data['stripeOnboardingComplete'] ?? false,
      prenotazioneLastMinute: data['prenotazioneLastMinute'] ?? false,
      emailVerificata: data['emailVerificata'] ?? false,
      phoneVerificata: data['phoneVerificata'] ?? false,
    );
  }

  factory SitterProfile.fromFirestore(DocumentSnapshot doc) {
    return SitterProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
