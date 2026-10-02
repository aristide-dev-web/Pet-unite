import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart';

class AddTreFront extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController viaController;
  final TextEditingController cittaController;
  final TextEditingController regioneController;
  final TextEditingController raccontoController;
  final TextEditingController rewardController;

  final int? selectedDay;
  final int? selectedMonth;
  final int? selectedYear;
  final ValueChanged<int?> onDayChanged;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<int?> onYearChanged;

  final Function(double lat, double lng, String via, String citta, String regione) onPositionConfirmed;
  final VoidCallback onSubmit;

  final double? lat;
  final double? lng;

  static const Color vintageGold = Color(0xFFC5A059);
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color parchment = Color(0xFFFEFAE0);

  const AddTreFront({
    super.key,
    required this.formKey,
    required this.viaController,
    required this.cittaController,
    required this.regioneController,
    required this.raccontoController,
    required this.rewardController,
    required this.selectedDay,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onPositionConfirmed,
    required this.onSubmit,
    this.lat,
    this.lng,
  });

  @override
  State<AddTreFront> createState() => _AddTreFrontState();
}

class _AddTreFrontState extends State<AddTreFront> {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("profile_error_address_not_found".tr())));
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
          _buildLabel('ps_reg_label_location_pet'.tr(), Icons.location_on_rounded),
          
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AddTreFront.vintageGold.withOpacity(0.3), width: 2),
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
                              child: const Icon(Icons.location_on, color: Color(0xFFE67E22), size: 40),
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
                        style: const TextStyle(fontSize: 13, color: AddTreFront.darkBrown),
                        decoration: InputDecoration(
                          hintText: "profile_map_search_hint".tr(),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, size: 18, color: AddTreFront.vintageGold),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: _isSearching 
                            ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: AddTreFront.vintageGold))
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
                          decoration: BoxDecoration(color: AddTreFront.darkBrown, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text("profile_btn_confirm_pos".tr(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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

          Row(
            children: [
              Expanded(child: _buildTextField(controller: widget.viaController, hint: 'profile_label_address'.tr(), icon: Icons.map_rounded)),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _searchAddress("${widget.viaController.text} ${widget.cittaController.text}"),
                icon: const Icon(Icons.gps_fixed_rounded, color: AddTreFront.vintageGold),
                tooltip: "snack_locating".tr(),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField(controller: widget.cittaController, hint: 'profile_label_city'.tr(), icon: Icons.location_city_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(controller: widget.regioneController, hint: 'profile_label_region'.tr(), icon: Icons.explore_rounded)),
            ],
          ),
          const SizedBox(height: 25),

          _buildLabel('sos_add_label_when'.tr(), Icons.calendar_month_rounded),
          Row(
            children: [
              _buildDateDropdown(flex: 2, label: 'GG', value: widget.selectedDay, items: 31, offset: 1, onChanged: widget.onDayChanged),
              const SizedBox(width: 8),
              _buildDateDropdown(flex: 2, label: 'MM', value: widget.selectedMonth, items: 12, offset: 1, onChanged: widget.onMonthChanged),
              const SizedBox(width: 8),
              _buildDateDropdown(flex: 3, label: 'AAAA', value: widget.selectedYear, items: 6, isYear: true, onChanged: widget.onYearChanged),
            ],
          ),
          const SizedBox(height: 25),

          _buildLabel('sos_add_label_story'.tr(), Icons.history_edu_rounded),
          TextFormField(
            controller: widget.raccontoController,
            maxLines: 3,
            style: const TextStyle(color: AddTreFront.darkBrown, fontWeight: FontWeight.w500, fontSize: 14),
            decoration: _inputDecoration('sos_add_story_hint'.tr(), null),
          ),
          const SizedBox(height: 20),
          _buildLabel('sos_add_label_reward'.tr(), Icons.card_giftcard_rounded),
          _buildTextField(
            controller: widget.rewardController, 
            hint: 'sos_add_reward_hint'.tr(), 
            keyboardType: TextInputType.text,
            icon: Icons.monetization_on_rounded,
            bottomPadding: 0
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AddTreFront.darkBrown,
                foregroundColor: AddTreFront.parchment,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.contact_phone_rounded),
                  const SizedBox(width: 12),
                  Text('sos_reg_btn_contacts'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AddTreFront.vintageGold),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AddTreFront.darkBrown, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 18, color: AddTreFront.vintageGold.withOpacity(0.5)) : null,
      hintStyle: TextStyle(color: AddTreFront.darkBrown.withOpacity(0.3), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AddTreFront.darkBrown.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC5A059), width: 2)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, double bottomPadding = 12, TextInputType keyboardType = TextInputType.text, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: TextFormField(
        controller: controller, 
        keyboardType: keyboardType,
        style: const TextStyle(color: AddTreFront.darkBrown, fontWeight: FontWeight.w600, fontSize: 14), 
        decoration: _inputDecoration(hint, icon)
      ),
    );
  }

  Widget _buildDateDropdown({required int flex, required String label, required int? value, required int items, int offset = 0, bool isYear = false, required ValueChanged<int?> onChanged}) {
    return Expanded(
      flex: flex,
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontSize: 10, color: AddTreFront.darkBrown), filled: true, fillColor: Colors.white.withOpacity(0.5), contentPadding: const EdgeInsets.symmetric(horizontal: 10), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AddTreFront.darkBrown.withOpacity(0.1)))),
        items: List.generate(items, (index) {
          final val = isYear ? DateTime.now().year - index : index + offset;
          return DropdownMenuItem(value: val, child: Text(val.toString(), style: const TextStyle(fontSize: 13, color: AddTreFront.darkBrown)));
        }),
        onChanged: onChanged,
      ),
    );
  }
}
