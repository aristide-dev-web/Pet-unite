import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/utils/image_picker_helper.dart';
import 'package:petping/utils/verification_badges.dart';
import 'package:petping/utils/image_optimizer.dart';

class SectionEPreferenze extends StatefulWidget {
  final List<Map<String, dynamic>> certifications;
  final Function(File, String, String?) onCertificationAdded;
  final Function(int) onCertificationRemoved;

  final List<String> selectedSkills;
  final Function(String, bool) onSkillToggled;

  final bool bisogniSpeciali;
  final bool somministrazioneFarmaci;
  final bool gestioneAnimaliDifficili;
  final Function(bool) onBisogniSpecialiChanged;
  final Function(bool) onFarmaciChanged;
  final Function(bool) onDifficiliChanged;

  const SectionEPreferenze({
    super.key,
    required this.certifications,
    required this.onCertificationAdded,
    required this.onCertificationRemoved,
    required this.selectedSkills,
    required this.onSkillToggled,
    required this.bisogniSpeciali,
    required this.somministrazioneFarmaci,
    required this.gestioneAnimaliDifficili,
    required this.onBisogniSpecialiChanged,
    required this.onFarmaciChanged,
    required this.onDifficiliChanged,
  });

  @override
  State<SectionEPreferenze> createState() => _SectionEPreferenzeState();
}

class _SectionEPreferenzeState extends State<SectionEPreferenze> {
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color secondaryTextColor = const Color(0xFF64748B);

  final Map<String, List<String>> _competenzePerCategoria = {
    "ps_reg_skill_cat_dogs": [
      "ps_reg_skill_reactive_dogs",
      "ps_reg_skill_anxious_dogs",
      "ps_reg_skill_senior_dogs",
      "ps_reg_skill_puppies",
      "ps_reg_skill_basic_training",
      "ps_reg_skill_adv_training",
      "ps_reg_skill_dog_social",
      "ps_reg_skill_large_dogs",
    ],
    "ps_reg_skill_cat_cats": [
      "ps_reg_skill_aggr_cats",
      "ps_reg_skill_senior_cats",
      "ps_reg_skill_cat_ethology",
      "ps_reg_skill_cat_social",
    ],
    "ps_reg_skill_cat_health": [
      "ps_reg_skill_med_admin",
      "ps_reg_skill_first_aid",
      "ps_reg_skill_vet_emergencies",
    ],
    "ps_reg_skill_cat_general": [
      "ps_reg_skill_pet_ethology",
      "ps_reg_skill_pet_nutrition",
      "ps_reg_skill_pet_therapy",
    ],
  };

  final List<String> _categorieCertificazioni = [
    "ps_reg_cert_first_aid",
    "ps_reg_cert_pro_dog_sitter",
    "ps_reg_cert_pro_cat_sitter",
    "ps_reg_cert_behavior",
    "ps_reg_cert_basic_vet",
    "ps_reg_cert_safety",
    "ps_reg_cert_general",
    "ps_reg_cert_enci",
    "ps_reg_cert_fci",
    "ps_reg_cert_grooming",
    "ps_reg_cert_basic_training",
    "ps_reg_cert_adv_training",
    "ps_reg_cert_ethology",
    "ps_reg_cert_nutrition",
    "ps_reg_cert_reactive_dogs",
    "ps_reg_cert_puppies",
    "ps_reg_cert_cats",
    "ps_reg_cert_therapy",
    "ps_reg_cert_wellbeing"
  ];

