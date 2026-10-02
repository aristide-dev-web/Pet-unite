import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/pet_mark.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/add_uno.dart';
import 'package:petping/d_tab_sds/d_smarriti/animal_card.dart';
import 'package:petping/d_tab_sds/d_smarriti/filtra_animal.dart';
import 'package:petping/utils/geo_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petping/d_tab_sds/models/sds_models.dart';
import 'package:petping/d_tab_sds/services/sds_cache_service.dart';
import 'package:petping/d_tab_sds/d_smarriti/services/sos_paywall_dialog.dart';
import 'package:petping/d_tab_sds/d_smarriti/services/sos_payment_service.dart';
import 'package:easy_localization/easy_localization.dart';

class LostAnimalsHome extends StatefulWidget {
  final VoidCallback? onBack;

  const LostAnimalsHome({super.key, this.onBack});

  @override
  State<LostAnimalsHome> createState() => _LostAnimalsHomeState();
}

class _LostAnimalsHomeState extends State<LostAnimalsHome> {
  static const Color orangeRescue = Color(0xFFE67E22);
  static const Color deepText = Color(0xFF2C3E50);

  String? _selectedSpecies;
  String? _filterSesso;
  bool? _filterCicatrici;
  Position? _userPosition;
  bool _isPaginationLoading = false;
  
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _razzaController = TextEditingController();
  final TextEditingController _coloreDomController = TextEditingController();
  final TextEditingController _coloreSecController = TextEditingController();
  final TextEditingController _occhiColoreController = TextEditingController();
  final TextEditingController _orecchieController = TextEditingController();
  final TextEditingController _codaController = TextEditingController();
  final TextEditingController _microchipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    SDSCacheService.caricaBatchSmarriti(limit: 6);
  }

  Future<void> _getUserLocation() async {
    final pos = await GeoService.getCurrentLocation();
    if (mounted) {
      setState(() => _userPosition = pos);
    }
  }

  Future<void> _loadMore() async {
    if (_isPaginationLoading) return;
    setState(() => _isPaginationLoading = true);
    await SDSCacheService.caricaBatchSmarriti(limit: 6);
    if (mounted) setState(() => _isPaginationLoading = false);
  }

  Future<void> _handleSegnala(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sosService = SosPaymentService();
    bool canPost = await sosService.canPostFree();

    if (canPost) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddUno()));
    } else {
      if (!mounted) return;
      await SosPaywallDialog.show(context);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _razzaController.dispose();
    _coloreDomController.dispose();
    _coloreSecController.dispose();
    _occhiColoreController.dispose();
    _orecchieController.dispose();
    _codaController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "fab_smarriti_manuale",
        onPressed: () => _handleSegnala(context),
        backgroundColor: orangeRescue,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text("sos_btn_report_fab".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
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
                        Text("sos_title_header".tr(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: orangeRescue, letterSpacing: -0.5)),
                        Text("sos_subtitle_header".tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                  ),
                  _buildHeaderAction(Icons.search_rounded, () => _apriRicerca()),
                  const SizedBox(width: 10),
                  _buildHeaderAction(Icons.map_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => PetMark(initialSpecies: _selectedSpecies)))),
                ],
              ),
            ),

            CategorySelector(
              selectedSpecies: _selectedSpecies,
              onSelected: (species) => setState(() => _selectedSpecies = species),
              isSOS: true, 
            ),
            
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<LostAnimal>(SDSCacheService.lostBoxName).listenable(),
                builder: (context, Box<LostAnimal> box, _) {
                  List<LostAnimal> allAnimals = box.values.toList();
                  
                  allAnimals.sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));

                  final filteredAnimals = allAnimals.where((animal) {
                    final data = animal.rawData;
                    final String petTipo = (data['tipo'] ?? data['specie'] ?? '').toString();
                    
                    if (_selectedSpecies != null) {
                       if (_selectedSpecies == 'Altro') {
                          if (['Cane', 'Gatto', 'Coniglio'].contains(petTipo)) return false;
                       } else if (petTipo != _selectedSpecies) {
                          return false;
                       }
                    }
                    
                    if (_microchipController.text.isNotEmpty) {
                      final chip = data['microchipNumero']?.toString() ?? data['microchip']?.toString() ?? '';
                      if (!chip.contains(_microchipController.text)) return false;
                    }
                    return true;
                  }).toList();

                  if (filteredAnimals.isEmpty && !_isPaginationLoading) return _buildEmptyState();

                  if (_userPosition != null) {
                    filteredAnimals.sort((a, b) {
                      double distA = GeoService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, a.lat ?? 0, a.lng ?? 0);
                      double distB = GeoService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, b.lat ?? 0, b.lng ?? 0);
                      return distA.compareTo(distB);
                    });
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                        _loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: filteredAnimals.length + (_isPaginationLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredAnimals.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator(color: orangeRescue)),
                          );
                        }
                        final animal = filteredAnimals[index];
                        return AnimalCard(
                          animalData: animal.rawData, 
                          currentUserId: currentUserId, 
                          docId: animal.id
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
            child: FiltraAnimali(
              nomeController: _nomeController,
              razzaController: _razzaController,
              coloreDominanteController: _coloreDomController,
              coloreSecondarioController: _coloreSecController,
              occhiColoreController: _occhiColoreController,
              orecchieGrandezzaController: _orecchieController,
              codaGrandezzaController: _codaController,
              microchipController: _microchipController,
              onSessoChanged: (v) {
                setState(() => _filterSesso = v);
                setModalState(() {});
              },
              onCicatriciChanged: (v) {
                setState(() => _filterCicatrici = v);
                setModalState(() {});
              },
              onTipoChanged: (v) {
                setState(() => _selectedSpecies = v);
                setModalState(() {});
              },
              onFiltra: () {
                Navigator.pop(context);
                setState(() {});
              },
              selectedSesso: _filterSesso,
              selectedCicatrici: _filterCicatrici,
              selectedTipo: _selectedSpecies,
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

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.pets_rounded, size: 80, color: orangeRescue.withOpacity(0.3)),
        const SizedBox(height: 16),
        Text("sos_empty_title".tr(), style: const TextStyle(color: deepText, fontWeight: FontWeight.bold, fontSize: 18)),
        Text("sos_empty_subtitle".tr(), style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
