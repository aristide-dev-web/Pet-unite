import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/lost_animal_data.dart';
import 'package:petping/utils/prefisso.dart';
import 'package:petping/d_tab_sds/d_smarriti/services/sos_payment_service.dart';
import 'package:petping/d_tab_sds/d_smarriti/services/sos_paywall_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class AddQuattro extends StatefulWidget {
  final LostAnimalData data;

  const AddQuattro({super.key, required this.data});

  @override
  State<AddQuattro> createState() => _AddQuattroState();
}

class _AddQuattroState extends State<AddQuattro> {
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color vintageGold = Color(0xFFC5A059);
  static const Color orangeRescue = Color(0xFFE67E22);
  
  // CARD DATA
  final List<TextEditingController> _phoneCard = [];
  final List<String> _prefixesCard = [];
  final List<TextEditingController> _whatsappCard = [];
  final List<String> _whatsappPrefixesCard = [];
  final List<TextEditingController> _emailCard = [];
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

        if (_phoneCard.isNotEmpty && _whatsappCard.isNotEmpty && _whatsappCard[0].text.isEmpty) {
          _whatsappCard[0].text = _phoneCard[0].text;
          _whatsappPrefixesCard[0] = _prefixesCard[0];
          _whatsappBio[0].text = _phoneBio[0].text;
          _whatsappPrefixesBio[0] = _prefixesBio[0];
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
    for (var c in [..._phoneCard, ..._emailCard, ..._whatsappCard, ..._phoneBio, ..._emailBio, ..._whatsappBio]) c.dispose();
    super.dispose();
  }

  Future<void> _submitFinal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    
    try {
      final paymentService = SosPaymentService();
      bool isFree = await paymentService.canPostFree();
      
      if (!isFree) {
        if (mounted) {
          setState(() => _isSaving = false);
          bool hasPaid = await SosPaywallDialog.show(context);
          if (!hasPaid) return;
          setState(() => _isSaving = true);
        }
      }

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
          String path = 'lost_pets/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          TaskSnapshot snap = await FirebaseStorage.instance.ref().child(path).putFile(widget.data.immagini![i]);
          imageUrls.add(await snap.ref.getDownloadURL());
        }
      }

      await FirebaseFirestore.instance.collection('animali_smarriti').add({
        'uid_utente': user.uid,
        'nome_utente': user.displayName ?? 'Utente PetPing',
        'nome': widget.data.nome,
        'tipo': widget.data.tipo,
        'razza': widget.data.razza,
        'sesso': widget.data.sesso,
        'immagini': imageUrls,
        'immagine': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'coloreDominante': widget.data.coloreDominante,
        'coloreSecondario': widget.data.coloreSecondario,
        'occhiColore': widget.data.occhiColore,
        'occhiForma': widget.data.occhiForma,
        'orecchieGrandezza': widget.data.orecchieGrandezza,
        'codaGrandezza': widget.data.codaGrandezza,
        'haCicatrici': widget.data.haCicatrici,
        'noteCicatrici': widget.data.noteCicatrici,
        'dataSmarrimento': widget.data.dataSmarrimento,
        'via': widget.data.via,
        'citta': widget.data.citta,
        'regione': widget.data.regione,
        'posizione': GeoPoint(widget.data.lat ?? 0, widget.data.lng ?? 0),
        'lat': widget.data.lat,
        'lng': widget.data.lng,
        'raccontoDettagliato': widget.data.raccontoDettagliato,
        'microchip': widget.data.microchip,
        'microchipNumero': widget.data.microchipNumero,
        'ricompensa': widget.data.ricompensa,
        'contatti_alternativi': {
          'telefoni': cardPhones,
          'emails': cardEmails,
          'whatsapp_list': cardWs,
          'privacy_attiva': _mostraContattiCard,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'stato': 'Smarrito',
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
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: anim1,
          child: _EmpatheticSuccessDialog(
            petName: widget.data.nome ?? "il tuo pet",
            updatedBio: _aggiornaContattiBio,
          ),
        );
      },
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "sos_add_contacts_desc".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600, height: 1.4),
                ),
              ),
              const SizedBox(height: 30),
              
              _buildPanel(
                title: 'sos_edit_contacts_card_title'.tr(),
                icon: Icons.style_rounded,
                color: vintageGold,
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
                title: 'sos_edit_contacts_bio_title'.tr(),
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
          if (_isSaving) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: vintageGold))),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildPanel({
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: color.withOpacity(0.3), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: darkBrown, fontSize: 13, letterSpacing: 0.5)),
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
        child: Row(children: [Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 12, color: isVisible ? color : Colors.grey[600]), const SizedBox(width: 6), Text(isVisible ? "PUB".tr().toUpperCase() : "PRI".tr().toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: isVisible ? color : Colors.grey[600]))]),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.white, Colors.white.withOpacity(0)])),
        child: SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: _isSaving ? null : _submitFinal, style: ElevatedButton.styleFrom(backgroundColor: darkBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text('sos_publish_btn'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)))),
      ),
    );
  }
}

class _EmpatheticSuccessDialog extends StatelessWidget {
  final String petName;
  final bool updatedBio;

  const _EmpatheticSuccessDialog({required this.petName, required this.updatedBio});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFEFAE0), // Parchment
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con Icona Animata (Effetto Cuore/Pulsazione)
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE67E22), // Orange Rescue
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icone fluttuanti di sfondo
                  ...List.generate(15, (index) => Positioned(
                    left: (index * 30.0) % 300,
                    top: (index * 20.0) % 180,
                    child: Icon(Icons.pets, color: Colors.white.withOpacity(0.1), size: 20 + (index % 10).toDouble()),
                  )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_rounded, color: Colors.white, size: 80),
                      const SizedBox(height: 10),
                      Text(
                        'sos_success_dialog_header'.tr(),
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                children: [
                  Text(
                    'sos_success_dialog_title'.tr(),
                    style: const TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.w900, fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF4E342E), fontSize: 16, height: 1.5, fontFamily: 'Roboto'),
                      children: [
                        TextSpan(text: 'sos_success_dialog_msg_part1'.tr()),
                        TextSpan(text: petName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE67E22))),
                        TextSpan(text: 'sos_success_dialog_msg_part2'.tr()),
                        TextSpan(
                          text: updatedBio 
                            ? 'sos_success_dialog_bio_updated'.tr()
                            : 'sos_success_dialog_keep_faith'.tr(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Bottone "Abbraccio" finale
                  GestureDetector(
                    onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E342E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFF4E342E).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Center(
                        child: Text(
                          'sos_success_dialog_btn'.tr(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'sos_success_dialog_footer'.tr(),
                    style: TextStyle(color: const Color(0xFF4E342E).withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
