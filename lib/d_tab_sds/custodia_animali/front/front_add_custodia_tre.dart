import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

class FrontAddCustodiaTre extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController viaController;
  final TextEditingController cittaController;
  final TextEditingController regioneController;
  final TextEditingController raccontoController;
  
  final DateTime? selectedInizio;
  final DateTime? selectedFine;
  final Function(DateTime?) onInizioChanged;
  final Function(DateTime?) onFineChanged;
  
  final Function(double lat, double lng, String via, String citta, String regione) onPositionConfirmed;
  final VoidCallback onSubmit;
  final double? lat;
  final double? lng;

  const FrontAddCustodiaTre({
    super.key,
    required this.formKey,
    required this.viaController,
    required this.cittaController,
    required this.regioneController,
    required this.raccontoController,
    this.selectedInizio,
    this.selectedFine,
    required this.onInizioChanged,
    required this.onFineChanged,
    required this.onPositionConfirmed,
    required this.onSubmit,
    this.lat,
    this.lng,
  });

  @override
  State<FrontAddCustodiaTre> createState() => _FrontAddCustodiaTreState();
}

class _FrontAddCustodiaTreState extends State<FrontAddCustodiaTre> {
  late MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _tempPosition;
  bool _isSearching = false;
  bool _showConfirmButton = false;

  static const Color blueSecurity = Color(0xFF2980B9); // Cambiato in Blu
  static const Color darkBrown = Color(0xFF4E342E);

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
    } catch (_) {
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
          _sectionTitle('custodia_add_where_question'.tr(), Icons.map_outlined),
          const SizedBox(height: 15),
          
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: blueSecurity.withOpacity(0.2), width: 2),
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
                      onTap: (_, latlng) => setState(() { _tempPosition = latlng; _showConfirmButton = true; }),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.petping.app',
                      ),
                      if (_tempPosition != null)
                        MarkerLayer(markers: [Marker(point: _tempPosition!, width: 40, height: 40, child: const Icon(Icons.location_on, color: blueSecurity, size: 40))]),
                    ],
                  ),
                  Positioned(
                    top: 10, left: 10, right: 10,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "adozione_add_search_hint".tr(),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, size: 18, color: blueSecurity),
                          suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(icon: const Icon(Icons.send_rounded, size: 18), onPressed: () => _searchAddress(_searchController.text)),
                        ),
                        onSubmitted: _searchAddress,
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
                          decoration: BoxDecoration(color: blueSecurity, borderRadius: BorderRadius.circular(20)),
                          child: Center(child: Text("adozione_add_save_pos".tr(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),
          _buildTextField(widget.viaController, 'custodia_add_address_hint'.tr()),
          Row(
            children: [
              Expanded(child: _buildTextField(widget.cittaController, 'profile_label_city'.tr())),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(widget.regioneController, 'profile_label_region'.tr())),
            ],
          ),

          const SizedBox(height: 30),
          _sectionTitle('custodia_add_when_question'.tr(), Icons.calendar_month_rounded),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _datePickerBtn(context, "custodia_add_date_found".tr(), widget.selectedInizio, widget.onInizioChanged)),
              const SizedBox(width: 10),
              Expanded(child: _datePickerBtn(context, "custodia_add_date_end".tr(), widget.selectedFine, widget.onFineChanged)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'custodia_add_period_info'.tr(),
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 25),
          _sectionTitle('custodia_add_notes_title'.tr(), Icons.description_rounded),
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
            child: TextFormField(controller: widget.raccontoController, maxLines: 4, decoration: InputDecoration(hintText: "custodia_add_notes_hint".tr(), border: InputBorder.none, contentPadding: const EdgeInsets.all(15))),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: blueSecurity, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 6,
                shadowColor: blueSecurity.withOpacity(0.4),
              ),
              child: Text('adozione_add_btn_contacts'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: blueSecurity),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: blueSecurity, letterSpacing: 1)),
    ],
  );

  Widget _buildTextField(TextEditingController c, String h, {IconData? icon}) => Container(
    margin: const EdgeInsets.only(top: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
    child: TextFormField(
      controller: c,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkBrown),
      decoration: InputDecoration(hintText: h, prefixIcon: icon != null ? Icon(icon, color: blueSecurity, size: 20) : null, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)),
    ),
  );

  Widget _datePickerBtn(BuildContext context, String label, DateTime? date, Function(DateTime?) onChanged) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 60)), lastDate: DateTime.now());
        if (d != null) onChanged(d);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey)),
            const SizedBox(height: 5),
            Text(date != null ? "${date.day}/${date.month}/${date.year}" : 'profile_select_placeholder'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: blueSecurity)),
          ],
        ),
      ),
    );
  }
}