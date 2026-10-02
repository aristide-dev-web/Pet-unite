import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared_servizi_widgets.dart';
import 'taglie_selector_widget.dart';
import 'specie_selector_widget.dart';

class FarmaciSection extends StatefulWidget {
  final bool isAttivo;
  final Map<String, String> serviziOrari;
  final Map<String, double> serviziPrezzi;
  final Map<String, double> serviziNotturnoExtra;
  final Map<String, List<String>> serviziTaglie;
  final Map<String, int> serviziMaxAnimali;
  final Map<String, String> serviziNote;

  final Function(String, bool) onServizioToggled;
  final Function(String, String) onOrariChanged;
  final Function(String, double) onPrezzoChanged;
  final Function(String, double) onNotturnoExtraChanged;
  final Function(String, String, bool) onTagliaChanged;
  final Function(String, int) onMaxAnimaliChanged;
  final Function(String, String) onNoteChanged;
  final Function(String, bool) onNotturnoToggled;

  const FarmaciSection({
    super.key,
    required this.isAttivo,
    required this.serviziOrari,
    required this.serviziPrezzi,
    required this.serviziNotturnoExtra,
    required this.serviziTaglie,
    required this.serviziMaxAnimali,
    required this.serviziNote,
    required this.onServizioToggled,
    required this.onOrariChanged,
    required this.onPrezzoChanged,
    required this.onNotturnoExtraChanged,
    required this.onTagliaChanged,
    required this.onMaxAnimaliChanged,
    required this.onNoteChanged,
    required this.onNotturnoToggled,
  });

  @override
  State<FarmaciSection> createState() => _FarmaciSectionState();
}

class _FarmaciSectionState extends State<FarmaciSection> {
  final String label = 'Somministrazione farmaci';
  final Map<String, TextEditingController> _priceControllers = {};
  late TextEditingController _noteController;

  final Color accentColor = const Color(0xFFF43F5E); 
  final Color cardBg = const Color(0xFFFFF1F2); 

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.serviziNote[label] ?? "");
  }

  @override
  void didUpdateWidget(FarmaciSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.serviziNote[label] != _noteController.text) {
      _noteController.text = widget.serviziNote[label] ?? "";
    }
  }

  @override
  void dispose() {
    _priceControllers.values.forEach((c) => c.dispose());
    _noteController.dispose();
    super.dispose();
  }

  TextEditingController _getPriceController(String key, String initialValue) {
    if (!_priceControllers.containsKey(key)) {
      _priceControllers[key] = TextEditingController(text: initialValue == "0.0" || initialValue == "0" ? "" : initialValue);
    }
    return _priceControllers[key]!;
  }

  void _showNightInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: accentColor),
            const SizedBox(width: 10),
            Text("ps_reg_serv_night_fare".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text("ps_reg_serv_night_fare_desc_extra".tr(), style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("age_got_it".tr().toUpperCase(), style: TextStyle(color: accentColor, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
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
            onExpansionChanged: (expanded) {
              widget.onServizioToggled(label, expanded);
              if (expanded && (widget.serviziOrari[label] == null || widget.serviziOrari[label]!.isEmpty)) {
                widget.onOrariChanged(label, 'giorno');
              }
            },
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
                  child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ps_service_medicine".tr().toUpperCase(), 
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 13, 
                          color: widget.isAttivo ? accentColor : SharedServiziWidgets.textColor, 
                          letterSpacing: 1.2
                        )
                      ),
                      Text(
                        "ps_service_medicine_desc".tr(), 
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
                    SharedServiziWidgets.buildSubLabel("ps_reg_serv_day_fare_label".tr()),
                    const SizedBox(height: 15),
                    SharedServiziWidgets.buildNumberField(
                      title: "${"ps_reg_serv_day_price".tr()} (€)", 
                      controller: _getPriceController('$label-base', (widget.serviziPrezzi[label] ?? 0.0).toString()), 
                      onChanged: (v) => widget.onPrezzoChanged(label, double.tryParse(v) ?? 0.0)
                    ),
                    if (hasNotte) ...[
                      const SizedBox(height: 25),
                      _buildNightSupplementSection(),
                    ],
                    const SizedBox(height: 30),
                    SpecieSelectorWidget(
                      currentSelected: widget.serviziTaglie['$label-Specie'] ?? [],
                      onSpecieChanged: (s, v) => widget.onTagliaChanged('$label-Specie', s, v),
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

  Widget _buildNightSupplementSection() {
    double extra = widget.serviziNotturnoExtra[label] ?? 0.0;
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
          Text("ps_reg_serv_night_fare".tr(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: SharedServiziWidgets.textColor)),
          const SizedBox(height: 15),
          SharedServiziWidgets.buildNumberField(
            title: "${"ps_reg_serv_night_extra".tr()} (€)",
            controller: _getPriceController('$label-notturno', extra.toString()), 
            onChanged: (v) => widget.onNotturnoExtraChanged(label, double.tryParse(v) ?? 0.0),
            onHelpTap: _showNightInfoDialog,
          ),
        ],
      ),
    );
  }
}
