import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryCardUser {
  final String uid;
  final String email;
  final String nome;
  final String cognome;
  final String dataNascita;
  final String telefono;
  final String nazione;
  final String regione;
  final String citta;
  final String indirizzo;
  final String immagine;
  final Map<String, bool> visibilita;
  final DateTime? creatoIl;

  MemoryCardUser({
    required this.uid,
    required this.email,
    required this.nome,
    required this.cognome,
    required this.dataNascita,
    required this.telefono,
    required this.nazione,
    required this.regione,
    required this.citta,
    required this.indirizzo,
    required this.immagine,
    required this.visibilita,
    required this.creatoIl,
  });

  factory MemoryCardUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return MemoryCardUser(
      uid: uid,
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      cognome: data['cognome'] ?? '',
      dataNascita: data['dataNascita'] ?? '',
      telefono: data['telefono'] ?? '',
      nazione: data['nazione'] ?? '',
      regione: data['regione'] ?? '',
      citta: data['citta'] ?? '',
      indirizzo: data['indirizzo'] ?? '',
      immagine: data['fotoUrl'] ?? '',
      visibilita: Map<String, bool>.from(data['visibilita'] ?? {}),
      creatoIl: (data['creato_il'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'cognome': cognome,
      'dataNascita': dataNascita,
      'telefono': telefono,
      'nazione': nazione,
      'regione': regione,
      'citta': citta,
      'indirizzo': indirizzo,
      'fotoUrl': immagine,
      'visibilita': visibilita,
      'creato_il': creatoIl != null ? Timestamp.fromDate(creatoIl!) : FieldValue.serverTimestamp(),
    };
  }

  static Future<MemoryCardUser?> getUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return MemoryCardUser.fromFirestore(uid, doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Errore nel recupero dati utente: $e');
      return null;
    }
  }

  Future<void> save() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(toMap());
    } catch (e) {
      print('Errore nel salvataggio dati utente: $e');
    }
  }
}