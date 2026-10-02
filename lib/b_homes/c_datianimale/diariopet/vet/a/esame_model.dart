import 'package:hive/hive.dart';

part 'esame_model.g.dart';

@HiveType(typeId: 2)
class Esame {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoria;

  @HiveField(2)
  final String titolo;

  @HiveField(3)
  final String descrizione;

  @HiveField(4)
  final String data;

  @HiveField(5)
  final String ora;

  // Modificati per supportare liste di file
  @HiveField(6)
  final List<String> fileUrls; 

  @HiveField(7)
  final List<String> tipiFile; 

  @HiveField(8)
  final List<int> dimensioniFile; 

  @HiveField(9)
  final String? valore;

  @HiveField(10)
  final String? unita;

  @HiveField(11)
  final String? range;

  @HiveField(12)
  final String? autore;

  @HiveField(13)
  final List<String>? tags;

  @HiveField(14)
  final int commentiCount;

  Esame({
    required this.id,
    required this.categoria,
    required this.titolo,
    required this.descrizione,
    required this.data,
    required this.ora,
    required this.fileUrls,
    required this.tipiFile,
    required this.dimensioniFile,
    this.valore,
    this.unita,
    this.range,
    this.autore,
    this.tags,
    this.commentiCount = 0,
  });
}
