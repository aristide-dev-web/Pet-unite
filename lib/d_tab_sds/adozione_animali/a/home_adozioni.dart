import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petping/utils/geo_service.dart';
import 'package:petping/d_tab_sds/adozione_animali/a/front_home_adozioni.dart';

class AdozioniHome extends StatefulWidget {
  final VoidCallback? onBack;
  const AdozioniHome({super.key, this.onBack});

  @override
  State<AdozioniHome> createState() => _AdozioniHomeState();
}

class _AdozioniHomeState extends State<AdozioniHome> {
  String? selectedSpecies;
  String? filterSesso;
  bool? filterVaccinato;
  bool? filterCastrato;
  bool? filterPassaporto;
  Position? userPosition;
  
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController razzaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final pos = await GeoService.getCurrentLocation();
    if (mounted) setState(() => userPosition = pos);
  }

  void updateSpecies(String? s) => setState(() => selectedSpecies = s);
  void updateSesso(String? s) => setState(() => filterSesso = s);
  void updateVaccinato(bool? b) => setState(() => filterVaccinato = b);
  void updateCastrato(bool? b) => setState(() => filterCastrato = b);
  void updatePassaporto(bool? b) => setState(() => filterPassaporto = b);
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('animali_adozione').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        List<QueryDocumentSnapshot> finalResults = [];
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          
          final filtered = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final petTipo = data['tipo'] ?? data['specie'];
            if (selectedSpecies != null && petTipo != selectedSpecies) return false;
            
            if (filterSesso != null && data['sesso'] != filterSesso) return false;
            if (filterVaccinato != null && data['vaccinato'] != filterVaccinato) return false;
            if (filterCastrato != null && data['castrato'] != filterCastrato) return false;
            if (filterPassaporto != null && data['passaporto'] != filterPassaporto) return false;

            return true;
          }).toList();

          if (userPosition != null) {
            finalResults = GeoService.sortByProximity(filtered, userPosition!);
          } else {
            finalResults = filtered;
          }
        }

        return AdozioniHomeFront(
          onBack: widget.onBack,
          currentUserId: currentUserId,
          selectedSpecies: selectedSpecies,
          onSpeciesSelected: updateSpecies,
          nomeController: nomeController,
          razzaController: razzaController,
          results: finalResults,
          isLoading: isLoading,
          onRefresh: refresh,
          userPosition: userPosition,
          filterSesso: filterSesso,
          onSessoChanged: updateSesso,
          filterVaccinato: filterVaccinato,
          onVaccinatoChanged: updateVaccinato,
          filterCastrato: filterCastrato,
          onCastratoChanged: updateCastrato,
          filterPassaporto: filterPassaporto,
          onPassaportoChanged: updatePassaporto,
        );
      },
    );
  }
}
