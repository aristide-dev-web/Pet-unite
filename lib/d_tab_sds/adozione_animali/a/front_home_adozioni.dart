import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';
import 'package:petping/d_tab_sds/adozione_animali/adozione_card.dart';
import 'package:petping/d_tab_sds/adozione_animali/filtra_adozioni.dart';
import 'package:petping/d_tab_sds/adozione_animali/pet_mark_adozioni.dart';
import 'package:petping/d_tab_sds/adozione_animali/button_adozione_home.dart';

class AdozioniHomeFront extends StatelessWidget {
  final VoidCallback? onBack;
  final String currentUserId;
  final String? selectedSpecies;
  final Function(String?) onSpeciesSelected;
  final TextEditingController nomeController;
  final TextEditingController razzaController;
  final List<QueryDocumentSnapshot> results;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Position? userPosition;
  final String? filterSesso;
  final Function(String?) onSessoChanged;
  
  final bool? filterVaccinato;
  final Function(bool?) onVaccinatoChanged;
  final bool? filterCastrato;
  final Function(bool?) onCastratoChanged;
  final bool? filterPassaporto;
  final Function(bool?) onPassaportoChanged;

  const AdozioniHomeFront({
    super.key,
    this.onBack,
    required this.currentUserId,
    this.selectedSpecies,
    required this.onSpeciesSelected,
    required this.nomeController,
    required this.razzaController,
    required this.results,
    required this.isLoading,
    required this.onRefresh,
    this.userPosition,
    this.filterSesso,
    required this.onSessoChanged,
    this.filterVaccinato,
    required this.onVaccinatoChanged,
    this.filterCastrato,
    required this.onCastratoChanged,
    this.filterPassaporto,
    required this.onPassaportoChanged,
  });

  static const Color greenHope = Color(0xFF27AE60); // Verde speranza
  static const Color deepText = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4), // Sfondo verde chiarissimo
      floatingActionButton: const ButtonAdozioneHome(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: deepText, size: 22), onPressed: onBack),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ADOZIONI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: greenHope, letterSpacing: -0.5)),
                        Text("Trova il compagno della tua vita", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                  ),
                  _buildHeaderAction(context, Icons.search_rounded, () => _apriRicerca(context)),
                  const SizedBox(width: 10),
                  _buildHeaderAction(context, Icons.map_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => PetMarkAdozioni(initialSpecies: selectedSpecies)))),
                ],
              ),
            ),

            CategorySelector(
              selectedSpecies: selectedSpecies,
              onSelected: onSpeciesSelected,
              activeColor: greenHope,
            ),
            
            Expanded(
              child: isLoading 
                ? const Center(child: CircularProgressIndicator(color: greenHope))
                : results.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: results.length,
                      itemBuilder: (context, index) => AdozioneCard(
                        animalData: results[index].data() as Map<String, dynamic>, 
                        currentUserId: currentUserId, 
                        docId: results[index].id
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _apriRicerca(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: FiltraAdozioni(
              razzaController: razzaController,
              onSessoChanged: (v) {
                onSessoChanged(v);
                setModalState(() {});
              },
              onTipoChanged: (v) {
                onSpeciesSelected(v);
                setModalState(() {});
              },
              onVaccinatoChanged: (v) {
                onVaccinatoChanged(v);
                setModalState(() {});
              },
              onCastratoChanged: (v) {
                onCastratoChanged(v);
                setModalState(() {});
              },
              onFiltra: () {
                Navigator.pop(context);
                onRefresh();
              },
              selectedSesso: filterSesso,
              selectedTipo: selectedSpecies,
              selectedVaccinato: filterVaccinato,
              selectedCastrato: filterCastrato,
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, IconData icon, VoidCallback onTap) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: deepText, size: 22)))),
  );

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), const Text("Nessun cucciolo trovato", style: TextStyle(color: deepText, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), const Text("Prova a cambiare i filtri", style: TextStyle(color: Colors.grey))]));
}
