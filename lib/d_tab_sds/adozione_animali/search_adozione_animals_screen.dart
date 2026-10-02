import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/d_tab_sds/adozione_animali/add/add_adozione_uno.dart';
import 'package:petping/d_tab_sds/adozione_animali/adozione_card.dart';
import 'package:petping/d_tab_sds/adozione_animali/filtra_adozioni.dart';
import 'package:petping/d_tab_sds/adozione_animali/pet_mark_adozioni.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';
import 'package:petping/utils/geo_service.dart';
import 'package:petping/d_tab_sds/models/sds_models.dart';
import 'package:petping/d_tab_sds/services/sds_cache_service.dart';

class SearchAdozioneAnimalsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SearchAdozioneAnimalsScreen({super.key, this.onBack});

  @override
  State<SearchAdozioneAnimalsScreen> createState() =>
      _SearchAdozioneAnimalsScreenState();
}

class _SearchAdozioneAnimalsScreenState
    extends State<SearchAdozioneAnimalsScreen> {
  static const Color greenHope = Color(0xFF27AE60);
  static const Color deepText = Color(0xFF2C3E50);

  String? _selectedSpecies;
  String? _filterSesso;
  bool? _filterVaccinato;
  bool? _filterCastrato;
  Position? _userPosition;

  final TextEditingController _razzaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final pos = await GeoService.getCurrentLocation();
    if (mounted) {
      setState(() => _userPosition = pos);
    }
  }

  @override
  void dispose() {
    _razzaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "fab_adozioni",
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAdozioneUno())),
        backgroundColor: greenHope,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text("adozione_btn_add".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: deepText, size: 22), onPressed: widget.onBack),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("adozione_title".tr(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: greenHope, letterSpacing: -0.5)),
                        Text("adozione_subtitle".tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                  ),
                  _buildHeaderAction(Icons.search_rounded, () => _apriRicerca()),
                  const SizedBox(width: 10),
                  _buildHeaderAction(Icons.map_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => PetMarkAdozioni(initialSpecies: _selectedSpecies)))),
                ],
              ),
            ),

            CategorySelector(
              selectedSpecies: _selectedSpecies,
              onSelected: (species) => setState(() => _selectedSpecies = species),
              activeColor: greenHope,
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<AdozioneAnimal>(SDSCacheService.adozioneBoxName).listenable(),
                builder: (context, Box<AdozioneAnimal> box, _) {
                  if (box.isEmpty) return _buildEmptyState();

                  List<AdozioneAnimal> allAnimals = box.values.toList();
                  allAnimals.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));

                  final filteredResults = allAnimals.where((animal) {
                    final data = animal.rawData;
                    final petTipo = data['specie'] ?? data['tipo'];
                    if (_selectedSpecies != null && petTipo != _selectedSpecies) return false;
                    
                    if (_filterSesso != null && data['sesso'] != _filterSesso) return false;
                    if (_filterVaccinato != null && data['vaccinato'] != _filterVaccinato) return false;
                    if (_filterCastrato != null && data['castrato'] != _filterCastrato) return false;

                    return true;
                  }).toList();

                  if (_userPosition != null) {
                    filteredResults.sort((a, b) {
                      double distA = GeoService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, a.lat ?? 0, a.lng ?? 0);
                      double distB = GeoService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, b.lat ?? 0, b.lng ?? 0);
                      if (a.lat == null) distA = 999999;
                      if (b.lat == null) distB = 999999;
                      return distA.compareTo(distB);
                    });
                  } else {
                    filteredResults.sort((a, b) {
                      return _calculateSearchAffinity(b.rawData).compareTo(_calculateSearchAffinity(a.rawData));
                    });
                  }

                  if (filteredResults.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final animal = filteredResults[index];
                      return AdozioneCard(
                        animalData: animal.rawData, 
                        currentUserId: currentUserId, 
                        docId: animal.id
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSearchAffinity(Map<String, dynamic> pet) {
    int score = 0;
    
    if (_razzaController.text.isNotEmpty) {
      String search = _razzaController.text.toLowerCase();
      String petRazza = (pet['razza'] ?? '').toString().toLowerCase();
      if (petRazza == search) score += 150;
      else if (petRazza.contains(search)) score += 80;
    }

    if (_filterSesso != null && pet['sesso'] == _filterSesso) score += 50;

    return score;
  }

  void _apriRicerca() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: FiltraAdozioni(
              razzaController: _razzaController,
              onSessoChanged: (v) {
                setState(() => _filterSesso = v);
                setModalState(() {});
              },
              onTipoChanged: (v) {
                setState(() => _selectedSpecies = v);
                setModalState(() {});
              },
              onVaccinatoChanged: (v) {
                setState(() => _filterVaccinato = v);
                setModalState(() {});
              },
              onCastratoChanged: (v) {
                setState(() => _filterCastrato = v);
                setModalState(() {});
              },
              onFiltra: () {
                Navigator.pop(context);
                setState(() {});
              },
              selectedSesso: _filterSesso,
              selectedTipo: _selectedSpecies,
              selectedVaccinato: _filterVaccinato,
              selectedCastrato: _filterCastrato,
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: deepText, size: 22)))),
  );

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), Text("adozione_empty".tr(), style: const TextStyle(color: deepText, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text("adozione_empty_sub".tr(), style: const TextStyle(color: Colors.grey))]));
}
