import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../utils/image_picker_helper.dart';
import '../../../../utils/image_optimizer.dart';
import 'foto_preview_widget.dart';
import 'serzioni/shared_servizi_widgets.dart';

class SectionBEsperienza extends StatefulWidget {
  final TextEditingController anniEsperienzaController;
  final TextEditingController descrizioneAltroController;
  final TextEditingController bioController; 
  final List<String> specieEsperienza;
  
  final Function(String, bool) onSpecieChanged;

  final double raggioKm;
  final Function(double) onRaggioKmChanged;

  final List<File?> fotoInserzione;
  final List<String> existingFotoUrls;
  final Function(List<File>) onMultiFotoPicked;
  final Function(int) onFotoRemoved;
  final Function(int) onExistingFotoRemoved;

  const SectionBEsperienza({
    super.key,
    required this.anniEsperienzaController,
    required this.descrizioneAltroController,
    required this.bioController, 
    required this.specieEsperienza,
    required this.onSpecieChanged,
    required this.raggioKm,
    required this.onRaggioKmChanged,
    required this.fotoInserzione,
    required this.existingFotoUrls,
    required this.onMultiFotoPicked,
    required this.onFotoRemoved,
    required this.onExistingFotoRemoved,
  });

  @override
  State<SectionBEsperienza> createState() => _SectionBEsperienzaState();
}

class _SectionBEsperienzaState extends State<SectionBEsperienza> {
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color secondaryTextColor = const Color(0xFF64748B);

  bool _isOptimizing = false;

  final List<Map<String, dynamic>> _opzioniSpecie = [
    {'label': 'Cani', 'key': 'ps_specie_dogs', 'emoji': '🐶', 'color': const Color(0xFFFFEDD5), 'text': const Color(0xFF9A3412)},
    {'label': 'Gatti', 'key': 'ps_specie_cats', 'emoji': '🐱', 'color': const Color(0xFFE0F2FE), 'text': const Color(0xFF075985)},
    {'label': 'Conigli', 'key': 'ps_specie_rabbits', 'emoji': '🐰', 'color': const Color(0xFFFCE7F3), 'text': const Color(0xFF9D174D)},
    {'label': 'Volatili', 'key': 'ps_specie_birds', 'emoji': '🐦', 'color': const Color(0xFFF0FDF4), 'text': const Color(0xFF166534)},
    {'label': 'Criceti', 'key': 'ps_specie_hamsters', 'emoji': '🐹', 'color': const Color(0xFFFEF9C3), 'text': const Color(0xFF854D0E)},
    {'label': 'Tartarughe', 'key': 'ps_specie_turtles', 'emoji': '🐢', 'color': const Color(0xFFFEE2E2), 'text': const Color(0xFF991B1B)},
    {'label': 'Altro', 'key': 'ps_specie_other', 'emoji': '➕', 'color': const Color(0xFFF1F5F9), 'text': const Color(0xFF475569)},
  ];

  final List<double> _distanzePossibili = [1, 3, 5, 10, 20, 30, 50, 100, 999];

  void _incrementYears() {
    int current = int.tryParse(widget.anniEsperienzaController.text) ?? 0;
    setState(() {
      widget.anniEsperienzaController.text = (current + 1).toString();
    });
  }

