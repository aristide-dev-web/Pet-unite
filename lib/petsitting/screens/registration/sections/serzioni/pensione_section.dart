import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/utils/image_picker_helper.dart';
import 'package:petping/utils/image_optimizer.dart';
import 'shared_servizi_widgets.dart';
import 'taglie_selector_widget.dart';
import 'specie_selector_widget.dart';
import '../foto_preview_widget.dart'; 

class PensioneSection extends StatefulWidget {
  final bool isAttivo;
  final Map<String, String> serviziOrari;
  final Map<String, double> serviziPrezzi;
  final Map<String, double> serviziNotturnoExtra;
  final Map<String, List<String>> serviziTaglie;
  final Map<String, int> serviziMaxAnimali;
  final Map<String, String> serviziNote;
  final Map<String, String> serviziCheckIn;
  final Map<String, String> serviziCheckOut;

  final int boardingDailyWalks;
  final List<String> boardingToiletOptions;
  final String boardingToiletFrequency;
  final String boardingHygieneDescription;
  final List<String> boardingSpecialNeeds;
  final String tipoCasa;
  final bool giardino;
  final bool altriAnimali;
  final bool bambini;
  final bool ambienteSicuro;
  final List<File?> fotoCasa;
  final List<String> existingFotoCasaUrls; 

  final Function(String, bool) onServizioToggled;
  final Function(String, String) onOrariChanged;
  final Function(String, double) onPrezzoChanged;
  final Function(String, double) onNotturnoExtraChanged;
  final Function(String, String, bool) onTagliaChanged;
  final Function(String, int) onMaxAnimaliChanged;
  final Function(String, String) onNoteChanged;
  final Function(String, bool) onNotturnoToggled;
  final Function(String, String) onCheckInChanged;
  final Function(String, String) onCheckOutChanged;

  final Function(int) onBoardingDailyWalksChanged;
  final Function(String, bool) onBoardingToiletOptionChanged;
  final Function(String) onBoardingToiletFrequencyChanged;
  final Function(String) onBoardingHygieneDescriptionChanged;
  final Function(String, bool) onBoardingSpecialNeedChanged;
  final Function(String) onTipoCasaChanged;
  final Function(bool) onGiardinoChanged;
  final Function(bool) onAltriAnimaliChanged;
  final Function(bool) onBambiniChanged;
  final Function(bool) onSicuroChanged;
  final Function(List<File>) onMultiFotoPicked;
  final Function(int) onFotoCasaRemoved;
  final Function(int) onExistingFotoCasaRemoved; 

  const PensioneSection({
    super.key,
    required this.isAttivo,
    required this.serviziOrari,
    required this.serviziPrezzi,
    required this.serviziNotturnoExtra,
    required this.serviziTaglie,
    required this.serviziMaxAnimali,
    required this.serviziNote,
    required this.serviziCheckIn,
    required this.serviziCheckOut,
    required this.boardingDailyWalks,
    required this.boardingToiletOptions,
    required this.boardingToiletFrequency,
    required this.boardingHygieneDescription,
    required this.boardingSpecialNeeds,
    required this.tipoCasa,
    required this.giardino,
    required this.altriAnimali,
    required this.bambini,
    required this.ambienteSicuro,
    required this.fotoCasa,
    required this.existingFotoCasaUrls, 
    required this.onServizioToggled,
    required this.onOrariChanged,
    required this.onPrezzoChanged,
    required this.onNotturnoExtraChanged,
    required this.onTagliaChanged,
    required this.onMaxAnimaliChanged,
    required this.onNoteChanged,
    required this.onNotturnoToggled,
    required this.onCheckInChanged,
    required this.onCheckOutChanged,
    required this.onBoardingDailyWalksChanged,
    required this.onBoardingToiletOptionChanged,
    required this.onBoardingToiletFrequencyChanged,
    required this.onBoardingHygieneDescriptionChanged,
    required this.onBoardingSpecialNeedChanged,
    required this.onTipoCasaChanged,
    required this.onGiardinoChanged,
    required this.onAltriAnimaliChanged,
    required this.onBambiniChanged,
    required this.onSicuroChanged,
    required this.onMultiFotoPicked,
    required this.onFotoCasaRemoved,
    required this.onExistingFotoCasaRemoved, 
  });

  @override
  State<PensioneSection> createState() => _PensioneSectionState();
}

class _PensioneSectionState extends State<PensioneSection> {
  final String label = 'Pensione Pet Stop';
  late TextEditingController _basePriceController; 
  late TextEditingController _noteController;
  late TextEditingController _hygieneController;

