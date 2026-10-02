import 'package:flutter/material.dart';
import 'package:petping/utils/prefisso.dart';
import 'package:easy_localization/easy_localization.dart';

class FrontAddAdozioneQuattro extends StatelessWidget {
  final List<TextEditingController> phoneCard;
  final List<String> prefixesCard;
  final List<TextEditingController> whatsappCard;
  final List<String> whatsappPrefixesCard;
  final List<TextEditingController> emailCard;
  final bool mostraContattiCard;
  final ValueChanged<bool> onToggleCard;

  final List<TextEditingController> phoneBio;
  final List<String> prefixesBio;
  final List<TextEditingController> whatsappBio;
  final List<String> whatsappPrefixesBio;
  final List<TextEditingController> emailBio;
  final bool aggiornaContattiBio;
  final ValueChanged<bool> onToggleBio;

  final Function(bool isBio) onAddPhone;
  final Function(bool isBio) onAddWs;
  final Function(bool isBio) onAddEmail;
  final Function(int index, bool isBio) onRemovePhone;
  final Function(int index, bool isBio) onRemoveWs;
  final Function(int index, bool isBio) onRemoveEmail;
  final VoidCallback onSubmit;

  static const Color greenHope = Color(0xFF27AE60);
  static const Color darkBlue = Color(0xFF2C3E50);

  const FrontAddAdozioneQuattro({
    super.key,
    required this.phoneCard,
    required this.prefixesCard,
    required this.whatsappCard,
    required this.whatsappPrefixesCard,
    required this.emailCard,
    required this.mostraContattiCard,
    required this.onToggleCard,
    required this.phoneBio,
    required this.prefixesBio,
    required this.whatsappBio,
    required this.whatsappPrefixesBio,
    required this.emailBio,
    required this.aggiornaContattiBio,
    required this.onToggleBio,
    required this.onAddPhone,
    required this.onAddWs,
    required this.onAddEmail,
    required this.onRemovePhone,
    required this.onRemoveWs,
    required this.onRemoveEmail,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Text(
            "adozione_contacts_desc".tr(),
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),

        _buildPanel(
          context,
          title: "adozione_on_ad".tr(),
          icon: Icons.assignment_rounded,
          color: greenHope,
          isVisible: mostraContattiCard,
          onToggle: onToggleCard,
          phones: phoneCard,
          prefixes: prefixesCard,
          whatsapps: whatsappCard,
          wsPrefixes: whatsappPrefixesCard,
          emails: emailCard,
          onAddPhone: () => onAddPhone(false),
          onAddWs: () => onAddWs(false),
          onAddEmail: () => onAddEmail(false),
          onRemovePhone: (i) => onRemovePhone(i, false),
          onRemoveWs: (i) => onRemoveWs(i, false),
          onRemoveEmail: (i) => onRemoveEmail(i, false),
          isBio: false,
        ),

        const SizedBox(height: 25),

        _buildPanel(
          context,
          title: "adozione_on_bio".tr(),
          icon: Icons.person_rounded,
          color: Colors.blue,
          isVisible: aggiornaContattiBio,
          onToggle: onToggleBio,
          phones: phoneBio,
          prefixes: prefixesBio,
          whatsapps: whatsappBio,
          wsPrefixes: whatsappPrefixesBio,
          emails: emailBio,
          onAddPhone: () => onAddPhone(true),
          onAddWs: () => onAddWs(true),
          onAddEmail: () => onAddEmail(true),
          onRemovePhone: (i) => onRemovePhone(i, true),
          onRemoveWs: (i) => onRemoveWs(i, true),
          onRemoveEmail: (i) => onRemoveEmail(i, true),
          isBio: true,
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isVisible,
    required ValueChanged<bool> onToggle,
    required List<TextEditingController> phones,
    required List<String> prefixes,
    required List<TextEditingController> whatsapps,
    required List<String> wsPrefixes,
    required List<TextEditingController> emails,
    required VoidCallback onAddPhone,
    required VoidCallback onAddWs,
    required VoidCallback onAddEmail,
    required Function(int) onRemovePhone,
    required Function(int) onRemoveWs,
    required Function(int) onRemoveEmail,
    required bool isBio,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: darkBlue, fontSize: 13, letterSpacing: 0.5)),
              const Spacer(),
              _buildVisibilityBadge(isVisible, onToggle, color),
            ],
          ),
          const SizedBox(height: 25),
          
          _subHeader("adozione_label_phones".tr(), Icons.phone_android, color),
          ...phones.asMap().entries.map((e) => _buildInput(context, e.value, "profile_label_phones".tr(), Icons.phone, () => onRemovePhone(e.key), color: color, isPhone: true, prefix: prefixes[e.key], onPrefixTap: () => _pickPrefix(context, isBio ? phoneBio : phoneCard, prefixes, e.key))),
          _addBtn("adozione_btn_add_phone".tr(), onAddPhone, color),
          
          const Divider(height: 40),

          _subHeader("adozione_label_whatsapp".tr(), Icons.chat, color),
          ...whatsapps.asMap().entries.map((e) => _buildInput(context, e.value, "profile_label_whatsapp".tr(), Icons.chat, () => onRemoveWs(e.key), color: color, isPhone: true, prefix: wsPrefixes[e.key], onPrefixTap: () => _pickPrefix(context, isBio ? whatsappBio : whatsappCard, wsPrefixes, e.key))),
          _addBtn("adozione_btn_add_whatsapp".tr(), onAddWs, color),

          const Divider(height: 40),
          
          _subHeader("adozione_label_email".tr(), Icons.email, color),
          ...emails.asMap().entries.map((e) => _buildInput(context, e.value, "profile_label_emails".tr(), Icons.email, () => onRemoveEmail(e.key), color: color, isPhone: false)),
          _addBtn("adozione_btn_add_email".tr(), onAddEmail, color),
        ],
      ),
    );
  }

  Widget _subHeader(String t, IconData i, Color c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(i, size: 14, color: c),
          const SizedBox(width: 8),
          Text(t, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: c.withOpacity(0.8), letterSpacing: 1.2)),
        ],
      ),
    );
  }

  void _pickPrefix(BuildContext context, List<TextEditingController> controllers, List<String> prefixes, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: (p) {
      prefixes[index] = p;
    })));
  }

  Widget _buildInput(BuildContext context, TextEditingController c, String h, IconData i, VoidCallback onRem, {required Color color, bool isPhone = true, String? prefix, VoidCallback? onPrefixTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (isPhone && prefix != null) ...[
            GestureDetector(
              onTap: onPrefixTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(12)),
                child: Text(prefix, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkBlue)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkBlue),
              decoration: InputDecoration(
                hintText: h,
                filled: true,
                fillColor: const Color(0xFFF1F3F4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
              )
            )
          ),
          IconButton(onPressed: onRem, icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20)),
        ],
      ),
    );
  }

  Widget _addBtn(String t, VoidCallback onTap, Color color) {
    return TextButton.icon(onPressed: onTap, icon: const Icon(Icons.add_circle_outline, size: 16), label: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)));
  }

  Widget _buildVisibilityBadge(bool isVisible, ValueChanged<bool> onTap, Color color) {
    return GestureDetector(
      onTap: () => onTap(!isVisible),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isVisible ? color.withOpacity(0.1) : Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: isVisible ? color : Colors.grey[400]!, width: 1.5)),
        child: Row(children: [Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 12, color: isVisible ? color : Colors.grey[600]), const SizedBox(width: 6), Text(isVisible ? "adozione_status_public".tr() : "adozione_status_private".tr(), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: isVisible ? color : Colors.grey[600]))]),
      ),
    );
  }
}
