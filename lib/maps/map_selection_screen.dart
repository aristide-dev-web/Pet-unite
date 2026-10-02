import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  LatLng? _selectedPosition;
  late final MapController _mapController;
  bool _isLocating = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializePosition();
  }

  Future<void> _initializePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _setFallbackPosition();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final currentLatLng = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _selectedPosition = currentLatLng;
          _isLocating = false;
        });
        _mapController.move(currentLatLng, 16.0);
      }
    } catch (e) {
      debugPrint('Errore GPS: $e');
      _setFallbackPosition();
    }
  }

  void _setFallbackPosition() {
    const fallback = LatLng(41.9028, 12.4964);
    if (mounted) {
      setState(() {
        _selectedPosition = fallback;
        _isLocating = false;
      });
      _mapController.move(fallback, 13.0);
    }
  }

  void _onTapMap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _selectedPosition = latlng;
    });
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selectedPosition = target;
        });
        _mapController.move(target, 16.0);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('map_address_not_found'.tr())),
      );
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedPosition == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF4E342E))),
    );

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedPosition!.latitude,
        _selectedPosition!.longitude,
      );

      String via = "";
      String citta = "";
      String regione = "";

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        via = "${p.thoroughfare ?? ''} ${p.subThoroughfare ?? ''}".trim();
        citta = p.locality ?? p.subLocality ?? '';
        regione = p.administrativeArea ?? '';
      }

      if (mounted) {
        Navigator.pop(context); 
        Navigator.pop(context, {
          'latitude': _selectedPosition!.latitude,
          'longitude': _selectedPosition!.longitude,
          'via': via,
          'città': citta,
          'regione': regione,
        });
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      if (mounted) {
        Navigator.pop(context); 
        Navigator.pop(context, {
          'latitude': _selectedPosition!.latitude,
          'longitude': _selectedPosition!.longitude,
          'via': '',
          'città': '',
          'regione': '',
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('map_selection_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4E342E),
        elevation: 0,
      ),
      body: _isLocating 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC5A059)))
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition ?? const LatLng(41.9028, 12.4964),
              initialZoom: 16.0,
              onTap: _onTapMap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.petping.app',
              ),
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on, color: Color(0xFFE67E22), size: 50),
                    ),
                  ],
                ),
            ],
          ),
          
          // Barra di ricerca
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'map_search_address_hint'.tr(),
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFC5A059)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF4E342E)),
                    onPressed: _searchLocation,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E342E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: _confirmSelection,
                child: Text(
                  'map_confirm_pos_upper'.tr(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