  void _showAddCertificationDialog() {
    File? pickedImage;
    String? selectedCategoryKey;
    bool isOptimizing = false;
    final yearController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("ps_reg_cert_dialog_title".tr(), style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final file = await ImagePickerHelper.pickImageFromGallery();
                    if (file != null) {
                      setDialogState(() => isOptimizing = true);
                      final optimized = await ImageOptimizer.optimize(file: file, quality: 60);
                      setDialogState(() {
                        pickedImage = optimized;
                        isOptimizing = false;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: isOptimizing 
                      ? const Center(child: CircularProgressIndicator())
                      : (pickedImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(pickedImage!, fit: BoxFit.cover))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_rounded, color: Colors.blueAccent, size: 40),
                              const SizedBox(height: 8),
                              Text("ps_reg_cert_dialog_photo_label".tr(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          )),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCategoryKey,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "ps_reg_cert_dialog_type_label".tr(),
                    labelStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return _categorieCertificazioni.map<Widget>((String key) {
                      return Text(
                        key.tr(),
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }).toList();
                  },
                  items: _categorieCertificazioni.map((key) {
                    return DropdownMenuItem(
                      value: key, 
                      child: Text(key.tr(), style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategoryKey = val),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "ps_reg_cert_dialog_year_label".tr(),
                    labelStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("btn_cancel".tr(), style: TextStyle(color: secondaryTextColor))),
            ElevatedButton(
              onPressed: () {
                if (pickedImage == null || selectedCategoryKey == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ps_reg_cert_dialog_error".tr())));
                  return;
                }
                widget.onCertificationAdded(pickedImage!, selectedCategoryKey!.tr(), yearController.text.trim().isEmpty ? null : yearController.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("btn_save".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 35),

            _buildExpansionPokeCard(
              title: "ps_reg_cert_section_title".tr(),
              subtitle: "ps_reg_cert_section_sub".tr(),
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFFF3E5F5), 
              accentColor: Colors.purple,
              child: Column(
                children: [
                  if (widget.certifications.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.certifications.length,
                      itemBuilder: (context, index) {
                        final cert = widget.certifications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: cert['file'] != null 
                                      ? FileImage(cert['file'] as File) as ImageProvider
                                      : NetworkImage(cert['url'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: VerificationBadges.certification(category: cert['name'], size: 20),
                                        ),
                                      ],
                                    ),
                                    if (cert['year'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 4),
                                        child: Text("${"ps_reg_cert_year_label".tr()}: ${cert['year']}", style: TextStyle(color: secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => widget.onCertificationRemoved(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showAddCertificationDialog,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: Text("ps_reg_cert_btn_upload".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            ..._competenzePerCategoria.entries.map((entry) {
              final colorInfo = _getColorInfoForCategory(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: _buildExpansionPokeCard(
                  title: entry.key.tr(),
                  subtitle: "ps_reg_skill_view_sub".tr(),
                  icon: _getIconForCategory(entry.key),
                  color: colorInfo['bg']!,
                  accentColor: colorInfo['accent']!,
                  child: Column(
                    children: entry.value.map((skillKey) {
                      final String skillLabel = skillKey.tr();
                      bool isSelected = widget.selectedSkills.contains(skillLabel);
                      bool isVerified = widget.certifications.any((c) => c['name'] == skillLabel);
                      
                      return Column(
                        children: [
                          CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) => widget.onSkillToggled(skillLabel, val ?? false),
                            title: Row(
                              children: [
                                Expanded(child: Text(skillLabel, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor))),
                                if (isVerified)
                                  const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                              ],
                            ),
                            activeColor: colorInfo['accent'],
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          if (entry.value.last != skillKey) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 25),

            _buildExpansionPokeCard(
              title: "ps_reg_special_cases_title".tr(),
              subtitle: "ps_reg_special_cases_sub".tr(),
              icon: Icons.star_rounded,
              color: const Color(0xFFFFF1E6), 
              accentColor: const Color(0xFFFFB347),
              child: Column(
                children: [
                  _buildPremiumToggle(
                    "ps_reg_special_needs_title".tr(),
                    "ps_reg_special_needs_sub".tr(),
                    widget.bisogniSpeciali,
                    widget.onBisogniSpecialiChanged,
                    Icons.favorite_rounded,
                    iconBgColor: const Color(0xFFFCE7F3),
                    iconColor: const Color(0xFF9D174D),
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _buildPremiumToggle(
                    "ps_reg_med_admin_title".tr(),
                    "ps_reg_med_admin_sub".tr(),
                    widget.somministrazioneFarmaci,
                    widget.onFarmaciChanged,
                    Icons.medical_services_rounded,
                    iconBgColor: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF075985),
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _buildPremiumToggle(
                    "ps_reg_behavior_mgmt_title".tr(),
                    "ps_reg_behavior_mgmt_sub".tr(),
                    widget.gestioneAnimaliDifficili,
                    widget.onDifficiliChanged,
                    Icons.psychology_rounded,
                    iconBgColor: const Color(0xFFFEF9C3),
                    iconColor: const Color(0xFF854D0E),
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

  Map<String, Color> _getColorInfoForCategory(String key) {
    if (key.contains("dogs") || key.contains("cats")) {
      return {'bg': const Color(0xFFE0F2FE), 'accent': Colors.blueAccent};
    }
    if (key.contains("health")) {
      return {'bg': const Color(0xFFFFEBEE), 'accent': const Color(0xFFF06292)};
    }
    return {'bg': const Color(0xFFDCFCE7), 'accent': const Color(0xFF388E3C)};
  }

  IconData _getIconForCategory(String key) {
    if (key.contains("dogs") || key.contains("cats")) return Icons.pets_rounded;
    if (key.contains("health")) return Icons.health_and_safety_rounded;
    return Icons.psychology_rounded;
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 30, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Text("ps_reg_skills_header".tr(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor)),
          ],
        ),
        const SizedBox(height: 8),
        Text("ps_reg_skills_sub_header".tr(), style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildExpansionPokeCard({
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
        border: Border.all(color: color, width: 4),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
      ), 
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
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
          children: [
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumToggle(
    String title, 
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    {Color? iconBgColor, Color? iconColor}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBgColor ?? Colors.blueAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor ?? Colors.blueAccent, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textColor)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: secondaryTextColor.withOpacity(0.7))),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch.adaptive(
              value: value, 
              onChanged: onChanged,
              activeColor: const Color(0xFF10B981),
              activeTrackColor: const Color(0xFF10B981).withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
