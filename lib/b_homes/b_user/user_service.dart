import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ritorna lo Stream dei dati utente (Real-time)
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('utenti').doc(userId).snapshots();
  }

  // Funzione per controllare se un dato è visibile (Logica Privacy)
  bool isFieldVisible(Map<String, dynamic> publicData, String fieldName) {
    final visibilita = Map<String, dynamic>.from(publicData['visibilita'] ?? {});
    return visibilita[fieldName] == true;
  }

// Qui puoi aggiungere altre logiche "invisibili" all'utente...
}