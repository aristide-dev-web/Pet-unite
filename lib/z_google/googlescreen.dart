import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:easy_localization/easy_localization.dart';

const String kGoogleApiKey =
    "LA_TUA_API_KEY"; // Sostituisci con la tua vera API Key

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  late GoogleMapController mapController;

  final LatLng _initialPosition = LatLng(41.9028, 12.4964); // Roma
  final Mode _mode = Mode.overlay;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _handleSearch() async {
    var p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: _mode,
      language: context.locale.languageCode,
      // components: [Component(Component.country, "it")], // Rimosso per compatibilità
    );

    if (p != null) {
      List<Location> locations = await locationFromAddress(p.description!);
      if (locations.isNotEmpty) {
        final lat = locations.first.latitude;
        final lng = locations.first.longitude;
        final selectedLatLng = LatLng(lat, lng);

        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId("searched_location"),
              position: selectedLatLng,
              infoWindow: InfoWindow(title: p.description),
            ),
          );
        });

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(selectedLatLng, 16),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home_btn_qr'.tr()), // Usando QR o cercandone uno generico per mappa
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _handleSearch),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
      ),
    );
  }
}
