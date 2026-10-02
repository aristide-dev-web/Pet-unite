import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/adozione_animali/adozione_card.dart';

class PetMarkAdozioni extends StatefulWidget {
  final String? initialSpecies;
  const PetMarkAdozioni({super.key, this.initialSpecies});

  @override
  State<PetMarkAdozioni> createState() => _PetMarkAdozioniState();
}

class _PetMarkAdozioniState extends State<PetMarkAdozioni> {
  LatLng _userPosition = const LatLng(41.9028, 12.4964);
  bool _loadingLocation = true;
  final MapController _mapController = MapController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _userPosition = LatLng(position.latitude, position.longitude);
            _loadingLocation = false;
          });
          _mapController.move(_userPosition, 13.0);
        }
      } catch (e) {
        if (mounted) setState(() => _loadingLocation = false);
      }
    } else {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _showAdozioneCardPopup(Map<String, dynamic> data, String docId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: AdozioneCard(
            animalData: data,
            currentUserId: currentUserId,
            docId: docId,
            isCompact: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color greenHope = Color(0xFF27AE60);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MAPPA ADOZIONI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, color: Color(0xFF2C3E50))),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('animali_adozione').snapshots(),
            builder: (context, snapshot) {
              final markers = <Marker>[];
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final petTipo = data['tipo'] ?? data['specie'];
                  if (widget.initialSpecies != null && petTipo != widget.initialSpecies) continue;

                  double? lat = (data['lat'] ?? data['latitude']) as double?;
                  double? lng = (data['lng'] ?? data['longitude']) as double?;

                  if (lat != null && lng != null) {
                    final immagine = data['immagine'] ?? (data['immagini'] is List && (data['immagini'] as List).isNotEmpty ? data['immagini'][0] : '');
                    markers.add(
                      Marker(
                        point: LatLng(lat, lng),
                        width: 70,
                        height: 70,
                        child: GestureDetector(
                          onTap: () => _showAdozioneCardPopup(data, doc.id),
                          child: _buildGreenMarker(immagine),
                        ),
                      ),
                    );
                  }
                }
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _userPosition,
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.petping.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),
          if (_loadingLocation) Container(color: Colors.white.withOpacity(0.5), child: const Center(child: CircularProgressIndicator(color: greenHope))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn_myloc_adozioni",
        backgroundColor: Colors.white,
        onPressed: () => _checkPermissionsAndGetLocation(),
        child: const Icon(Icons.my_location, color: greenHope),
      ),
    );
  }

  Widget _buildGreenMarker(String imageUrl) {
    const Color greenHope = Color(0xFF27AE60);
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.location_on_rounded, color: greenHope, size: 70),
        Positioned(
          top: 8,
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.pets, color: greenHope, size: 20))
                  : const Icon(Icons.pets, color: greenHope, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
