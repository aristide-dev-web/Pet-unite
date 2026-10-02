import 'package:flutter/material.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/services/sitter_service.dart';
import 'package:petping/utils/verification_badges.dart';
import 'sitter_ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';

class SitterInfoSection extends StatefulWidget {
  final SitterProfile sitter;
  final bool isMyProfile;
  final VoidCallback onEditPressed;

  const SitterInfoSection({
    super.key,
    required this.sitter,
    required this.isMyProfile,
    required this.onEditPressed,
  });

  @override
  State<SitterInfoSection> createState() => _SitterInfoSectionState();
}

class _SitterInfoSectionState extends State<SitterInfoSection> {
  bool _isDeleting = false;

  final List<String> _catTrasporto = [
    "ps_reg_equip_carrier_s", "ps_reg_equip_carrier_m", "ps_reg_equip_carrier_l", "ps_reg_equip_kennel",
    "ps_reg_equip_dog_seat", "ps_reg_equip_dog_belt", "ps_reg_equip_seat_cover",
    "ps_reg_equip_car_net", "ps_reg_equip_ramps"
  ];
  final List<String> _catPasseggiate = [
    "ps_reg_equip_harnesses", "ps_reg_equip_leashes", "ps_reg_equip_bags",
    "ps_reg_equip_water_bottle", "ps_reg_equip_snacks"
  ];
  final List<String> _catInCasa = [
    "ps_reg_equip_bed", "ps_reg_equip_fence", "ps_reg_equip_bowls", "ps_reg_equip_scratcher", "ps_reg_equip_litter", "ps_reg_equip_toys"
  ];

