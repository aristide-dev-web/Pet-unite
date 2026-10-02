import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import '../../components/sections/sitter_ui_helpers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class TaxiLocationPicker extends StatefulWidget {
  final SitterProfile sitter;
  final Function(double km, double minutes, String from, String to) onLocationChanged;

  const TaxiLocationPicker({
    super.key,
    required this.sitter,
    required this.onLocationChanged,
  });

  @override
  State<TaxiLocationPicker> createState() => _TaxiLocationPickerState();
}

class _TaxiLocationPickerState extends State<TaxiLocationPicker> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  
  double _distance = 0.0;
  double _durationMinutes = 0.0;
  bool _isLoading = false;

  List<String> _suggestions = [];
  bool _showSuggestionsFrom = false;
  bool _showSuggestionsTo = false;

  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  /// Tenta di ottenere le coordinate tramite il pacchetto geocoding (Sistema Android)
  /// Se fallisce (DeadObjectException), usa il fallback tramite API HTTP (Nominatim)
  Future<List<double>> _getCoords(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return [locations.first.latitude, locations.first.longitude];
      }
    } catch (e) {
      debugPrint("Geocoding nativo fallito, uso fallback HTTP: $e");
    }

    // FALLBACK: Chiamata HTTP a Nominatim se il servizio Android è morto
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1'),
        headers: {'User-Agent': 'PetPingApp/1.0'},
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return [
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon']),
          ];
        }
      }
    } catch (e) {
      debugPrint("Fallback HTTP fallito: $e");
    }
    return [];
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=it'),
        headers: {'User-Agent': 'PetPingApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _suggestions = data.map((item) => item['display_name'].toString()).toList();
        });
      }
    } catch (e) {
      debugPrint("Errore suggerimenti: $e");
    }
  }

  Future<void> _calculateRoute() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSuggestionsFrom = false;
      _showSuggestionsTo = false;
    });

    try {
      // Otteniamo le coordinate con il nuovo metodo robusto (con fallback)
      List<double> startCoords = await _getCoords(_fromController.text);
      List<double> endCoords = await _getCoords(_toController.text);

      if (startCoords.isNotEmpty && endCoords.isNotEmpty) {
        // Usiamo OSRM per il percorso stradale reale
        final url = 'https://router.project-osrm.org/route/v1/driving/${startCoords[1]},${startCoords[0]};${endCoords[1]},${endCoords[0]}?overview=false';
        
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final route = data['routes'][0];
            
            setState(() {
              _distance = route['distance'] / 1000.0; // Da metri a KM
              _durationMinutes = (route['duration'] / 60.0).toDouble(); // Da secondi a Minuti
              _isLoading = false;
            });

            widget.onLocationChanged(_distance, _durationMinutes, _fromController.text, _toController.text);
            return;
          }
        }
      }
      throw Exception("Impossibile trovare le coordinate o il percorso.");
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressInput('taxi_from_label'.tr(), _fromController, _fromFocusNode, Icons.location_on_outlined, (val) {
            _fetchSuggestions(val);
            setState(() {
              _showSuggestionsFrom = true;
              _showSuggestionsTo = false;
            });
          }),
          
          if (_showSuggestionsFrom && _suggestions.isNotEmpty) _buildSuggestionsList(_fromController),
          
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.more_vert, color: Colors.grey, size: 20),
          ),
          
          _buildAddressInput('taxi_to_label'.tr(), _toController, _toFocusNode, Icons.flag_outlined, (val) {
            _fetchSuggestions(val);
            setState(() {
              _showSuggestionsFrom = false;
              _showSuggestionsTo = true;
            });
          }),

          if (_showSuggestionsTo && _suggestions.isNotEmpty) _buildSuggestionsList(_toController),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _calculateRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: SitterUIHelpers.primaryIndigo,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('taxi_calculate_btn'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),

          if (_distance > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: SitterUIHelpers.primaryIndigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('taxi_distance_label'.tr(), "${_distance.toStringAsFixed(1)} KM"),
                  _buildStat('taxi_time_label'.tr(), "${_durationMinutes.toInt()} MIN"),
                  _buildStat('taxi_cost_label'.tr(), "€${(widget.sitter.taxiBaseFare + (_distance * widget.sitter.taxiPricePerKm)).toInt()}"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'taxi_calc_info'.tr(),
              style: const TextStyle(fontSize: 8, color: Colors.grey, fontStyle: FontStyle.italic),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(TextEditingController controller) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: _suggestions.map((s) => ListTile(
          dense: true,
          title: Text(s, style: const TextStyle(fontSize: 12)),
          onTap: () {
            setState(() {
              controller.text = s;
              _suggestions = [];
              _showSuggestionsFrom = false;
              _showSuggestionsTo = false;
              FocusScope.of(context).unfocus();
            });
          },
        )).toList(),
      ),
    );
  }

  Widget _buildAddressInput(String label, TextEditingController controller, FocusNode focusNode, IconData icon, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onTap: () {
            if (!focusNode.hasFocus) {
              focusNode.requestFocus();
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: SitterUIHelpers.primaryIndigo, size: 20),
            hintText: 'map_search_hint'.tr(),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: SitterUIHelpers.primaryIndigo)),
      ],
    );
  }
}