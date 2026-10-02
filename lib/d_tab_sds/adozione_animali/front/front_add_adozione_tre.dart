import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

class FrontAddAdozioneTre extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController viaController;
  final TextEditingController cittaController;
  final TextEditingController regioneController;
  final TextEditingController raccontoController;
  final Function(double lat, double lng, String via, String citta, String regione) onPositionConfirmed;
  final VoidCallback onNext;
  final double? lat;
  final double? lng;

  static const Color greenHope = Color(0xFF27AE60);
  static const Color darkBlue = Color(0xFF2C3E50);

  const FrontAddAdozioneTre({
    super.key,
    required this.formKey,
    required this.viaController,
    required this.cittaController,
    required this.regioneController,
    required this.raccontoController,
    required this.onPositionConfirmed,
    required this.onNext,
    this.lat,
    this.lng,
  });

  @override
  State<FrontAddAdozioneTre> createState() => _FrontAddAdozioneTreState();
}

class _FrontAddAdozioneTreState extends State<FrontAddAdozioneTre> {
  late MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _tempPosition;
  bool _showConfirmButton = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.lat != null && widget.lng != null) {
      _tempPosition = LatLng(widget.lat!, widget.lng!);
    }
  }

  Future<void> _searchAddress(String address) async {
    if (address.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPos = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _tempPosition = newPos;
          _showConfirmButton = true;
        });
        _mapController.move(newPos, 15.0);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("map_address_not_found".tr())));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _handleConfirm() async {
    if (_tempPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_tempPosition!.latitude, _tempPosition!.longitude);
      String via = "", citta = "", regione = "";
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        via = "${p.thoroughfare ?? ''} ${p.subThoroughfare ?? ''}".trim();
        citta = p.locality ?? p.subLocality ?? '';
        regione = p.administrativeArea ?? '';
      }
      widget.onPositionConfirmed(_tempPosition!.latitude, _tempPosition!.longitude, via, citta, regione);
      setState(() => _showConfirmButton = false);
    } catch (e) {
      widget.onPositionConfirmed(_tempPosition!.latitude, _tempPosition!.longitude, "", "", "");
      setState(() => _showConfirmButton = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('adozione_add_where_question'.tr()),
          
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: FrontAddAdozioneTre.greenHope.withOpacity(0.3), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _tempPosition ?? const LatLng(41.9028, 12.4964),
                      initialZoom: _tempPosition != null ? 15.0 : 5.0,
                      onTap: (tapPos, latlng) {
                        setState(() {
                          _tempPosition = latlng;
                          _showConfirmButton = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.petping.app',
                      ),
                      if (_tempPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _tempPosition!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  Positioned(
                    top: 10, left: 10, right: 10,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13, color: FrontAddAdozioneTre.darkBlue),
                        decoration: InputDecoration(
                          hintText: "adozione_add_search_hint".tr(),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, size: 18, color: FrontAddAdozioneTre.greenHope),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: _isSearching 
                            ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: FrontAddAdozioneTre.greenHope))
                            : IconButton(icon: const Icon(Icons.send_rounded, size: 18), onPressed: () => _searchAddress(_searchController.text)),
                        ),
                        onSubmitted: (val) => _searchAddress(val),
                      ),
                    ),
                  ),

                  if (_showConfirmButton)
                    Positioned(
                      bottom: 10, left: 50, right: 50,
                      child: GestureDetector(
                        onTap: _handleConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: FrontAddAdozioneTre.darkBlue, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text("adozione_add_save_pos".tr(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          _buildTextField(controller: widget.viaController, hint: 'profile_label_address'.tr()),
          Row(
            children: [
              Expanded(child: _buildTextField(controller: widget.cittaController, hint: 'profile_label_city'.tr())),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(controller: widget.regioneController, hint: 'profile_label_region'.tr())),
            ],
          ),

          _buildLabel('profile_label_bio'.tr().toUpperCase()),
          TextFormField(
            controller: widget.raccontoController,
            maxLines: 4,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'adozione_add_desc_hint'.tr(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: FrontAddAdozioneTre.greenHope,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('sos_add_btn_contacts'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
      child: Text(text, style: const TextStyle(color: FrontAddAdozioneTre.darkBlue, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
