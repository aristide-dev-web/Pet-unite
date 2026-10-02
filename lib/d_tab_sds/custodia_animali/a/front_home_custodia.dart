import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';
import 'package:petping/d_tab_sds/custodia_animali/custodia_card.dart';
import 'package:petping/d_tab_sds/custodia_animali/filtra_custodia.dart';
import 'package:petping/d_tab_sds/custodia_animali/pet_mark_custodia.dart';
import 'package:petping/d_tab_sds/custodia_animali/button_custodia_home.dart';

class CustodiaHomeFront extends StatelessWidget {
  final VoidCallback? onBack;
  final String currentUserId;
  final String? selectedSpecies;
  final Function(String?) onSpeciesSelected;
  final TextEditingController nomeController;
  final TextEditingController razzaController;
  final TextEditingController coloreDomController;
  final TextEditingController coloreSecController;
  final TextEditingController occhiColoreController;
  final TextEditingController orecchieGrandezzaController;
  final TextEditingController codaGrandezzaController;
  final TextEditingController microchipController;
  final bool? selectedCicatrici;
  final Function(bool?) onCicatriciChanged;
  final List<dynamic> results; // CAMBIATO DA List<QueryDocumentSnapshot> A List<dynamic>
  final bool isLoading;
  final VoidCallback onRefresh;
  final Position? userPosition;
  final String? filterSesso;
  final Function(String?) onSessoChanged;

  const CustodiaHomeFront({
    super.key,
    this.onBack,
    required this.currentUserId,
    this.selectedSpecies,
    required this.onSpeciesSelected,
    required this.nomeController,
    required this.razzaController,
    required this.coloreDomController,
    required this.coloreSecController,
    required this.occhiColoreController,
    required this.orecchieGrandezzaController,
    required this.codaGrandezzaController,
    required this.microchipController,
    this.selectedCicatrici,
    required this.onCicatriciChanged,
    required this.results,
    required this.isLoading,
    required this.onRefresh,
    this.userPosition,
    this.filterSesso,
    required this.onSessoChanged,
  });

  static const Color blueSecurity = Color(0xFF2980B9); 
  static const Color deepText = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), 
      floatingActionButton: const ButtonCustodiaHome(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: deepText, size: 22), onPressed: onBack),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("custodia_title".tr(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: blueSecurity, letterSpacing: -0.5)),
                        Text("custodia_subtitle".tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                  ),
                  _buildHeaderAction(context, Icons.search_rounded, () => _apriRicerca(context)),
                  const SizedBox(width: 10),
                  _buildHeaderAction(context, Icons.map_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => PetMarkCustodia(initialSpecies: selectedSpecies)))),
                ],
              ),
            ),

            CategorySelector(
              selectedSpecies: selectedSpecies,
              onSelected: onSpeciesSelected,
              activeColor: blueSecurity,
            ),
            
            Expanded(
              child: isLoading 
                ? const Center(child: CircularProgressIndicator(color: blueSecurity))
                : results.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final doc = results[index];
                        // Gestione sicura dei dati, sia che siano MockDoc o QueryDocumentSnapshot
                        final data = doc.data() is Map ? doc.data() as Map<String, dynamic> : <String, dynamic>{};
                        final id = doc.id;

                        return CustodiaCard(
                          animalData: data, 
                          currentUserId: currentUserId, 
                          docId: id
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _apriRicerca(BuildContext context) {
    String? tempSesso = filterSesso;
    String? tempTipo = selectedSpecies;
    bool? tempCicatrici = selectedCicatrici;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: FiltraCustodia(
              nomeController: nomeController,
              razzaController: razzaController,
              microchipController: microchipController,
              coloreDominanteController: coloreDomController,
              coloreSecondarioController: coloreSecController,
              occhiColoreController: occhiColoreController,
              orecchieGrandezzaController: orecchieGrandezzaController,
              codaGrandezzaController: codaGrandezzaController,
              selectedCicatrici: tempCicatrici,
              onCicatriciChanged: (v) {
                tempCicatrici = v;
                setModalState(() {});
              },
              onSessoChanged: (v) {
                tempSesso = v;
                setModalState(() {});
              },
              onTipoChanged: (v) {
                tempTipo = v;
                setModalState(() {});
              },
              onFiltra: () {
                onSessoChanged(tempSesso);
                onSpeciesSelected(tempTipo);
                onCicatriciChanged(tempCicatrici);
                Navigator.pop(context);
                onRefresh();
              },
              selectedSesso: tempSesso,
              selectedTipo: tempTipo,
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

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), Text("custodia_empty".tr(), style: const TextStyle(color: deepText, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text("custodia_empty_sub".tr(), style: const TextStyle(color: Colors.grey))]));
}
