import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 10)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String nome;
  @HiveField(3)
  final String cognome;
  @HiveField(4)
  final String bio;
  @HiveField(5)
  final String dataNascita;
  @HiveField(6)
  final String sesso;
  @HiveField(7)
  final String fotoUrl;
  
  @HiveField(8)
  final List<String> emails;
  @HiveField(9)
  final List<String> telefoni;
  @HiveField(10)
  final List<String> whatsapp;

  @HiveField(11)
  final String nazione;
  @HiveField(12)
  final String regione;
  @HiveField(13)
  final String citta;
  @HiveField(14)
  final String indirizzo;
  @HiveField(15)
  final double? lat;
  @HiveField(16)
  final double? lng;

  @HiveField(17)
  final Map<String, bool> visibilita;
  
  @HiveField(18)
  final bool isPetSitter;

  @HiveField(19)
  final String quartiere; // ✅ NUOVO CAMPO UNIFICATO

  @HiveField(20)
  final bool isAdmin;

  UserProfile({
    required this.uid,
    this.username = '',
    this.nome = '',
    this.cognome = '',
    this.bio = '',
    this.dataNascita = '',
    this.sesso = 'Non specificato',
    this.fotoUrl = '',
    this.emails = const [],
    this.telefoni = const [],
    this.whatsapp = const [],
    this.nazione = '',
    this.regione = '',
    this.citta = '',
    this.indirizzo = '',
    this.lat,
    this.lng,
    this.visibilita = const {},
    this.isPetSitter = false,
    this.quartiere = '',
    this.isAdmin = false,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String id) {
    return UserProfile(
      uid: id,
      username: data['username'] ?? '',
      nome: data['nome'] ?? '',
      cognome: data['cognome'] ?? '',
      bio: data['bio'] ?? '',
      dataNascita: data['dataNascita'] ?? '',
      sesso: data['sesso'] ?? 'Non specificato',
      fotoUrl: data['fotoUrl'] ?? '',
      emails: List<String>.from(data['emails'] ?? []),
      telefoni: List<String>.from(data['telefoni'] ?? []),
      whatsapp: List<String>.from(data['whatsapp'] ?? []),
      nazione: data['nazione'] ?? '',
      regione: data['regione'] ?? '',
      citta: data['citta'] ?? '',
      indirizzo: data['indirizzo'] ?? '',
      quartiere: data['quartiere'] ?? '',
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      visibilita: Map<String, bool>.from(data['visibilita'] ?? {}),
      isPetSitter: data['isPetSitter'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'nome': nome,
      'cognome': cognome,
      'bio': bio,
      'dataNascita': dataNascita,
      'sesso': sesso,
      'fotoUrl': fotoUrl,
      'emails': emails,
      'telefoni': telefoni,
      'whatsapp': whatsapp,
      'nazione': nazione,
      'regione': regione,
      'citta': citta,
      'indirizzo': indirizzo,
      'quartiere': quartiere,
      'lat': lat,
      'lng': lng,
      'visibilita': visibilita,
      'isPetSitter': isPetSitter,
      'isAdmin': isAdmin,
    };
  }
}
