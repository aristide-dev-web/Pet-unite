import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class MappaAnimale extends StatefulWidget {
  final double latitudine;
  final double longitudine;
  final void Function(double, double)? onCoordinateChanged;
  final void Function(String via, String citta, String regione)?
  onIndirizzoSelezionato;

  const MappaAnimale({
    required this.latitudine,
    required this.longitudine,
    this.onCoordinateChanged,
    required this.onIndirizzoSelezionato,
    super.key,
  });

  @override
  State<MappaAnimale> createState() => _MappaAnimaleState();
}

class _MappaAnimaleState extends State<MappaAnimale> {
  late LatLng _posizione;
  String? _indirizzo;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  bool _caricamento = false;

  @override
  void initState() {
    super.initState();
    _posizione = LatLng(widget.latitudine, widget.longitudine);
    _caricaIndirizzo(_posizione);
  }

  Future<void> _caricaIndirizzo(LatLng punto) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        punto.latitude,
        punto.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final via = p.street ?? '';
        final citta = p.locality ?? '';
        final regione = p.administrativeArea ?? '';

        setState(() {
          _indirizzo = '$via, $citta, $regione';
        });

        widget.onIndirizzoSelezionato?.call(via, citta, regione);
      }
    } catch (e) {
      debugPrint('Errore nel reverse geocoding: $e');
      setState(() {
        _indirizzo = null;
      });
    }
  }

  void _aggiornaPosizione(LatLng nuovoPunto) {
    setState(() {
      _posizione = nuovoPunto;
    });
    _mapController.move(nuovoPunto, _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_caricamento)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _posizione,
                  initialZoom: 16.0,
                  onTap: (tapPosition, point) => _aggiornaPosizione(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.petping.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _posizione,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: _searchController,
                    enabled: !_caricamento,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      hintText: 'map_search_hint'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        setState(() => _caricamento = true);
                        try {
                          final url = Uri.parse(
                            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(value)}&format=json&limit=1',
                          );
                          final response = await http.get(
                            url,
                            headers: {
                              'User-Agent':
                                  'app-app/1.0 (support.petunite@gmail.com)',
                            },
                          );

                          if (response.statusCode == 200) {
                            final data = jsonDecode(response.body);
                            if (data.isNotEmpty) {
                              final lat = double.parse(data[0]['lat']);
                              final lon = double.parse(data[0]['lon']);
                              final nuovoPunto = LatLng(lat, lon);
                              _aggiornaPosizione(nuovoPunto);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('map_address_not_found'.tr()),
                                ),
                              );
                            }
                          } else {
                            throw Exception(
                              'Errore HTTP ${response.statusCode}',
                            );
                          }
                        } catch (e) {
                          debugPrint('Errore nella ricerca: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))),
                          );
                        } finally {
                          setState(() => _caricamento = false);
                        }
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    widget.onCoordinateChanged?.call(
                      _posizione.latitude,
                      _posizione.longitude,
                    );
                    _caricaIndirizzo(_posizione);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('map_pos_saved'.tr())),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: Text('btn_save'.tr()),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        if (_indirizzo != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '📍 $_indirizzo',
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
