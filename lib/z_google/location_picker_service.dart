import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';

class LocationPickerService {
  
  static Future<Map<String, dynamic>?> showPicker(BuildContext context) async {
    debugPrint("DEBUG_GPS: [START] showPicker");
    
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text("location_picker_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 1.5, fontSize: 14)),
            const SizedBox(height: 30),
            
            // 1. POSIZIONE ATTUALE
            _buildOption(
              icon: Icons.my_location_rounded,
              color: Colors.blueAccent,
              title: "location_option_current_title".tr(),
              subtitle: "location_option_current_sub".tr(),
              onTap: () async {
                debugPrint("DEBUG_GPS: Scelta 'Posizione Attuale'");
                final pos = await _getCurrentLocation(context);
                if (pos != null) {
                  debugPrint("DEBUG_GPS: Coordinate: ${pos.latitude}, ${pos.longitude}");
                  String addr = "location_msg_current".tr();
                  try {
                    List<Placemark> p = await placemarkFromCoordinates(pos.latitude, pos.longitude);
                    if (p.isNotEmpty) {
                      addr = "${p[0].thoroughfare ?? ''}, ${p[0].locality ?? ''}".trim();
                      if (addr.startsWith(',')) addr = addr.substring(1).trim();
                    }
                  } catch (e) { debugPrint("DEBUG_GPS: Errore indirizzo: $e"); }

                  if (context.mounted) {
                    final res = {'type': 'static', 'link': "https://www.google.com/maps?q=${pos.latitude},${pos.longitude}", 'address': addr};
                    debugPrint("DEBUG_GPS: [SUCCESS] Invio: $res");
                    Navigator.of(context).pop(res);
                  }
                }
              },
            ),
            const SizedBox(height: 15),
            
            // 2. SCEGLI SULLA MAPPA (Bios Style)
            _buildOption(
              icon: Icons.map_rounded,
              color: const Color(0xFF64B5B4),
              title: "location_option_map_title".tr(),
              subtitle: "location_option_map_sub".tr(),
              onTap: () async {
                debugPrint("DEBUG_GPS: Apertura Mappa (Bios Style)");
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (ctx) => const MapPickerDialog(),
                );
                if (result != null && context.mounted) {
                  debugPrint("DEBUG_GPS: [SUCCESS] Ricevuto da mappa: $result");
                  Navigator.of(context).pop(result);
                }
              },
            ),
            const SizedBox(height: 15),

            // 3. GPS LIVE
            _buildOption(
              icon: Icons.run_circle_outlined,
              color: Colors.orangeAccent,
              title: "location_option_live_title".tr(),
              subtitle: "location_option_live_sub".tr(),
              onTap: () {
                debugPrint("DEBUG_GPS: Scelta GPS Live");
                _showLiveWarning(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showLiveWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent), const SizedBox(width: 10), Text("location_live_warning_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold))]),
        content: Text("location_live_warning_text".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("btn_cancel".tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              debugPrint("DEBUG_GPS: Conferma Live");
              Navigator.pop(ctx);
              Navigator.of(context).pop({'type': 'live', 'address': "location_msg_realtime".tr()});
            },
            child: Text("location_live_btn_start".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Widget _buildOption({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1), width: 1.5)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ),
    );
  }

  static Future<Position?> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("DEBUG_GPS: GPS spento sul telefono");
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("location_gps_off_title".tr()),
            content: Text("${"location_gps_off_text".tr()}\n\n${"location_return_instruction".tr()}"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text("btn_cancel".tr())),
              ElevatedButton(onPressed: () async { await Geolocator.openLocationSettings(); Navigator.pop(ctx); }, child: Text("location_gps_off_btn".tr())),
            ],
          ),
        );
      }
      return null;
    }
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) { p = await Geolocator.requestPermission(); if (p == LocationPermission.denied) return null; }
    if (p == LocationPermission.deniedForever) return null;
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}

