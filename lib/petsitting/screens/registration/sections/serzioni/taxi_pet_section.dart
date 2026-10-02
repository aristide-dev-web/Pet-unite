import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared_servizi_widgets.dart';
import 'taglie_selector_widget.dart';

class TaxiPetSection extends StatefulWidget {
  final bool isAttivo;
  final Map<String, String> serviziOrari;
  final double taxiBaseFare;
  final double taxiPricePerKm;
  final double taxiPricePerMin;
  final double taxiNightSurcharge;
  final List<String> taxiSpecieAccettate;
  final Map<String, List<String>> serviziTaglie;
  final Map<String, double> serviziNotturnoExtra;
  final Map<String, int> serviziMaxAnimali;
  final Map<String, String> serviziNote;

  final Function(String, bool) onServizioToggled;
  final Function(String, String) onOrariChanged;
  final Function(double) onTaxiBaseFareChanged;
  final Function(double) onTaxiPricePerKmChanged;
  final Function(double) onTaxiPricePerMinChanged;
  final Function(double) onTaxiNightSurchargeChanged;
  final Function(String, bool) onTaxiSpecieChanged;
  final Function(String, String, bool) onTagliaChanged;
  final Function(String, double) onNotturnoExtraChanged;
  final Function(String, int) onMaxAnimaliChanged;
  final Function(String, String) onNoteChanged;
  final Function(String, bool) onNotturnoToggled;

  const TaxiPetSection({
    super.key,
    required this.isAttivo,
    required this.serviziOrari,
    required this.taxiBaseFare,
    required this.taxiPricePerKm,
    required this.taxiPricePerMin,
    required this.taxiNightSurcharge,
    required this.taxiSpecieAccettate,
    required this.serviziTaglie,
    required this.serviziNotturnoExtra,
    required this.serviziMaxAnimali,
    required this.serviziNote,
    required this.onServizioToggled,
    required this.onOrariChanged,
    required this.onTaxiBaseFareChanged,
    required this.onTaxiPricePerKmChanged,
    required this.onTaxiPricePerMinChanged,
    required this.onTaxiNightSurchargeChanged,
    required this.onTaxiSpecieChanged,
    required this.onTagliaChanged,
    required this.onNotturnoExtraChanged,
    required this.onMaxAnimaliChanged,
    required this.onNoteChanged,
    required this.onNotturnoToggled,
  });

  @override
  State<TaxiPetSection> createState() => _TaxiPetSectionState();
}

class _TaxiPetSectionState extends State<TaxiPetSection> {
  final String label = 'Taxi Pet';
  
  late TextEditingController _baseFareController;
  late TextEditingController _priceKmController;
  late TextEditingController _priceMinController;
  late TextEditingController _nightSurchargeController;
  late TextEditingController _noteController;

  final Color accentColor = const Color(0xFFF59E0B); 
  final Color cardBg = const Color(0xFFFFFBEB);

  final List<Map<String, dynamic>> _opzioniTaxi = [
    {'label': 'Cani', 'key': 'ps_specie_dogs', 'emoji': '🐶', 'color': const Color(0xFFFFEDD5), 'text': const Color(0xFF9A3412)},
    {'label': 'Gatti', 'key': 'ps_specie_cats', 'emoji': '🐱', 'color': const Color(0xFFE0F2FE), 'text': const Color(0xFF075985)},
    {'label': 'Conigli', 'key': 'ps_specie_rabbits', 'emoji': '🐰', 'color': const Color(0xFFFCE7F3), 'text': const Color(0xFF9D174D)},
    {'label': 'Volatili', 'key': 'ps_specie_birds', 'emoji': '🐦', 'color': const Color(0xFFF0FDF4), 'text': const Color(0xFF166534)},
    {'label': 'Altro', 'key': 'ps_specie_other', 'emoji': '➕', 'color': const Color(0xFFF1F5F9), 'text': const Color(0xFF475569)},
  ];

  @override
  void initState() {
    super.initState();
    _baseFareController = TextEditingController(text: widget.taxiBaseFare > 0 ? widget.taxiBaseFare.toString() : "");
    _priceKmController = TextEditingController(text: widget.taxiPricePerKm > 0 ? widget.taxiPricePerKm.toString() : "");
    _priceMinController = TextEditingController(text: widget.taxiPricePerMin > 0 ? widget.taxiPricePerMin.toString() : "");
    _nightSurchargeController = TextEditingController(text: widget.taxiNightSurcharge > 0 ? widget.taxiNightSurcharge.toString() : "");
    _noteController = TextEditingController(text: widget.serviziNote[label] ?? "");
  }