  void _decrementYears() {
    int current = int.tryParse(widget.anniEsperienzaController.text) ?? 0;
    if (current > 0) {
      setState(() {
        widget.anniEsperienzaController.text = (current - 1).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBioValid = widget.bioController.text.length >= 20;

    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 35),

            // 1. BIO
            _buildPokeCard(
              title: "ps_reg_bio_title".tr(),
              subtitle: "ps_reg_bio_subtitle".tr(),
              icon: Icons.auto_stories_rounded,
              color: const Color(0xFFE0E7FF), 
              accentColor: const Color(0xFF818CF8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SharedServiziWidgets.buildNoteField(
                    controller: widget.bioController,
                    onNoteChanged: (v) => setState(() {}),
                    label: "ps_reg_bio_label".tr(),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isBioValid ? const Color(0xFF10B981) : const Color(0xFF818CF8)).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isBioValid ? const Color(0xFF10B981) : const Color(0xFF818CF8)).withOpacity(0.2),
                        width: 1
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBioValid) ...[
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          "${widget.bioController.text.length}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isBioValid ? const Color(0xFF10B981) : const Color(0xFF818CF8),
                          ),
                        ),
                        Text(
                          "ps_reg_bio_char_count".tr(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: (isBioValid ? const Color(0xFF10B981) : const Color(0xFF818CF8)).withOpacity(0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 2. ANNI DI ESPERIENZA
            _buildPokeCard(
              title: "ps_reg_exp_title".tr(),
              subtitle: "ps_reg_exp_subtitle".tr(),
              icon: Icons.history_edu_rounded,
              color: const Color(0xFFFFF1E6), 
              accentColor: const Color(0xFFF59E0B),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularBtn(Icons.remove_rounded, _decrementYears, const Color(0xFFF59E0B)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20), 
                        child: Column(
                          children: [
                            Text(
                              widget.anniEsperienzaController.text.isEmpty ? "0" : widget.anniEsperienzaController.text,
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFFD97706), letterSpacing: -1),
                            ),
                            Text("ps_reg_exp_years_label".tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD97706).withOpacity(0.5), letterSpacing: 1.2)),
                          ],
                        ),
                      ),
                      _buildCircularBtn(Icons.add_rounded, _incrementYears, const Color(0xFFF59E0B)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. SPECIALITÀ
            _buildPokeCard(
              title: "ps_reg_specie_title".tr(),
              subtitle: "ps_reg_specie_subtitle".tr(),
              icon: Icons.pets_rounded,
              color: const Color(0xFFDCFCE7), 
              accentColor: const Color(0xFF10B981),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _opzioniSpecie.map((specie) {
                      final label = specie['label']!;
                      final String key = specie['key']!;
                      final emoji = specie['emoji']!;
                      final pastelBg = specie['color'] as Color;
                      final pastelText = specie['text'] as Color;
                      final isSelected = widget.specieEsperienza.contains(label);
                      return _buildPastelChip(label, key.tr(), emoji, pastelBg, pastelText, isSelected, const Color(0xFF10B981));
                    }).toList(),
                  ),
                  if (widget.specieEsperienza.contains('Altro')) ...[
                    const SizedBox(height: 25),
                    SharedServiziWidgets.buildNoteField(
                      controller: widget.descrizioneAltroController,
                      onNoteChanged: (v) {},
                      label: "ps_reg_specie_other_label".tr(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 4. RAGGIO D'AZIONE
            _buildPokeCard(
              title: "ps_reg_radius_title".tr(),
              subtitle: "ps_reg_radius_subtitle".tr(),
              icon: Icons.directions_car_rounded,
              color: const Color(0xFFE0F2FE), 
              accentColor: const Color(0xFF3B82F6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _distanzePossibili.map((d) {
                      final isSelected = widget.raggioKm == d;
                      final label = d == 999 ? "ps_reg_radius_no_limit".tr() : "${d.toInt()} km";
                      return GestureDetector(
                        onTap: () => widget.onRaggioKmChanged(d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), width: 2),
                            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 5. GALLERY FOTO
            _buildPokeCard(
              title: "ps_reg_gallery_title".tr(),
              subtitle: "ps_reg_gallery_subtitle".tr(),
              icon: Icons.add_a_photo_rounded,
              color: const Color(0xFFF3E5F5), 
              accentColor: const Color(0xFF8B5CF6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SharedServiziWidgets.buildSubLabel(
                    "ps_reg_gallery_info".tr(),
                    icon: Icons.info_outline_rounded
                  ),
                  const SizedBox(height: 20),
                  if (_isOptimizing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                    ),
                  FotoPreviewWidget(
                    files: widget.fotoInserzione,
                    existingUrls: widget.existingFotoUrls,
                    onRemoveFile: widget.onFotoRemoved,
                    onRemoveExisting: widget.onExistingFotoRemoved,
                    onAdd: () async {
                      final picked = await ImagePickerHelper.pickMultiImagesFromGallery();
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
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 30, decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Text("ps_reg_exp_header".tr(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 8),
        Text("ps_reg_exp_sub_header".tr(), style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPokeCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color, 
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.8), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.25), 
            blurRadius: 35, 
            spreadRadius: 2, 
            offset: const Offset(0, 12)
          ),
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, letterSpacing: 1.2)),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: secondaryTextColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildCircularBtn(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.2), width: 2)),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _buildPastelChip(String rawValue, String label, String emoji, Color pastelBg, Color pastelText, bool selected, Color selectedColor) {
    return GestureDetector(
      onTap: () => widget.onSpecieChanged(rawValue, !selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor : pastelBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? selectedColor : Colors.transparent, width: 2),
          boxShadow: selected ? [BoxShadow(color: selectedColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : pastelText)),
          ],
        ),
      ),
    );
  }
}
