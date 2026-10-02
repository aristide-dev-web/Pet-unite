// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sitter_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SitterProfileAdapter extends TypeAdapter<SitterProfile> {
  @override
  final int typeId = 7;

  @override
  SitterProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SitterProfile(
      uid: fields[0] as String,
      nome: fields[1] as String,
      cognome: fields[2] as String,
      bio: fields[3] as String,
      fotoUrl: fields[4] as String,
      eta: fields[5] as int,
      verificato: fields[6] as bool,
      etaVerificata: fields[7] as bool,
      dataNascita: fields[8] as String,
      dataVerifica: fields[9] as DateTime?,
      metodoVerifica: fields[10] as String,
      anniEsperienza: fields[11] as int,
      specieEsperienza: (fields[12] as List).cast<String>(),
      bisogniSpeciali: fields[13] as bool,
      somministrazioneFarmaci: fields[14] as bool,
      gestioneAnimaliDifficili: fields[15] as bool,
      serviziPrezzi: (fields[16] as Map).cast<String, double>(),
      serviziPrezziAggiuntivi: (fields[45] as Map).cast<String, double>(),
      maxAnimali: (fields[17] as Map).cast<String, int>(),
      orariDisponibili: (fields[18] as Map).cast<String, String>(),
      serviziNote: (fields[46] as Map).cast<String, String>(),
      serviziDurata: (fields[47] as Map).cast<String, String>(),
      serviziWeekendExtra: (fields[48] as Map).cast<String, double>(),
      serviziTaxiPet: (fields[49] as Map).cast<String, double>(),
      serviziCheckIn: (fields[50] as Map).cast<String, String>(),
      serviziCheckOut: (fields[51] as Map).cast<String, String>(),
      serviziTaglie: (fields[52] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<String>())),
      serviziWeekendAttivi: (fields[53] as Map).cast<String, bool>(),
      serviziNotturnoAttivi: (fields[54] as Map).cast<String, bool>(),
      serviziNotturnoExtra: (fields[55] as Map).cast<String, double>(),
      serviziAsciugaturaAttivi: (fields[56] as Map).cast<String, bool>(),
      serviziScontoAttivo: (fields[57] as Map).cast<String, bool>(),
      serviziScontoPerc: (fields[58] as Map).cast<String, double>(),
      serviziScontoDal: (fields[59] as Map).cast<String, int>(),
      tipoCasa: fields[19] as String,
      giardino: fields[20] as bool,
      fotoCasa: (fields[21] as List).cast<String>(),
      taglieAccettate: (fields[22] as List).cast<String>(),
      razzeEscluse: (fields[23] as List).cast<String>(),
      comportamentiEsclusi: (fields[60] as List).cast<String>(),
      ambienteSicuro: fields[61] as bool,
      percheSitter: fields[62] as String,
      cosaSpeciale: fields[63] as String,
      disponibilitaNotte: fields[24] as bool,
      rating: fields[25] as double,
      numeroRecensioni: fields[26] as int,
      citta: fields[27] as String,
      indirizzo: fields[28] as String,
      telefono: fields[29] as String,
      fotoChiSei: (fields[30] as List).cast<String>(),
      assenzaPrecedenti: fields[31] as bool,
      esperienzaProfessionale: fields[32] as bool,
      certificazioni: (fields[33] as List).cast<dynamic>(),
      competenze: (fields[34] as List).cast<String>(),
      descrizioneEsperienza: fields[35] as String,
      quartiere: fields[36] as String,
      raggioKm: fields[37] as double,
      giorniDisponibili: (fields[38] as List).cast<String>(),
      altriAnimali: fields[39] as bool,
      bambini: fields[40] as bool,
      lat: fields[41] as double?,
      lng: fields[42] as double?,
      regione: fields[43] as String,
      nazione: fields[44] as String,
      email: fields[64] as String,
      boardingDailyWalks: fields[65] as int,
      boardingToiletOptions: (fields[66] as List).cast<String>(),
      boardingToiletFrequency: fields[67] as String,
      boardingHygieneDescription: fields[68] as String,
      boardingSpecialNeeds: (fields[69] as List).cast<String>(),
      taxiBaseFare: fields[70] as double,
      taxiPricePerKm: fields[71] as double,
      taxiPricePerMin: fields[78] as double,
      taxiNightSurcharge: fields[79] as double,
      taxiSpecieAccettate: (fields[72] as List).cast<String>(),
      taxiMaxDistance: fields[73] as double,
      taxiTransportModes: (fields[80] as List).cast<String>(),
      attrezzatura: (fields[74] as Map).cast<String, bool>(),
      attrezzaturaAltro: fields[75] as String,
      serviziAttivi: (fields[76] as List).cast<String>(),
      username: fields[77] as String,
      geohash: fields[81] as String,
      stripeAccountId: fields[82] as String?,
      stripeOnboardingComplete: fields[83] as bool,
      prenotazioneLastMinute: fields[84] as bool,
      emailVerificata: fields[85] as bool,
      phoneVerificata: fields[86] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SitterProfile obj) {
    writer
      ..writeByte(87)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.cognome)
      ..writeByte(3)
      ..write(obj.bio)
      ..writeByte(4)
      ..write(obj.fotoUrl)
      ..writeByte(5)
      ..write(obj.eta)
      ..writeByte(6)
      ..write(obj.verificato)
      ..writeByte(7)
      ..write(obj.etaVerificata)
      ..writeByte(8)
      ..write(obj.dataNascita)
      ..writeByte(9)
      ..write(obj.dataVerifica)
      ..writeByte(10)
      ..write(obj.metodoVerifica)
      ..writeByte(11)
      ..write(obj.anniEsperienza)
      ..writeByte(12)
      ..write(obj.specieEsperienza)
      ..writeByte(13)
      ..write(obj.bisogniSpeciali)
      ..writeByte(14)
      ..write(obj.somministrazioneFarmaci)
      ..writeByte(15)
      ..write(obj.gestioneAnimaliDifficili)
      ..writeByte(16)
      ..write(obj.serviziPrezzi)
      ..writeByte(17)
      ..write(obj.maxAnimali)
      ..writeByte(18)
      ..write(obj.orariDisponibili)
      ..writeByte(19)
      ..write(obj.tipoCasa)
      ..writeByte(20)
      ..write(obj.giardino)
      ..writeByte(21)
      ..write(obj.fotoCasa)
      ..writeByte(22)
      ..write(obj.taglieAccettate)
      ..writeByte(23)
      ..write(obj.razzeEscluse)
      ..writeByte(24)
      ..write(obj.disponibilitaNotte)
      ..writeByte(25)
      ..write(obj.rating)
      ..writeByte(26)
      ..write(obj.numeroRecensioni)
      ..writeByte(27)
      ..write(obj.citta)
      ..writeByte(28)
      ..write(obj.indirizzo)
      ..writeByte(29)
      ..write(obj.telefono)
      ..writeByte(30)
      ..write(obj.fotoChiSei)
      ..writeByte(31)
      ..write(obj.assenzaPrecedenti)
      ..writeByte(32)
      ..write(obj.esperienzaProfessionale)
      ..writeByte(33)
      ..write(obj.certificazioni)
      ..writeByte(34)
      ..write(obj.competenze)
      ..writeByte(35)
      ..write(obj.descrizioneEsperienza)
      ..writeByte(36)
      ..write(obj.quartiere)
      ..writeByte(37)
      ..write(obj.raggioKm)
      ..writeByte(38)
      ..write(obj.giorniDisponibili)
      ..writeByte(39)
      ..write(obj.altriAnimali)
      ..writeByte(40)
      ..write(obj.bambini)
      ..writeByte(41)
      ..write(obj.lat)
      ..writeByte(42)
      ..write(obj.lng)
      ..writeByte(43)
      ..write(obj.regione)
      ..writeByte(44)
      ..write(obj.nazione)
      ..writeByte(45)
      ..write(obj.serviziPrezziAggiuntivi)
      ..writeByte(46)
      ..write(obj.serviziNote)
      ..writeByte(47)
      ..write(obj.serviziDurata)
      ..writeByte(48)
      ..write(obj.serviziWeekendExtra)
      ..writeByte(49)
      ..write(obj.serviziTaxiPet)
      ..writeByte(50)
      ..write(obj.serviziCheckIn)
      ..writeByte(51)
      ..write(obj.serviziCheckOut)
      ..writeByte(52)
      ..write(obj.serviziTaglie)
      ..writeByte(53)
      ..write(obj.serviziWeekendAttivi)
      ..writeByte(54)
      ..write(obj.serviziNotturnoAttivi)
      ..writeByte(55)
      ..write(obj.serviziNotturnoExtra)
      ..writeByte(56)
      ..write(obj.serviziAsciugaturaAttivi)
      ..writeByte(57)
      ..write(obj.serviziScontoAttivo)
      ..writeByte(58)
      ..write(obj.serviziScontoPerc)
      ..writeByte(59)
      ..write(obj.serviziScontoDal)
      ..writeByte(60)
      ..write(obj.comportamentiEsclusi)
      ..writeByte(61)
      ..write(obj.ambienteSicuro)
      ..writeByte(62)
      ..write(obj.percheSitter)
      ..writeByte(63)
      ..write(obj.cosaSpeciale)
      ..writeByte(64)
      ..write(obj.email)
      ..writeByte(65)
      ..write(obj.boardingDailyWalks)
      ..writeByte(66)
      ..write(obj.boardingToiletOptions)
      ..writeByte(67)
      ..write(obj.boardingToiletFrequency)
      ..writeByte(68)
      ..write(obj.boardingHygieneDescription)
      ..writeByte(69)
      ..write(obj.boardingSpecialNeeds)
      ..writeByte(70)
      ..write(obj.taxiBaseFare)
      ..writeByte(71)
      ..write(obj.taxiPricePerKm)
      ..writeByte(72)
      ..write(obj.taxiSpecieAccettate)
      ..writeByte(73)
      ..write(obj.taxiMaxDistance)
      ..writeByte(78)
      ..write(obj.taxiPricePerMin)
      ..writeByte(79)
      ..write(obj.taxiNightSurcharge)
      ..writeByte(80)
      ..write(obj.taxiTransportModes)
      ..writeByte(74)
      ..write(obj.attrezzatura)
      ..writeByte(75)
      ..write(obj.attrezzaturaAltro)
      ..writeByte(76)
      ..write(obj.serviziAttivi)
      ..writeByte(77)
      ..write(obj.username)
      ..writeByte(81)
      ..write(obj.geohash)
      ..writeByte(82)
      ..write(obj.stripeAccountId)
      ..writeByte(83)
      ..write(obj.stripeOnboardingComplete)
      ..writeByte(84)
      ..write(obj.prenotazioneLastMinute)
      ..writeByte(85)
      ..write(obj.emailVerificata)
      ..writeByte(86)
      ..write(obj.phoneVerificata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SitterProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
