import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared_servizi_widgets.dart';
import 'specie_selector_widget.dart';

class BenessereSection extends StatefulWidget {
  final String label;
  final IconData icon;
  final String desc;
  final bool isAttivo;
  
  final Map<String, double> prezziTaglia;
  final List<String> opzioniSelezionate;
  final String note;
  final Map<String, List<String>> serviziTaglie;
  
  final Function(String, bool) onServizioToggled;
  final Function(String, double) onPrezzoChanged;
  final Function(String, bool) onOpzioneChanged;
  final Function(String) onNoteChanged;
  final Function(String, String, bool) onTagliaChanged;

  const BenessereSection({
    super.key,
    required this.label,
    required this.icon,
    required this.desc,
    required this.isAttivo,
    required this.prezziTaglia,
    required this.opzioniSelezionate,
    required this.note,
    required this.serviziTaglie,
    required this.onServizioToggled,
    required this.onPrezzoChanged,
    required this.onOpzioneChanged,
    required this.onNoteChanged,
    required this.onTagliaChanged,
  });

  @override
  State<BenessereSection> createState() => _BenessereSectionState();
}

class _BenessereSectionState extends State<BenessereSection> {
  final Color secondaryTextColor = const Color(0xFF64748B);
  final Color textColor = const Color(0xFF1E293B);

  final Map<String, TextEditingController> _priceControllers = {};
  late TextEditingController _noteController;

  final List<String> _prodottiBagnetto = [
    'ps_reg_well_bath_shampoo', 'ps_reg_well_bath_conditioner', 'ps_reg_well_bath_dry', 
    'ps_reg_well_bath_anti', 'ps_reg_well_bath_ears', 'ps_reg_well_bath_nails'
  ];

  final List<String> _strumentiToilettatura = [
    'ps_reg_well_groom_table', 'ps_reg_well_groom_clippers', 'ps_reg_well_groom_scissors', 
    'ps_reg_well_groom_dryer', 'ps_reg_well_groom_tub', 'ps_reg_well_groom_hypo'
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note);
  }

  @override
  void dispose() {
    _priceControllers.values.forEach((c) => c.dispose());
    _noteController.dispose();
    super.dispose();
  }

  TextEditingController _getPriceController(String taglia, double price) {
    if (!_priceControllers.containsKey(taglia)) {
      _priceControllers[taglia] = TextEditingController(
        text: price == 0 ? "" : price.toString().replaceAll('.0', ''),
      );
    }
    return _priceControllers[taglia]!;
  }

  @override
  Widget build(BuildContext context) {
    bool isToilettatura = widget.label.contains('Toilettatura');
    List<String> opzioniDisponibili = isToilettatura ? _strumentiToilettatura : _prodottiBagnetto;
    
    Color accentColor = isToilettatura 
        ? const Color(0xFFF43F5E).withOpacity(0.8)
        : const Color(0xFFEC4899);

    Color cardBg = isToilettatura ? const Color(0xFFFFF1F2) : const Color(0xFFFDF2F8);

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
            onExpansionChanged: (expanded) => widget.onServizioToggled(widget.label, expanded),
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
                  child: Icon(widget.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: widget.isAttivo ? accentColor : textColor, letterSpacing: 1.2)),
                      Text(widget.desc, style: TextStyle(fontSize: 11, color: secondaryTextColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
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
                    _buildSubHeader(isToilettatura ? "ps_reg_well_groom_equip_title".tr() : "ps_reg_well_bath_equip_title".tr(), Icons.auto_awesome_rounded, accentColor),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: opzioniDisponibili.map((key) {
                        final String optLabel = key.tr();
                        final isSelected = widget.opzioniSelezionate.contains(optLabel);
                        return GestureDetector(
                          onTap: () => widget.onOpzioneChanged(optLabel, !isSelected),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? accentColor : SharedServiziWidgets.bgLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? accentColor : Colors.grey.shade200),
                            ),
                            child: Text(optLabel, style: TextStyle(color: isSelected ? Colors.white : secondaryTextColor, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    _buildSubHeader("ps_reg_serv_taglie_prezzi".tr(), Icons.payments_rounded, const Color(0xFF10B981)),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: SharedServiziWidgets.taglieInfo.length,
                      itemBuilder: (context, index) {
                        String key = SharedServiziWidgets.taglieInfo.keys.elementAt(index);
                        var info = SharedServiziWidgets.taglieInfo[key]!;
                        return _buildPriceItem(key, info['label']!, info['icon']!, info['size']!, accentColor);
                      },
                    ),
                    
                    const SizedBox(height: 30),

                    SpecieSelectorWidget(
                      currentSelected: widget.serviziTaglie['${widget.label}-Specie'] ?? [],
                      onSpecieChanged: (s, v) => widget.onTagliaChanged('${widget.label}-Specie', s, v),
                    ),

                    const SizedBox(height: 30),
                    
                    SharedServiziWidgets.buildNoteField(
                      controller: _noteController,
                      onNoteChanged: widget.onNoteChanged,
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

  Widget _buildSubHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildPriceItem(String taglia, String labelInfo, String iconPath, double iconSize, Color highlightColor) {
    double currentPrice = widget.prezziTaglia[taglia] ?? 0.0;
    return Column(
      children: [
        Container(
          height: 55, width: double.infinity,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: SharedServiziWidgets.bgLight, borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Image.asset(iconPath, height: iconSize * 0.8, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.pets, size: 20, color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 4),
        Text(taglia, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
        Text(labelInfo.split('(')[1].replaceAll(')', ''), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: secondaryTextColor)),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: TextField(
            controller: _getPriceController(taglia, currentPrice),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            onChanged: (v) => widget.onPrezzoChanged(taglia, double.tryParse(v.replaceAll(',', '.')) ?? 0.0),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
            decoration: InputDecoration(
              hintText: "€",
              contentPadding: EdgeInsets.zero,
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: highlightColor)),
            ),
          ),
        ),
      ],
    );
  }
}