  @override
  void dispose() {
    _baseFareController.dispose();
    _priceKmController.dispose();
    _priceMinController.dispose();
    _nightSurchargeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentOrario = widget.serviziOrari[label] ?? "giorno";
    bool hasNotte = currentOrario == 'notte' || currentOrario == 'entrambi';

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: widget.isAttivo ? accentColor : cardBg, 
            width: 4
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(widget.isAttivo ? 0.15 : 0.05), 
              blurRadius: 20, 
              offset: const Offset(0, 10)
            )
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: widget.isAttivo,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            onExpansionChanged: (expanded) => widget.onServizioToggled(label, expanded),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ps_service_taxi".tr().toUpperCase(), 
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 13, 
                          color: widget.isAttivo ? accentColor : SharedServiziWidgets.textColor, 
                          letterSpacing: 1.2
                        )
                      ),
                      Text(
                        "ps_service_taxi_desc".tr(), 
                        style: TextStyle(
                          fontSize: 11, 
                          color: SharedServiziWidgets.secondaryTextColor.withOpacity(0.7), 
                          fontWeight: FontWeight.w500
                        )
                      ),
                    ],
                  ),
                ),
                if (widget.isAttivo)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
              ],
            ),
            children: [
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeUnitSelector(),
                    const SizedBox(height: 30),
                    SharedServiziWidgets.buildSubLabel("ps_reg_taxi_fare_config".tr()),
                    const SizedBox(height: 15),
                    SharedServiziWidgets.buildNumberField(
                      title: "${"ps_reg_taxi_base".tr()} (€)", 
                      controller: _baseFareController, 
                      onChanged: (v) => widget.onTaxiBaseFareChanged(double.tryParse(v) ?? 0.0)
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: SharedServiziWidgets.buildNumberField(
                            title: "${"ps_reg_taxi_price_km".tr()} (€)", 
                            controller: _priceKmController, 
                            onChanged: (v) => widget.onTaxiPricePerKmChanged(double.tryParse(v) ?? 0.0)
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SharedServiziWidgets.buildNumberField(
                            title: "${"ps_reg_taxi_price_min".tr()} (€)", 
                            controller: _priceMinController, 
                            onChanged: (v) => widget.onTaxiPricePerMinChanged(double.tryParse(v) ?? 0.0)
                          ),
                        ),
                      ],
                    ),
                    if (hasNotte) ...[
                      const SizedBox(height: 25),
                      _buildNightSurchargeSection(),
                    ],
                    const SizedBox(height: 30),
                    SharedServiziWidgets.buildSubLabel("ps_reg_taxi_specie_label".tr()),
                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _opzioniTaxi.map((s) {
                          final String raw = s['label']!;
                          final String key = s['key']!;
                          final bool isSelected = widget.taxiSpecieAccettate.contains(raw);
                          return GestureDetector(
                            onTap: () => widget.onTaxiSpecieChanged(raw, !isSelected),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? accentColor : (s['color'] as Color),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: isSelected ? accentColor : Colors.transparent, width: 2),
                                boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: Row(
                                children: [
                                  Text(s['emoji'] as String, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    key.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : (s['text'] as Color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TaglieSelectorWidget(
                      title: "ps_reg_serv_sizes_accepted".tr(),
                      currentSelected: widget.serviziTaglie[label] ?? [],
                      onTagliaChanged: (s, v) => widget.onTagliaChanged(label, s, v),
                    ),
                    const SizedBox(height: 30),
                    SharedServiziWidgets.buildCounterField(
                      label: label,
                      current: widget.serviziMaxAnimali[label] ?? 1,
                      onMaxAnimaliChanged: (v) => widget.onMaxAnimaliChanged(label, v),
                    ),
                    const SizedBox(height: 30),
                    SharedServiziWidgets.buildNoteField(
                      controller: _noteController,
                      onNoteChanged: (v) => widget.onNoteChanged(label, v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnitSelector() {
    final List<Map<String, dynamic>> units = [
      {'label': 'giorno', 'key': 'ps_reg_serv_day', 'icon': Icons.wb_sunny_rounded}, 
      {'label': 'notte', 'key': 'ps_reg_serv_night', 'icon': Icons.nightlight_round}
    ];
    String current = widget.serviziOrari[label] ?? "giorno";
    return Row(
      children: units.map((unit) {
        final u = unit['label'] as String;
        final key = unit['key'] as String;
        bool selected = (current == 'entrambi') || (current == u);
        return Expanded(
          child: GestureDetector(
            onTap: () {
              String newVal = current == 'entrambi' ? (u == 'giorno' ? 'notte' : 'giorno') : (current == u ? current : 'entrambi');
              widget.onOrariChanged(label, newVal);
              widget.onNotturnoToggled(label, newVal == 'entrambi' || newVal == 'notte');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: selected ? accentColor : SharedServiziWidgets.bgLight, 
                borderRadius: BorderRadius.circular(18), 
                border: Border.all(color: selected ? accentColor : Colors.grey.shade200)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(unit['icon'] as IconData, size: 18, color: selected ? Colors.white : SharedServiziWidgets.secondaryTextColor),
                  const SizedBox(width: 10),
                  Text(key.tr().toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: selected ? Colors.white : SharedServiziWidgets.textColor)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNightSurchargeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: accentColor.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ps_reg_taxi_night_extra_title".tr(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: SharedServiziWidgets.textColor)),
          const SizedBox(height: 15),
          SharedServiziWidgets.buildNumberField(
            title: "${"ps_reg_taxi_night_extra_label".tr()} (%)",
            controller: _nightSurchargeController, 
            onChanged: (v) => widget.onTaxiNightSurchargeChanged(double.tryParse(v) ?? 0.0),
          ),
        ],
      ),
    );
  }
}
