import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

part 'back_diario.g.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

// Nome del box Hive per gli animali
const String animaliBoxName = 'animali_box';

/// Funzione per sincronizzare Firestore con Hive in tempo reale.
void sincronizzaAnimaliConHive() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  _db.collection('animali')
    .where('userId', isEqualTo: user.uid)
    .snapshots()
    .listen((snapshot) async {
    var box = await Hive.openBox<Animale>(animaliBoxName);
    
    for (var change in snapshot.docChanges) {
      final doc = change.doc;
      
      if (change.type == DocumentChangeType.removed) {
        await box.delete(doc.id);
      } else {
        final animale = Animale.fromFirestore(doc);
        await box.put(doc.id, animale);
      }
    }
  });
}

void ascoltaSingoloAnimale(String animaleId) {
  _db.collection('animali').doc(animaleId).snapshots().listen((doc) async {
    if (doc.exists) {
      var box = await Hive.openBox<Animale>(animaliBoxName);
      await box.put(doc.id, Animale.fromFirestore(doc));
    }
  });
}

Future<void> eliminaAnimale(String animaleId) async {
  try {
    await _db.collection('animali').doc(animaleId).delete();
    var box = await Hive.openBox<Animale>(animaliBoxName);
    await box.delete(animaleId);
  } catch (e) {
    rethrow;
  }
}

@HiveType(typeId: 3)
class Animale extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String nome;
  @HiveField(2) final String tipo;
  @HiveField(3) final String razza;
  @HiveField(4) final String sesso;
  @HiveField(5) final String day;
  @HiveField(6) final String month;
  @HiveField(7) final String year;
  @HiveField(8) final String coloreDominante;
  @HiveField(9) final String coloreSecondario;
  @HiveField(10) final String coloreTerziario;
  @HiveField(11) final String peloGrandezza;
  @HiveField(12) final String peloTipo;
  @HiveField(13) final String codaGrandezza;
  @HiveField(14) final String codaTipo;
  @HiveField(15) final String orecchieGrandezza;
  @HiveField(16) final String orecchieTipo;
  @HiveField(17) final String occhiColore;
  @HiveField(18) final String occhiForma;
  @HiveField(19) final String taglia;
  @HiveField(20) final String microchip;
  @HiveField(21) final String microchipNumero;
  @HiveField(22) final String vaccinato;
  @HiveField(23) final String riproduttivo;
  @HiveField(24) final String iperteso; 
  @HiveField(25) final String allergico;
  @HiveField(26) final String allergie;
  @HiveField(27) final String passaporto;
  @HiveField(28) final String passaportoNumero;
  @HiveField(29) final String passaportoNote;
  @HiveField(30) final String noteGenerali;
  @HiveField(31) final String? fotoUrl;
  @HiveField(32) final String peso;
  @HiveField(33) final String fegato;
  @HiveField(34) final List<String> fotoPassaportoUrls;

  Animale({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.razza,
    required this.sesso,
    required this.day,
    required this.month,
    required this.year,
    required this.coloreDominante,
    required this.coloreSecondario,
    required this.coloreTerziario,
    required this.peloGrandezza,
    required this.peloTipo,
    required this.codaGrandezza,
    required this.codaTipo,
    required this.orecchieGrandezza,
    required this.orecchieTipo,
    required this.occhiColore,
    required this.occhiForma,
    required this.taglia,
    required this.microchip,
    required this.microchipNumero,
    required this.vaccinato,
    required this.riproduttivo,
    this.iperteso = "No",
    required this.allergico,
    required this.allergie,
    required this.passaporto,
    required this.passaportoNumero,
    required this.passaportoNote,
    required this.noteGenerali,
    this.fotoUrl,
    this.peso = "",
    this.fegato = "",
    this.fotoPassaportoUrls = const [],
  });

  factory Animale.fromMap(Map<String, dynamic> data, String id) {
    String d = data['day'] ?? '';
    String m = data['month'] ?? '';
    String y = data['year'] ?? '';
    final dataNascita = data['dataNascita']?.toString() ?? '';
    if (dataNascita.contains('-')) {
      final parti = dataNascita.split('-');
      if (parti.length == 3) {
        y = parti[0]; m = parti[1]; d = parti[2];
      }
    }
    return Animale(
      id: id,
      nome: data['nome'] ?? '',
      tipo: data['tipo'] ?? '',
      razza: data['razza'] ?? '',
      sesso: data['sesso'] ?? '',
      day: d, month: m, year: y,
      coloreDominante: data['coloreDominante'] ?? '',
      coloreSecondario: data['coloreSecondario'] ?? '',
      coloreTerziario: data['coloreTerziario'] ?? '',
      peloGrandezza: data['peloGrandezza'] ?? '',
      peloTipo: data['peloTipo'] ?? '',
      codaGrandezza: data['codaGrandezza'] ?? '',
      codaTipo: data['codaTipo'] ?? '',
      orecchieGrandezza: data['orecchieGrandezza'] ?? '',
      orecchieTipo: data['orecchieTipo'] ?? '',
      occhiColore: data['occhiColore'] ?? '',
      occhiForma: data['occhiForma'] ?? '',
      taglia: data['taglia'] ?? '',
      microchip: data['microchip'] ?? '',
      microchipNumero: data['microchipNumero'] ?? '',
      vaccinato: data['vaccinato'] ?? '',
      riproduttivo: data['riproduttivo'] ?? '',
      iperteso: data['iperteso'] ?? 'No',
      allergico: data['allergico'] ?? '',
      allergie: data['allergie'] ?? '',
      passaporto: data['passaporto'] ?? '',
      passaportoNumero: data['passaportoNumero'] ?? '',
      passaportoNote: data['passaportoNote'] ?? '',
      noteGenerali: data['noteGenerali'] ?? '',
      fotoUrl: data['fotoUrl'],
      peso: data['peso'] ?? '',
      fegato: data['fegato'] ?? '',
      fotoPassaportoUrls: List<String>.from(data['fotoPassaportoUrls'] ?? []),
    );
  }

  factory Animale.fromFirestore(DocumentSnapshot doc) {
    return Animale.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome, 'tipo': tipo, 'razza': razza, 'sesso': sesso,
      'day': day, 'month': month, 'year': year,
      'coloreDominante': coloreDominante, 'coloreSecondario': coloreSecondario, 'coloreTerziario': coloreTerziario,
      'peloGrandezza': peloGrandezza, 'peloTipo': peloTipo, 'codaGrandezza': codaGrandezza, 'codaTipo': codaTipo,
      'orecchieGrandezza': orecchieGrandezza, 'orecchieTipo': orecchieTipo, 'occhiColore': occhiColore, 'occhiForma': occhiForma,
      'taglia': taglia, 'microchip': microchip, 'microchipNumero': microchipNumero, 'vaccinato': vaccinato,
      'riproduttivo': riproduttivo, 'iperteso': iperteso, 'allergico': allergico, 'allergie': allergie,
      'passaporto': passaporto, 'passaportoNumero': passaportoNumero, 'passaportoNote': passaportoNote,
      'noteGenerali': noteGenerali, 'fotoUrl': fotoUrl,
      'peso': peso, 'fegato': fegato,
      'fotoPassaportoUrls': fotoPassaportoUrls,
    };
  }
}
