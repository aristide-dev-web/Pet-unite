import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petping/utils/geo_service.dart';
import 'package:petping/d_tab_sds/custodia_animali/a/front_home_custodia.dart';
import 'package:petping/d_tab_sds/models/sds_models.dart';
import 'package:petping/d_tab_sds/services/sds_cache_service.dart';

class CustodiaHome extends StatefulWidget {
  final VoidCallback? onBack;
  const CustodiaHome({super.key, this.onBack});

  @override
  State<CustodiaHome> createState() => _CustodiaHomeState();
}

class _CustodiaHomeState extends State<CustodiaHome> {
  String? selectedSpecies;
  String? filterSesso;
  bool? filterCicatrici;
  Position? userPosition;
  
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController razzaController = TextEditingController();
  final TextEditingController coloreDomController = TextEditingController();
  final TextEditingController coloreSecController = TextEditingController();
  final TextEditingController occhiColoreController = TextEditingController();
  final TextEditingController orecchieController = TextEditingController();
  final TextEditingController codaController = TextEditingController();
  final TextEditingController microchipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final pos = await GeoService.getCurrentLocation();
    if (mounted) setState(() => userPosition = pos);
  }

  @override
  void dispose() {
    nomeController.dispose();
    razzaController.dispose();
    coloreDomController.dispose();
    coloreSecController.dispose();
    occhiColoreController.dispose();
    orecchieController.dispose();
    codaController.dispose();
    microchipController.dispose();
    super.dispose();
  }

  int _calculateSearchAffinity(Map<String, dynamic> pet) {
    int score = 0;
    if (nomeController.text.isNotEmpty && (pet['nome']?.toString().toLowerCase() ?? '').contains(nomeController.text.toLowerCase())) score += 200;
    if (filterCicatrici != null && pet['haCicatrici'] == filterCicatrici && filterCicatrici == true) score += 200;
    if (razzaController.text.isNotEmpty) {
      String search = razzaController.text.toLowerCase();
      String petRazza = (pet['razza'] ?? '').toString().toLowerCase();
      if (petRazza == search) score += 150;
      else if (petRazza.contains(search)) score += 80;
    }
    final petDom = pet['coloreDominante'];
    final petSec = pet['coloreSecondario'];
    if (coloreDomController.text.isNotEmpty) {
      if (petDom == coloreDomController.text) score += 100;
      else if (petSec == coloreDomController.text) score += 40;
    }
    score += _proximityScore(pet['orecchieGrandezza'], orecchieController.text, 40);
    score += _proximityScore(pet['codaGrandezza'], codaController.text, 30);
    if (filterSesso != null && pet['sesso'] == filterSesso) score += 20;
    return score;
  }

  int _proximityScore(String? petValue, String targetValue, int maxPoints) {
    if (targetValue.isEmpty || petValue == null) return 0;
    if (petValue == targetValue) return maxPoints;
    const levels = ['Piccola', 'Piccole', 'Medie', 'Media', 'Grande', 'Grandi', 'Molto grandi'];
    int petIdx = levels.indexOf(petValue);
    int targetIdx = levels.indexOf(targetValue);
    if (petIdx != -1 && targetIdx != -1 && (petIdx - targetIdx).abs() <= 2) return (maxPoints / 2).round();
    return 0;
  }

  void updateSpecies(String? s) => setState(() => selectedSpecies = s);
  void updateSesso(String? s) => setState(() => filterSesso = s);
  void updateCicatrici(bool? v) => setState(() => filterCicatrici = v);
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ValueListenableBuilder(
      valueListenable: Hive.box<CustodiaAnimal>(SDSCacheService.custodiaBoxName).listenable(),
      builder: (context, Box<CustodiaAnimal> box, _) {
        List<CustodiaAnimal> allAnimals = box.values.toList();
        allAnimals.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));

        // FILTRAGGIO BASE
        final filteredAnimals = allAnimals.where((animal) {
          final data = animal.rawData;
          final petTipo = data['tipo'] ?? data['specie'];
          if (selectedSpecies != null && petTipo != selectedSpecies) return false;
          
          if (microchipController.text.isNotEmpty) {
            final chip = data['microchipNumero']?.toString() ?? '';
            if (!chip.contains(microchipController.text)) return false;
          }
          return true;
        }).toList();

        // ORDINAMENTO
        List<CustodiaAnimal> sortedResults = filteredAnimals;
        if (userPosition != null && microchipController.text.isEmpty) {
          sortedResults.sort((a, b) {
            double distA = GeoService.calculateDistance(userPosition!.latitude, userPosition!.longitude, a.lat ?? 0, a.lng ?? 0);
            double distB = GeoService.calculateDistance(userPosition!.latitude, userPosition!.longitude, b.lat ?? 0, b.lng ?? 0);
            if (a.lat == null) distA = 999999;
            if (b.lat == null) distB = 999999;
            return distA.compareTo(distB);
          });
        } else {
          sortedResults.sort((a, b) {
            return _calculateSearchAffinity(b.rawData).compareTo(_calculateSearchAffinity(a.rawData));
          });
        }

        // Recuperiamo i rawData per il front che si aspetta documenti Firestore simulati
        // home_custodia.dart originale passava QueryDocumentSnapshot.
        // Dobbiamo simulare degli oggetti che abbiano .data() e .id
        final resultsForFront = sortedResults.map((e) => _MockDoc(e.rawData, e.id)).toList();

        return CustodiaHomeFront(
          onBack: widget.onBack,
          currentUserId: currentUserId,
          selectedSpecies: selectedSpecies,
          onSpeciesSelected: updateSpecies,
          nomeController: nomeController,
          razzaController: razzaController,
          coloreDomController: coloreDomController,
          coloreSecController: coloreSecController,
          occhiColoreController: occhiColoreController,
          orecchieGrandezzaController: orecchieController,
          codaGrandezzaController: codaController,
          microchipController: microchipController,
          selectedCicatrici: filterCicatrici,
          onCicatriciChanged: updateCicatrici,
          results: resultsForFront as dynamic, // Forza il cast per compatibilità col front che si aspetta List<QueryDocumentSnapshot>
          isLoading: false,
          onRefresh: refresh,
          userPosition: userPosition,
          filterSesso: filterSesso,
          onSessoChanged: updateSesso,
        );
      },
    );
  }
}

class _MockDoc {
  final Map<String, dynamic> _data;
  final String id;
  _MockDoc(this._data, this.id);
  Map<String, dynamic> data() => _data;
}
