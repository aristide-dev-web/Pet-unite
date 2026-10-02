import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/custodia_animali/custodia_animal_data.dart';
import 'package:petping/utils/prefisso.dart';
import 'package:easy_localization/easy_localization.dart';

class AddCustodiaQuattro extends StatefulWidget {
  final CustodiaAnimalData data;
  const AddCustodiaQuattro({super.key, required this.data});

  @override
  State<AddCustodiaQuattro> createState() => _AddCustodiaQuattroState();
}

class _AddCustodiaQuattroState extends State<AddCustodiaQuattro> {
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color blueSecurity = Color(0xFF2980B9);
  static const Color goldHighlight = Color(0xFFFFC107); 
  
  // CARD DATA
  final List<TextEditingController> _phoneCard = [];
  final List<String> _prefixesCard = [];
  final List<TextEditingController> _whatsappCard = [];
  final List<String> _whatsappPrefixesCard = [];
  final List<TextEditingController> _emailCard = [];
  final TextEditingController _microchipController = TextEditingController();
  bool _mostraContattiCard = true;

  // BIO DATA
  final List<TextEditingController> _phoneBio = [];
  final List<String> _prefixesBio = [];
  final List<TextEditingController> _whatsappBio = [];
  final List<String> _whatsappPrefixesBio = [];
  final List<TextEditingController> _emailBio = [];
  bool _aggiornaContattiBio = false;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _caricaDatiEsistenti();
  }

  Future<void> _caricaDatiEsistenti() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _initVuoti();
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final List<dynamic> emails = data['emails'] ?? [];
      final List<dynamic> telefoni = data['telefoni'] ?? [];
      final dynamic whatsappData = data['whatsapp'];
      
      setState(() {
        if (emails.isNotEmpty) {
          for (var e in emails) {
            _emailCard.add(TextEditingController(text: e.toString()));
            _emailBio.add(TextEditingController(text: e.toString()));
          }
        } else {
          _emailCard.add(TextEditingController());
          _emailBio.add(TextEditingController());
        }
        
        if (telefoni.isNotEmpty) {
          for (var t in telefoni) {
            final split = PrefixSelector.splitPhone(t.toString());
            _phoneCard.add(TextEditingController(text: split["number"]));
            _prefixesCard.add(split["prefix"]!);
            _phoneBio.add(TextEditingController(text: split["number"]));
            _prefixesBio.add(split["prefix"]!);
          }
        } else {
          _phoneCard.add(TextEditingController());
          _prefixesCard.add("+39");
          _phoneBio.add(TextEditingController());
          _prefixesBio.add("+39");
        }

        if (whatsappData != null) {
          final List<dynamic> wsList = whatsappData is List ? whatsappData : [whatsappData];
          for (var w in wsList) {
            final split = PrefixSelector.splitPhone(w.toString());
            _whatsappCard.add(TextEditingController(text: split["number"]));
            _whatsappPrefixesCard.add(split["prefix"]!);
            _whatsappBio.add(TextEditingController(text: split["number"]));
            _whatsappPrefixesBio.add(split["prefix"]!);
          }
        } else {
          _whatsappCard.add(TextEditingController());
          _whatsappPrefixesCard.add("+39");
          _whatsappBio.add(TextEditingController());
          _whatsappPrefixesBio.add("+39");
        }
      });
    } else {
      _initVuoti();
    }
  }

  void _initVuoti() {
    setState(() {
      _phoneCard.add(TextEditingController()); _prefixesCard.add("+39");
      _phoneBio.add(TextEditingController()); _prefixesBio.add("+39");
      _whatsappCard.add(TextEditingController()); _whatsappPrefixesCard.add("+39");
      _whatsappBio.add(TextEditingController()); _whatsappPrefixesBio.add("+39");
      _emailCard.add(TextEditingController());
      _emailBio.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    for (var c in [..._phoneCard, ..._emailCard, ..._whatsappCard, ..._phoneBio, ..._emailBio, ..._whatsappBio, _microchipController]) c.dispose();
    super.dispose();
  }

  Future<void> _submitFinal() async {
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cardPhones = <String>[];
      for(int i=0; i<_phoneCard.length; i++) {
        String n = _phoneCard[i].text.trim();
        if (n.isNotEmpty) cardPhones.add("${_prefixesCard[i]}$n");
      }
      final cardWs = <String>[];
      for(int i=0; i<_whatsappCard.length; i++) {
        String n = _whatsappCard[i].text.trim();
        if (n.isNotEmpty) cardWs.add("${_whatsappPrefixesCard[i]}$n");
      }
      final cardEmails = _emailCard.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      
      final bioPhones = <String>[];
      for(int i=0; i<_phoneBio.length; i++) {
        String n = _phoneBio[i].text.trim();
        if (n.isNotEmpty) bioPhones.add("${_prefixesBio[i]}$n");
      }
      final bioWs = <String>[];
      for(int i=0; i<_whatsappBio.length; i++) {
        String n = _whatsappBio[i].text.trim();
        if (n.isNotEmpty) bioWs.add("${_whatsappPrefixesBio[i]}$n");
      }
      final bioEmails = _emailBio.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

      List<String> imageUrls = [];
      if (widget.data.immagini != null) {
        for (int i = 0; i < widget.data.immagini!.length; i++) {
          String path = 'custodia_pets/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          TaskSnapshot snap = await FirebaseStorage.instance.ref().child(path).putFile(widget.data.immagini![i]);
          imageUrls.add(await snap.ref.getDownloadURL());
        }
      }

      await FirebaseFirestore.instance.collection('animali_custodia').add({
        'uid_utente': user.uid,
        'nome_utente': user.displayName ?? 'Utente PetPing',
        'nome': widget.data.nome ?? 'label_none'.tr(),
        'tipo': widget.data.tipo,
        'razza': widget.data.razza,
        'sesso': widget.data.sesso,
        'immagini': imageUrls,
        'immagine': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'coloreDominante': widget.data.coloreDominante,
        'coloreSecondario': widget.data.coloreSecondario,
        'occhiColore': widget.data.occhiColore,
        'haCicatrici': widget.data.haCicatrici,
        'noteParticolari': widget.data.noteParticolari,
        'via': widget.data.via,
        'citta': widget.data.citta,
        'regione': widget.data.regione,
        'lat': widget.data.lat,
        'lng': widget.data.lng,
        'raccontoDettagliato': widget.data.raccontoDettagliato,
        'dataInizio': widget.data.dataInizio?.toIso8601String(),
        'dataFine': widget.data.dataFine?.toIso8601String(),
        'microchipNumero': _microchipController.text.trim(),
        'contatti_alternativi': {
          'telefoni': cardPhones,
          'emails': cardEmails,
          'whatsapp_list': cardWs,
          'privacy_attiva': _mostraContattiCard,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'stato': 'Trovato',
      });

      if (_aggiornaContattiBio) {
        await FirebaseFirestore.instance.collection('utenti').doc(user.uid).update({
          'telefoni': bioPhones,
          'emails': bioEmails,
          'whatsapp': bioWs,
        });
      }
      
      setState(() => _isSaving = false);
      if (mounted) _showSuccessDialog();

    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('custodia_add_success_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: blueSecurity)),
        content: Text(_aggiornaContattiBio
            ? 'custodia_add_success_bio_msg'.tr()
            : 'custodia_add_success_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).popUntil((route) => route.isFirst),
            child: Text('age_got_it'.tr().toUpperCase(), style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('custodia_add_contact_title'.tr(), style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 14)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildMicrochipPanel(),
              const SizedBox(height: 25),
              
              _buildPanel(
                title: 'custodia_add_card_panel_title'.tr(),
                icon: Icons.style_rounded,
                color: blueSecurity,
                iconColor: goldHighlight,
                isVisible: _mostraContattiCard,
                onToggle: (v) => setState(() => _mostraContattiCard = v),
                phones: _phoneCard,
                prefixes: _prefixesCard,
                whatsapps: _whatsappCard,
                wsPrefixes: _whatsappPrefixesCard,
                emails: _emailCard,
                onAddPhone: () => setState(() { _phoneCard.add(TextEditingController()); _prefixesCard.add("+39"); }),
                onAddWs: () => setState(() { _whatsappCard.add(TextEditingController()); _whatsappPrefixesCard.add("+39"); }),
                onAddEmail: () => setState(() => _emailCard.add(TextEditingController())),
                onRemovePhone: (i) => setState(() { _phoneCard.removeAt(i); _prefixesCard.removeAt(i); }),
                onRemoveWs: (i) => setState(() { _whatsappCard.removeAt(i); _whatsappPrefixesCard.removeAt(i); }),
                onRemoveEmail: (i) => setState(() => _emailCard.removeAt(i)),
              ),

              const SizedBox(height: 25),

              _buildPanel(
                title: 'custodia_add_bio_panel_title'.tr(),
                icon: Icons.account_circle_rounded,
                color: Colors.blue,
                isVisible: _aggiornaContattiBio,
                onToggle: (v) => setState(() => _aggiornaContattiBio = v),
                phones: _phoneBio,
                prefixes: _prefixesBio,
                whatsapps: _whatsappBio,
                wsPrefixes: _whatsappPrefixesBio,
                emails: _emailBio,
                onAddPhone: () => setState(() { _phoneBio.add(TextEditingController()); _prefixesBio.add("+39"); }),
                onAddWs: () => setState(() { _whatsappBio.add(TextEditingController()); _whatsappPrefixesBio.add("+39"); }),
                onAddEmail: () => setState(() => _emailBio.add(TextEditingController())),
                onRemovePhone: (i) => setState(() { _phoneBio.removeAt(i); _prefixesBio.removeAt(i); }),
                onRemoveWs: (i) => setState(() { _whatsappBio.removeAt(i); _whatsappPrefixesBio.removeAt(i); }),
                onRemoveEmail: (i) => setState(() => _emailBio.removeAt(i)),
              ),
              
              const SizedBox(height: 120),
            ],
          ),
          if (_isSaving) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: blueSecurity))),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildMicrochipPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: goldHighlight.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: goldHighlight.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner_rounded, color: goldHighlight, size: 24),
              const SizedBox(width: 12),
              Text('sos_detail_microchip_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: darkBrown, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'custodia_add_microchip_help'.tr(),
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _microchipController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
            decoration: InputDecoration(
              hintText: 'custodia_add_microchip_hint'.tr(),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required IconData icon,
    required Color color,
    Color? iconColor,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: color.withOpacity(0.3), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? color, size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: darkBrown, fontSize: 13, letterSpacing: 0.5)),
              const Spacer(),
              _buildVisibilityBadge(isVisible, onToggle, color),
            ],
          ),
          const SizedBox(height: 25),
          
          _subHeader('custodia_add_phones_header'.tr(), Icons.phone_callback_rounded, color),
          ...phones.asMap().entries.map((e) => _buildInput(e.value, 'custodia_add_phone_label'.tr(), Icons.phone, () => onRemovePhone(e.key), color: color, isPhone: true, prefix: prefixes[e.key], onPrefixTap: () => _pickPrefix(prefixes, e.key))),
          _addBtn('sos_edit_add_phone'.tr(), onAddPhone, color),
          
          const Divider(height: 40),

          _subHeader("WHATSAPP", Icons.chat_rounded, color),
          ...whatsapps.asMap().entries.map((e) => _buildInput(e.value, 'custodia_add_ws_label'.tr(), Icons.chat_rounded, () => onRemoveWs(e.key), color: color, isPhone: true, prefix: wsPrefixes[e.key], onPrefixTap: () => _pickPrefix(wsPrefixes, e.key))),
          _addBtn('profile_btn_add_whatsapp'.tr(), onAddWs, color),

          const Divider(height: 40),
          
          _subHeader('custodia_add_emails_header'.tr(), Icons.email_rounded, color),
          ...emails.asMap().entries.map((e) => _buildInput(e.value, 'custodia_add_email_label'.tr(), Icons.email, () => onRemoveEmail(e.key), color: color, isPhone: false)),
          _addBtn('profile_btn_add_email'.tr(), onAddEmail, color),
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

  void _pickPrefix(List<String> list, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: (p) => setState(() => list[index] = p))));
  }

  Widget _buildInput(TextEditingController c, String h, IconData i, VoidCallback onRem, {required Color color, bool isPhone = true, String? prefix, VoidCallback? onPrefixTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(i, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          
          if (isPhone && prefix != null) ...[
            GestureDetector(
              onTap: onPrefixTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(12)),
                child: Text(prefix, style: const TextStyle(fontWeight: FontWeight.bold, color: darkBrown, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: h,
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF1F3F4),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isVisible ? color.withOpacity(0.1) : Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: isVisible ? color : Colors.grey[400]!, width: 1.5)),
        child: Row(children: [Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 12, color: isVisible ? color : Colors.grey[600]), const SizedBox(width: 6), Text(isVisible ? "PUB".tr().toUpperCase() : "PRI".tr().toUpperCase(), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.blueGrey))])),
    );
  }

  Widget _buildBottomAction() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.white, Colors.white.withOpacity(0)])),
        child: SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: _isSaving ? null : _submitFinal, style: ElevatedButton.styleFrom(backgroundColor: blueSecurity, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text('custodia_add_publish_btn'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)))),
      ),
    );
  }
}
