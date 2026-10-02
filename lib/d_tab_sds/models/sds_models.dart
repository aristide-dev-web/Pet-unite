import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'sds_models.g.dart';

/// Utility per convertire i tipi non supportati da Hive (Timestamp, GeoPoint) in tipi standard
Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
  final Map<String, dynamic> sanitized = Map.from(data);
  sanitized.forEach((key, value) {
    if (value is Timestamp) {
      sanitized[key] = value.toDate();
    } else if (value is GeoPoint) {
      // Convertiamo GeoPoint in una mappa semplice {lat, lng}
      sanitized[key] = {'latitude': value.latitude, 'longitude': value.longitude};
    } else if (value is Map<String, dynamic>) {
      sanitized[key] = _sanitizeData(value);
    } else if (value is List) {
      sanitized[key] = value.map((e) {
        if (e is Timestamp) return e.toDate();
        if (e is GeoPoint) return {'latitude': e.latitude, 'longitude': e.longitude};
        if (e is Map<String, dynamic>) return _sanitizeData(e);
        return e;
      }).toList();
    }
  });
  return sanitized;
}

@HiveType(typeId: 11)
class LostAnimal extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String nome;
  @HiveField(2) final String tipo;
  @HiveField(3) final String razza;
  @HiveField(4) final String sesso;
  @HiveField(5) final List<String> immagini;
  @HiveField(6) final String? ricompensa;
  @HiveField(7) final bool haCicatrici;
  @HiveField(8) final String uidUtente;
  @HiveField(9) final String via;
  @HiveField(10) final String citta;
  @HiveField(11) final String? dataSmarrimento;
  @HiveField(12) final double? lat;
  @HiveField(13) final double? lng;
  @HiveField(14) final DateTime? timestamp;
  @HiveField(15) final Map<String, dynamic> rawData;

  LostAnimal({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.razza,
    required this.sesso,
    required this.immagini,
    this.ricompensa,
    required this.haCicatrici,
    required this.uidUtente,
    required this.via,
    required this.citta,
    this.dataSmarrimento,
    this.lat,
    this.lng,
    this.timestamp,
    required this.rawData,
  });

  factory LostAnimal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LostAnimal(
      id: doc.id,
      nome: data['nome'] ?? 'Sconosciuto',
      tipo: data['tipo'] ?? data['specie'] ?? '',
      razza: data['razza'] ?? '',
      sesso: data['sesso'] ?? '',
      immagini: List<String>.from(data['immagini'] ?? (data['immagine'] != null ? [data['immagine']] : [])),
      ricompensa: data['ricompensa']?.toString(),
      haCicatrici: data['haCicatrici'] ?? data['ha_cicatrici'] ?? false,
      uidUtente: data['uid_utente'] ?? '',
      via: data['via'] ?? '',
      citta: data['citta'] ?? '',
      dataSmarrimento: data['dataSmarrimento'] ?? data['data_smarrimento'],
      lat: (data['lat'] ?? data['latitude'])?.toDouble(),
      lng: (data['lng'] ?? data['longitude'])?.toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      rawData: _sanitizeData(data), // PULIZIA QUI
    );
  }
}

@HiveType(typeId: 12)
class CustodiaAnimal extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String nome;
  @HiveField(2) final String tipo;
  @HiveField(3) final String razza;
  @HiveField(4) final String sesso;
  @HiveField(5) final List<String> immagini;
  @HiveField(6) final bool haCicatrici;
  @HiveField(7) final String uidUtente;
  @HiveField(8) final String via;
  @HiveField(9) final String citta;
  @HiveField(10) final double? lat;
  @HiveField(11) final double? lng;
  @HiveField(12) final DateTime? timestamp;
  @HiveField(13) final Map<String, dynamic> rawData;

  CustodiaAnimal({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.razza,
    required this.sesso,
    required this.immagini,
    required this.haCicatrici,
    required this.uidUtente,
    required this.via,
    required this.citta,
    this.lat,
    this.lng,
    this.timestamp,
    required this.rawData,
  });

  factory CustodiaAnimal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustodiaAnimal(
      id: doc.id,
      nome: data['nome'] ?? 'Sconosciuto',
      tipo: data['tipo'] ?? data['specie'] ?? '',
      razza: data['razza'] ?? '',
      sesso: data['sesso'] ?? '',
      immagini: List<String>.from(data['immagini'] ?? (data['immagine'] != null ? [data['immagine']] : [])),
      haCicatrici: data['haCicatrici'] ?? false,
      uidUtente: data['uid_utente'] ?? '',
      via: data['via'] ?? '',
      citta: data['citta'] ?? '',
      lat: (data['lat'] ?? data['latitude'])?.toDouble(),
      lng: (data['lng'] ?? data['longitude'])?.toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      rawData: _sanitizeData(data), // PULIZIA QUI
    );
  }
}

@HiveType(typeId: 13)
class AdozioneAnimal extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String nome;
  @HiveField(2) final String tipo;
  @HiveField(3) final String razza;
  @HiveField(4) final String sesso;
  @HiveField(5) final List<String> immagini;
  @HiveField(6) final String? eta;
  @HiveField(7) final bool vaccinato;
  @HiveField(8) final bool castrato;
  @HiveField(9) final String uidUtente;
  @HiveField(10) final String via;
  @HiveField(11) final String citta;
  @HiveField(12) final double? lat;
  @HiveField(13) final double? lng;
  @HiveField(14) final DateTime? timestamp;
  @HiveField(15) final Map<String, dynamic> rawData;

  AdozioneAnimal({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.razza,
    required this.sesso,
    required this.immagini,
    this.eta,
    required this.vaccinato,
    required this.castrato,
    required this.uidUtente,
    required this.via,
    required this.citta,
    this.lat,
    this.lng,
    this.timestamp,
    required this.rawData,
  });

  factory AdozioneAnimal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdozioneAnimal(
      id: doc.id,
      nome: data['nome'] ?? 'Cucciolo',
      tipo: data['specie'] ?? data['tipo'] ?? '',
      razza: data['razza'] ?? '',
      sesso: data['sesso'] ?? '',
      immagini: List<String>.from(data['immagini'] ?? (data['immagine'] != null ? [data['immagine']] : [])),
      eta: data['eta'],
      vaccinato: data['vaccinato'] ?? false,
      castrato: data['castrato'] ?? false,
      uidUtente: data['uid_utente'] ?? '',
      via: data['via'] ?? '',
      citta: data['citta'] ?? '',
      lat: (data['lat'] ?? data['latitude'])?.toDouble(),
      lng: (data['lng'] ?? data['longitude'])?.toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      rawData: _sanitizeData(data), // PULIZIA QUI
    );
  }
}
