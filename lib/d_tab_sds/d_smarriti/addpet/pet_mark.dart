import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/d_smarriti/animal_card.dart';

class PetMark extends StatefulWidget {
  final String? initialSpecies;

  const PetMark({super.key, this.initialSpecies});

  @override
  State<PetMark> createState() => _PetMarkState();
}

class _PetMarkState extends State<PetMark> {
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

  Future<void> _showAnimalCardPopup(Map<String, dynamic> data, String docId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: AnimalCard(
            animalData: data,
            currentUserId: currentUserId,
            docId: docId,
            isCompact: true, // ATTIVA LA MODALITÀ COMPATTA
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeRescue = Color(0xFFE67E22);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('RADAR SMARRIMENTI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, color: Color(0xFF2C3E50))),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C3E50), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('animali_smarriti').snapshots(),
            builder: (context, snapshot) {
              final markers = <Marker>[];

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final petTipo = data['tipo'] ?? data['specie'];
                  
                  if (widget.initialSpecies != null && petTipo != widget.initialSpecies) continue;

                  double? lat;
                  double? lng;

                  if (data['lat'] != null && data['lng'] != null) {
                    lat = (data['lat'] as num).toDouble();
                    lng = (data['lng'] as num).toDouble();
                  } else if (data['posizione'] is GeoPoint) {
                    final gp = data['posizione'] as GeoPoint;
                    lat = gp.latitude;
                    lng = gp.longitude;
                  }

                  if (lat != null && lng != null) {
                    final immagine = data['immagine'] ?? (data['immagini'] is List && (data['immagini'] as List).isNotEmpty ? data['immagini'][0] : '');

                    markers.add(
                      Marker(
                        point: LatLng(lat, lng),
                        width: 70,
                        height: 70,
                        child: GestureDetector(
                          onTap: () => _showAnimalCardPopup(data, doc.id),
                          child: _buildElegantMarker(immagine),
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
                  if (!_loadingLocation)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userPosition,
                          width: 40,
                          height: 40,
                          child: _buildUserLocationMarker(),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
          
          if (widget.initialSpecies != null)
            Positioned(
              top: 110, left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: orangeRescue, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text("FILTRO: ${widget.initialSpecies!.toUpperCase()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                  ],
                ),
              ),
            ),

          if (_loadingLocation)
            Container(color: Colors.white.withOpacity(0.5), child: const Center(child: CircularProgressIndicator(color: orangeRescue))),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_myloc",
            backgroundColor: Colors.white,
            mini: true,
            onPressed: () => _checkPermissionsAndGetLocation(),
            child: const Icon(Icons.my_location, color: orangeRescue),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "btn_zoom_in",
            backgroundColor: orangeRescue,
            onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantMarker(String imageUrl) {
    const Color orangeRescue = Color(0xFFE67E22);
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.location_on_rounded, color: orangeRescue, size: 70),
        Positioned(
          top: 8,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover, 
                      errorBuilder: (c, e, s) => const Icon(Icons.pets, color: orangeRescue, size: 20))
                  : const Icon(Icons.pets, color: orangeRescue, size: 20),
            ),
          ),
        ),
        Positioned(
          top: 0, right: 5,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Text("!", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildUserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
        ),
        Container(
          width: 15, height: 15,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)],
          ),
        ),
      ],
    );
  }
}