  Future<void> _confermaEliminazioneSitter(BuildContext context) async {
    final confermato = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          children: [
            const Icon(Icons.volunteer_activism_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text('sitter_delete_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'sitter_delete_content'.tr(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('btn_cancel'.tr().toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('btn_delete'.tr().toUpperCase(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900))),
        ],
      ),
    );

    if (confermato == true) {
      setState(() => _isDeleting = true);
      try {
        await SitterService().deleteSitterProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('sitter_deleted_success'.tr()), backgroundColor: const Color(0xFFA18CD1), behavior: SnackBarBehavior.floating));
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))));
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF1E293B);
    const Color secondaryTextColor = Color(0xFF64748B);
    const Color coralloPastello = Color(0xFFFCA5A5);

    if (_isDeleting) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFFA18CD1))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isMyProfile) ...[
          _buildEditActionPokeCard(context),
          const SizedBox(height: 32),
        ],

        _buildSectionHeader('sitter_info_title'.tr(), 'sitter_info_subtitle'.tr()),
        const SizedBox(height: 35),

        _buildPokeCard(
          title: 'sitter_bio_title'.tr(),
          subtitle: 'sitter_bio_subtitle'.tr(),
          icon: Icons.favorite_rounded,
          color: coralloPastello.withOpacity(0.15), 
          accentColor: coralloPastello,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: coralloPastello.withOpacity(0.3), width: 2)),
                child: Text(widget.sitter.bio, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9), height: 1.7, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFF6366F1).withOpacity(0.12), const Color(0xFF4F46E5).withOpacity(0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3), width: 2),
                ),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.1), blurRadius: 10)]), child: const Icon(Icons.map_rounded, color: Color(0xFF6366F1), size: 26)),
                    const SizedBox(width: 18),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('sitter_radius_label'.tr(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5), letterSpacing: 1.2)), const SizedBox(height: 4), Text('sitter_radius_desc'.tr(args: [widget.sitter.raggioKm.toInt().toString()]), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))]))
                  ],
                ),
              ),
              if (widget.sitter.prenotazioneLastMinute) ...[
                const SizedBox(height: 15),
                Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5)), child: Row(children: [const Icon(Icons.bolt_rounded, color: Colors.orange, size: 22), const SizedBox(width: 12), Text('sitter_last_minute_label'.tr(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF9A3412)))]))
              ],
            ],
          ),
        ),

        const SizedBox(height: 25),

        _buildPokeCard(
          title: 'sitter_experience_title'.tr(),
          subtitle: 'sitter_experience_subtitle'.tr(),
          icon: Icons.history_edu_rounded,
          color: const Color(0xFFFFF1E6), 
          accentColor: const Color(0xFFF59E0B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Text("${widget.sitter.anniEsperienza}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFD97706), letterSpacing: -1)), const SizedBox(width: 8), Text('sitter_exp_years_label'.tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD97706).withOpacity(0.5), letterSpacing: 1.2))]),
              if (widget.sitter.descrizioneEsperienza.isNotEmpty) ...[const SizedBox(height: 15), Text(widget.sitter.descrizioneEsperienza, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w500, height: 1.5))],
              if (widget.sitter.specieEsperienza.isNotEmpty) ...[const SizedBox(height: 20), Text('sitter_exp_species_header'.tr(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: secondaryTextColor, letterSpacing: 1)), const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: widget.sitter.specieEsperienza.map((s) => SitterUIHelpers.buildEmojiMiniChip(SitterUIHelpers.getEmoji(s), s)).toList())],
              const SizedBox(height: 20),
              SitterUIHelpers.buildSmallSubHeader('sitter_skills_header'.tr(), Icons.checklist_rtl_rounded, const Color(0xFFF59E0B)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: widget.sitter.competenze.map((c) => SitterUIHelpers.buildMiniChip(Icons.done_all_rounded, c)).toList()),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // FORMAZIONE (VIOLA PASTELLO)
        if (widget.sitter.certificazioni.isNotEmpty || widget.sitter.somministrazioneFarmaci || widget.sitter.bisogniSpeciali || widget.sitter.gestioneAnimaliDifficili) ...[
          _buildPokeCard(
            title: 'sitter_training_title'.tr(),
            subtitle: 'sitter_training_subtitle'.tr(),
            icon: Icons.school_rounded,
            color: const Color(0xFFF3E5F5), // Viola Pastello Light
            accentColor: const Color(0xFF8B5CF6), // Viola Accent
            child: Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                if (widget.sitter.somministrazioneFarmaci) VerificationBadges.certification(category: 'ps_reg_med_admin_title'.tr(), size: 24),
                if (widget.sitter.bisogniSpeciali) VerificationBadges.certification(category: 'ps_reg_special_needs_title'.tr(), size: 24),
                if (widget.sitter.gestioneAnimaliDifficili) VerificationBadges.certification(category: 'ps_reg_behavior_mgmt_title'.tr(), size: 24),
                ...widget.sitter.certificazioni.map((certObj) {
                  final cert = certObj as Map<String, dynamic>;
                  return VerificationBadges.certification(category: cert['name']?.toString() ?? 'Certificato', size: 24);
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 25),
        ],

        ..._buildAttrezzaturaSections(textColor),
      ],
    );
  }

  List<Widget> _buildAttrezzaturaSections(Color textColor) {
    List<Widget> sections = [];
    final attr = widget.sitter.attrezzatura;
    final itemsTrasporto = _catTrasporto.where((i) => attr[i] == true).toList();
    if (itemsTrasporto.isNotEmpty) { sections.add(_buildPokeCard(title: 'sitter_equip_transport'.tr(), subtitle: 'sitter_equip_transport_sub'.tr(), icon: Icons.directions_car_rounded, color: const Color(0xFFDCFCE7), accentColor: const Color(0xFF10B981), child: _buildAttrWrap(itemsTrasporto, const Color(0xFF10B981), textColor))); sections.add(const SizedBox(height: 25)); }
    final itemsPasseggiate = _catPasseggiate.where((i) => attr[i] == true).toList();
    if (itemsPasseggiate.isNotEmpty) { sections.add(_buildPokeCard(title: 'sitter_equip_walks'.tr(), subtitle: 'sitter_equip_walks_sub'.tr(), icon: Icons.explore_rounded, color: const Color(0xFFFFF1E6), accentColor: const Color(0xFFFFB347), child: _buildAttrWrap(itemsPasseggiate, const Color(0xFFFFB347), textColor))); sections.add(const SizedBox(height: 25)); }
    final itemsInCasa = _catInCasa.where((i) => attr[i] == true).toList();
    if (itemsInCasa.isNotEmpty) { sections.add(_buildPokeCard(title: 'sitter_equip_home'.tr(), subtitle: 'sitter_equip_home_sub'.tr(), icon: Icons.home_rounded, color: const Color(0xFFFEF9C3), accentColor: const Color(0xFFEAB308), child: _buildAttrWrap(itemsInCasa, const Color(0xFFEAB308), textColor))); sections.add(const SizedBox(height: 25)); }
    if (widget.sitter.attrezzaturaAltro.isNotEmpty) { sections.add(_buildPokeCard(title: 'sitter_equip_other'.tr(), subtitle: 'sitter_equip_other_sub'.tr(), icon: Icons.inventory_2_rounded, color: const Color(0xFFEEF2FF), accentColor: const Color(0xFF6366F1), child: Text(widget.sitter.attrezzaturaAltro, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7), fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)))); sections.add(const SizedBox(height: 25)); }
    return sections;
  }

  Widget _buildAttrWrap(List<String> items, Color accentColor, Color textColor) { return Wrap(spacing: 10, runSpacing: 10, children: items.map((item) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: accentColor.withOpacity(0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle_rounded, size: 14, color: accentColor), const SizedBox(width: 8), Text(item.tr().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textColor))]))).toList()); }
  Widget _buildSectionHeader(String title, String subtitle) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 5, height: 30, decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(10))), const SizedBox(width: 15), Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))]), const SizedBox(height: 8), Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500, height: 1.4))]); }
  Widget _buildPokeCard({required String title, required String subtitle, required IconData icon, required Color color, required Color accentColor, required Widget child}) { return Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: color, width: 4), boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.all(20), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white, size: 22)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, letterSpacing: 1.2)), Text(subtitle, style: TextStyle(fontSize: 11, color: const Color(0xFF64748B).withOpacity(0.7), fontWeight: FontWeight.w500))]))])), const Divider(height: 1, color: Color(0xFFF1F5F9)), Padding(padding: const EdgeInsets.all(20), child: child)])); }
  Widget _buildEditActionPokeCard(BuildContext context) { const Color indigoAccent = Color(0xFF6366F1); return Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: indigoAccent.withOpacity(0.3), width: 3), boxShadow: [BoxShadow(color: indigoAccent.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]), child: Stack(children: [Padding(padding: const EdgeInsets.all(20), child: InkWell(onTap: widget.onEditPressed, borderRadius: BorderRadius.circular(24), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [indigoAccent, Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('sitter_my_profile_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: indigoAccent, letterSpacing: 1.0)), Text('sitter_my_profile_sub'.tr(), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600))])), const SizedBox(width: 10), Icon(Icons.arrow_forward_ios_rounded, color: indigoAccent.withOpacity(0.5), size: 16)]))), Positioned(top: 12, right: 12, child: IconButton(onPressed: () => _confermaEliminazioneSitter(context), icon: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent.withOpacity(0.4), size: 20), tooltip: 'sitter_remove_profile_tooltip'.tr()))])); }
}