class MapPickerDialog extends StatefulWidget {
  const MapPickerDialog({super.key});
  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentPos = const LatLng(41.9028, 12.4964);
  bool _isSearching = false;
  String _address = "";

  @override
  void initState() {
    super.initState();
    _address = "location_selected".tr();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 5));
      if (mounted) {
        debugPrint("DEBUG_GPS: Init mappa su coordinate GPS");
        setState(() => _currentPos = LatLng(pos.latitude, pos.longitude));
        _mapController.move(_currentPos, 15.0);
        _updateAddressFromCoords(_currentPos);
      }
    } catch (e) { debugPrint("DEBUG_GPS: Errore init mappa: $e"); }
  }

  Future<void> _updateAddressFromCoords(LatLng pos) async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (p.isNotEmpty && mounted) {
        setState(() {
          _address = "${p[0].thoroughfare ?? ''}, ${p[0].locality ?? ''}".trim();
          if (_address.startsWith(',')) _address = _address.substring(1).trim();
        });
        debugPrint("DEBUG_GPS: Indirizzo trovato: $_address");
      }
    } catch (e) {}
  }

  Future<void> _searchAddress(String text) async {
    if (text.isEmpty) return;
    debugPrint("DEBUG_GPS: Ricerca indirizzo: $text");
    setState(() => _isSearching = true);
    try {
      List<Location> locs = await locationFromAddress(text);
      if (locs.isNotEmpty && mounted) {
        final newPos = LatLng(locs.first.latitude, locs.first.longitude);
        setState(() { _currentPos = newPos; _address = text; });
        _mapController.move(newPos, 15.0);
        _updateAddressFromCoords(newPos);
      }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("location_error_not_found".tr()))); }
    finally { if (mounted) setState(() => _isSearching = false); }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF64B5B4);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), border: Border.all(color: primaryColor.withOpacity(0.2), width: 4)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(31),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: _currentPos, initialZoom: 15.0, onTap: (tp, l) {
                  debugPrint("DEBUG_GPS: Tap mappa a coordinate: ${l.latitude}, ${l.longitude}");
                  setState(() => _currentPos = l);
                  _updateAddressFromCoords(l);
                }),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.petping.app'),
                  MarkerLayer(markers: [Marker(point: _currentPos, width: 60, height: 60, child: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 50))]),
                ],
              ),
              // Barra Ricerca Overlay (Bios style)
              Positioned(top: 15, left: 15, right: 15, child: Container(height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))]), child: TextField(controller: _searchController, decoration: InputDecoration(hintText: "location_map_hint".tr(), prefixIcon: const Icon(Icons.search, color: primaryColor), suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(icon: const Icon(Icons.send_rounded, color: primaryColor), onPressed: () => _searchAddress(_searchController.text)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12)), onSubmitted: _searchAddress))),
              // Indirizzo sopra i pulsanti
              Positioned(bottom: 100, left: 20, right: 20, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Text(_address, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)))),
              // Tasto My Location
              Positioned(bottom: 150, right: 15, child: FloatingActionButton.small(backgroundColor: Colors.white, elevation: 4, onPressed: _setInitialLocation, child: const Icon(Icons.my_location, color: primaryColor))),
              // Pulsanti Invio/Annulla
              Positioned(bottom: 20, left: 20, right: 20, child: Row(children: [Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), side: const BorderSide(color: Colors.grey, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () => Navigator.pop(context), child: Text("btn_cancel".tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))), const SizedBox(width: 15), Expanded(flex: 2, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, elevation: 5, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () {
                final data = {'type': 'static', 'link': "https://www.google.com/maps?q=${_currentPos.latitude},${_currentPos.longitude}", 'address': _address};
                debugPrint("DEBUG_GPS: [CONFIRM] Invio pacchetto: $data");
                Navigator.pop(context, data);
              }, child: Text("location_btn_send".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))])),
            ],
          ),
        ),
      ),
    );
  }
}
