import 'package:petping/tipologie/dog.dart';
import 'package:petping/tipologie/cat.dart';
import 'package:petping/tipologie/rabit.dart';
import 'package:petping/tipologie/hamster.dart';
import 'package:petping/tipologie/tartle.dart';
import 'package:petping/tipologie/cavallo.dart';
import 'package:petping/tipologie/serpente.dart';
import 'package:petping/tipologie/ragno.dart';

final Map<String, List<String>> razzePerSpecie = {
  'Cane': razzeCani,
  'Gatto': razzeGatti,
  'Coniglio': razzeConigli,
  'Criceto': razzeCriceti,
  'Tartaruga': razzeTartarughe,
  'Cavallo': razzeCavalli,
  'Serpente': razzeSerpenti,
  'Ragno': razzeRagni,
};

final List<String> specieSenzaRazze = [
  'Uccello',
  'Pappagallo',
  'Furetto',
  'Porcellino d\'India',
  'Topo',
  'Capra',
  'Maiale',
  'Gallina',
  'Anatra',
  'Oca',
  'Riccio',
  'Scoiattolo',
  'Volpe',
  'Pipistrello',
  'Iguana',
  'Pitone',
  'Camaleonte',
  'Scimmia',
  'Cervo',
  'Lupo',
  'Tucano',
  'Fenicottero',
  'Pinguino',
  'Coccodrillo',
  'Zebra',
  'Giraffa',
  'Elefante',
  'Tigre',
  'Leone',
  'Orso',
  'Canguro',
  'Lemure',
  'Pesce',
];

List<String> get allTipiOrdinati {
  // 'Generale' è ora la prima categoria per tutti
  final preferred = ['Generale', 'Cane', 'Gatto', 'Coniglio', 'Criceto'];
  final others = [...razzePerSpecie.keys, ...specieSenzaRazze]
    ..removeWhere((e) => preferred.contains(e))
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [...preferred, ...others];
}