  final Color accentColor = const Color(0xFF10B981); 
  final Color cardBg = const Color(0xFFECFDF5);

  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    double currentPrice = widget.serviziPrezzi[label] ?? 0.0;
    _basePriceController = TextEditingController(text: currentPrice > 0 ? currentPrice.toString() : "");
    _noteController = TextEditingController(text: widget.serviziNote[label] ?? "");
    _hygieneController = TextEditingController(text: widget.boardingHygieneDescription);
  }

  @override
  void dispose() {
    _basePriceController.dispose();
    _noteController.dispose();
    _hygieneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              if (expanded) {
                widget.onOrariChanged(label, 'entrambi');
                widget.onNotturnoToggled(label, true);
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
                  child: const Icon(Icons.night_shelter_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ps_service_boarding".tr().toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: widget.isAttivo ? accentColor : SharedServiziWidgets.textColor,
                          letterSpacing: 1.2
                        )
                      ),
                      Text(
                        "ps_service_boarding_desc".tr(),
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
                    SharedServiziWidgets.buildSubLabel("ps_reg_boarding_fare_title".tr()),
                    const SizedBox(height: 15),
                    SharedServiziWidgets.buildNumberField(
                      title: "${"ps_reg_boarding_base_price".tr()} (€)",
                      controller: _basePriceController, 
                      onChanged: (v) => widget.onPrezzoChanged(label, double.tryParse(v) ?? 0.0)
                    ),
                    const SizedBox(height: 25),
                    SharedServiziWidgets.buildSubLabel("ps_reg_boarding_check_title".tr()),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildTimePickerField("ps_reg_boarding_checkin".tr(), widget.serviziCheckIn[label] ?? "10:00", (v) => widget.onCheckInChanged(label, v))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTimePickerField("ps_reg_boarding_checkout".tr(), widget.serviziCheckOut[label] ?? "18:00", (v) => widget.onCheckOutChanged(label, v))),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildBoardingToiletSection(),
                    const SizedBox(height: 30),
                    _buildBoardingEnvironmentSection(),
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
                      current: widget.serviziMaxAnimali[label] ?? 0,
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

  Widget _buildTimePickerField(String title, String current, Function(String) onChanged) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: int.parse(current.split(":")[0]), minute: int.parse(current.split(":")[1])),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: accentColor, onPrimary: Colors.white, onSurface: SharedServiziWidgets.textColor),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged("${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: SharedServiziWidgets.bgLight, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: SharedServiziWidgets.secondaryTextColor, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(current, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: SharedServiziWidgets.textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingToiletSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.clean_hands_rounded, color: accentColor, size: 20),
              const SizedBox(width: 10),
              Text("ps_reg_boarding_hygiene_section".tr(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _buildStepSelector(label: "ps_reg_boarding_walks_label".tr(), value: widget.boardingDailyWalks, onChanged: widget.onBoardingDailyWalksChanged)),
              const SizedBox(width: 10),
              Expanded(child: _buildStepSelector(label: "ps_reg_boarding_freq_label".tr(), value: int.tryParse(widget.boardingToiletFrequency.replaceAll(RegExp(r'[^0-9]'), '')) ?? 6, suffix: "h", onChanged: (v) => widget.onBoardingToiletFrequencyChanged("ps_reg_boarding_freq_value".tr(args: [v.toString()])))),
            ],
          ),
          const SizedBox(height: 25),
          SharedServiziWidgets.buildSubLabel("ps_reg_boarding_toilet_loc".tr()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ["ps_reg_boarding_opt_only_out", "ps_reg_boarding_opt_out_pads", "ps_reg_boarding_opt_pads_in", "ps_reg_boarding_opt_fenced"].map((key) {
              final String optLabel = key.tr();
              final isSelected = widget.boardingToiletOptions.contains(optLabel);
              return _buildChoiceChip(label: optLabel, isSelected: isSelected, onTap: () => widget.onBoardingToiletOptionChanged(optLabel, !isSelected), activeColor: accentColor);
            }).toList(),
          ),
          const SizedBox(height: 25),
          SharedServiziWidgets.buildSubLabel("ps_reg_boarding_clean_label".tr()),
          const SizedBox(height: 12),
          TextField(
            controller: _hygieneController,
            maxLines: 2,
            onChanged: widget.onBoardingHygieneDescriptionChanged,
            decoration: InputDecoration(
              hintText: "ps_reg_boarding_clean_hint".tr(),
              filled: true,
              fillColor: SharedServiziWidgets.bgLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 25),
          SharedServiziWidgets.buildSubLabel("ps_reg_boarding_special_title".tr()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ["ps_reg_boarding_opt_senior", "ps_reg_boarding_opt_puppy", "ps_reg_boarding_opt_problems"].map((key) {
              final String optLabel = key.tr();
              final isSelected = widget.boardingSpecialNeeds.contains(optLabel);
              return _buildChoiceChip(label: optLabel, isSelected: isSelected, onTap: () => widget.onBoardingSpecialNeedChanged(optLabel, !isSelected), activeColor: const Color(0xFF10B981));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardingEnvironmentSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_rounded, size: 20, color: accentColor),
              const SizedBox(width: 12),
              Text("ps_reg_boarding_env_title".tr(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor)),
            ],
          ),
          const SizedBox(height: 25),
          DropdownButtonFormField<String>(
            value: widget.tipoCasa.isEmpty ? null : widget.tipoCasa,
            decoration: InputDecoration(
              labelText: "ps_reg_boarding_home_type_label".tr(),
              filled: true,
              fillColor: SharedServiziWidgets.bgLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: ['ps_reg_boarding_home_apt', 'ps_reg_boarding_home_house', 'ps_reg_boarding_home_villa', 'ps_reg_boarding_home_other'].map((key) => DropdownMenuItem(value: key.tr(), child: Text(key.tr(), style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (val) => widget.onTipoCasaChanged(val ?? ""),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: [
              _buildChoiceChip(label: "ps_reg_boarding_chip_garden".tr(), isSelected: widget.giardino, onTap: () => widget.onGiardinoChanged(!widget.giardino), icon: Icons.yard_rounded, activeColor: const Color(0xFF10B981)),
              _buildChoiceChip(label: "ps_reg_boarding_chip_pets".tr(), isSelected: widget.altriAnimali, onTap: () => widget.onAltriAnimaliChanged(!widget.altriAnimali), icon: Icons.pets_rounded, activeColor: const Color(0xFF10B981)),
              _buildChoiceChip(label: "ps_reg_boarding_chip_kids".tr(), isSelected: widget.bambini, onTap: () => widget.onBambiniChanged(!widget.bambini), icon: Icons.child_care_rounded, activeColor: const Color(0xFF10B981)),
              _buildChoiceChip(label: "ps_reg_boarding_chip_safe".tr(), isSelected: widget.ambienteSicuro, onTap: () => widget.onSicuroChanged(!widget.ambienteSicuro), icon: Icons.security_rounded, activeColor: const Color(0xFF10B981)),
            ],
          ),
          const Divider(height: 40),
          SharedServiziWidgets.buildSubLabel("ps_reg_boarding_gallery_label".tr()),
          const SizedBox(height: 20),
          if (_isOptimizing)
            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator())),
          
          FotoPreviewWidget(
            files: widget.fotoCasa,
            existingUrls: widget.existingFotoCasaUrls,
            onRemoveFile: widget.onFotoCasaRemoved,
            onRemoveExisting: widget.onExistingFotoCasaRemoved,
            onAdd: () async {
              final remaining = 6 - (widget.fotoCasa.whereType<File>().length + widget.existingFotoCasaUrls.length);
              if (remaining <= 0) return;
              List<File> picked = await ImagePickerHelper.pickMultiImagesFromGallery();
              if (picked.isNotEmpty) {
                setState(() => _isOptimizing = true);
                List<File> optimized = [];
                for (var f in picked) {
                  optimized.add(await ImageOptimizer.optimize(file: f, quality: 60));
                }
                widget.onMultiFotoPicked(optimized);
                setState(() => _isOptimizing = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({required String label, required bool isSelected, required VoidCallback onTap, IconData? icon, Color? activeColor}) {
    final color = activeColor ?? accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: isSelected ? color : SharedServiziWidgets.bgLight, borderRadius: BorderRadius.circular(18), border: Border.all(color: isSelected ? color : Colors.grey.shade200)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 16, color: isSelected ? Colors.white : SharedServiziWidgets.secondaryTextColor.withOpacity(0.5)),
            if (icon != null) const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : SharedServiziWidgets.secondaryTextColor))
          ]
        ),
      ),
    );
  }

  Widget _buildStepSelector({required String label, required int value, required Function(int) onChanged, String suffix = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: SharedServiziWidgets.secondaryTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: SharedServiziWidgets.bgLight, borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, onPressed: () => onChanged(value > 1 ? value - 1 : 1), icon: Icon(Icons.remove_circle_outline, color: accentColor, size: 20)),
              const SizedBox(width: 4),
              Text("$value$suffix", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 4),
              IconButton(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, onPressed: () => onChanged(value + 1), icon: Icon(Icons.add_circle_outline, color: accentColor, size: 20)),
            ],
          ),
        ),
      ],
    );
  }
}
