import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/d_message/chat_screen.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/modifica_smarriti.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/addanimalsmar/contatore_smarriti.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';

class DettaglioAnimaleScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String currentUserId;
  final String? docId;

  const DettaglioAnimaleScreen({
    super.key,
    required this.data,
    required this.currentUserId,
    this.docId,
  });

  @override
  Widget build(BuildContext context) {
    const Color orangeRescue = Color(0xFFE67E22);
    const Color blueSecurity = Color(0xFF2980B9);
    const Color deepText = Color(0xFF2C3E50);
    const Color goldAccent = Color(0xFFFFC107);

    // LOGICA UNIVERSALE
    final String stato = data['stato'] ?? 'Smarrito';
    final bool isFound = stato == 'Trovato';
    final Color themeColor = isFound ? blueSecurity : orangeRescue;
    final Color alertColor = isFound ? blueSecurity : Colors.redAccent;

    final Map<String, dynamic>? contatti = data['contatti_alternativi'];
    final List<dynamic> telefoni = contatti?['telefoni'] ?? [];
    final List<dynamic> emails = contatti?['emails'] ?? [];
    final String? whatsapp = contatti?['whatsapp'] ?? data['whatsapp'];

    final String? microchip = data['microchipNumero'] ?? data['microchip'];
    final bool hasMicrochip = microchip != null && microchip.toString().trim().isNotEmpty && microchip.toString().toLowerCase() != 'no';

    final bool isMine = currentUserId == data['uid_utente'];

    // Coordinate con parsing sicuro e fallback
    LatLng? markerPosition;
    try {
      double? lat = double.tryParse(data['lat']?.toString() ?? data['latitude']?.toString() ?? '');
      double? lng = double.tryParse(data['lng']?.toString() ?? data['longitude']?.toString() ?? '');
      if (lat != null && lng != null) {
        markerPosition = LatLng(lat, lng);
      } else if (data['posizione'] is GeoPoint) {
        final gp = data['posizione'] as GeoPoint;
        markerPosition = LatLng(gp.latitude, gp.longitude);
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: deepText),
        title: Text(
          isFound ? 'sos_detail_title_found'.tr() : 'sos_detail_title_lost'.tr(),
          style: const TextStyle(color: deepText, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
        ),
        actions: [
          if (isMine && docId != null)
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
              onPressed: () => _showOwnerOptions(context, orangeRescue),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER INFO ---
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
              child: Column(
                children: [
                  _buildStatusBadge(isFound, themeColor),
                  const SizedBox(height: 20),
                  Text(
                    data['nome']?.toUpperCase() ?? 'sos_detail_unknown_name'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: deepText, letterSpacing: -1.5),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: themeColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "${data['tipo'] ?? ''} • ${data['sesso'] ?? 'sos_detail_sex_nd'.tr()}".toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: themeColor, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SEZIONE CONTATTI ---
                  if (!isMine) ...[
                    _buildSectionTitle(isFound ? 'sos_detail_contact_found'.tr() : 'sos_detail_contact_lost'.tr()),
                    const SizedBox(height: 12),
                    _contactCard(context, themeColor, emails, telefoni, whatsapp),
                    const SizedBox(height: 30),
                  ],

                  // --- SEZIONE IDENTIKIT ---
                  _buildSectionCard(
                    title: 'sos_detail_identikit'.tr(),
                    icon: Icons.fingerprint_rounded,
                    color: goldAccent,
                    content: Column(
                      children: [
                        _detailRow('sos_detail_breed_label'.tr(), data['razza'] ?? 'sos_detail_breed_default'.tr(), Icons.pets_rounded, goldAccent),
                        _detailRow('sos_detail_eye_color'.tr(), data['occhiColore'] ?? 'gender_not_specified'.tr(), Icons.remove_red_eye_rounded, goldAccent),
                        _detailRow('sos_detail_coat'.tr(), "${data['coloreDominante'] ?? ''} ${data['coloreSecondario'] ?? ''}", Icons.palette_rounded, goldAccent),
                        _detailRow('sos_detail_physical_features'.tr(), "${'sos_detail_ears'.tr()} ${data['orecchieGrandezza'] ?? 'gender_not_specified'.tr()}, ${'sos_detail_tail'.tr()} ${data['codaGrandezza'] ?? 'gender_not_specified'.tr()}", Icons.straighten_rounded, goldAccent),
                        _detailRow('sos_detail_special_marks'.tr(), (data['haCicatrici'] ?? false) ? 'sos_detail_has_scars'.tr() : 'sos_detail_no_marks'.tr(), Icons.healing_rounded, goldAccent, isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- SEZIONE LUOGO E NOTE ---
                  _buildSectionCard(
                    title: isFound ? 'sos_detail_event_found'.tr() : 'sos_detail_event_lost'.tr(),
                    icon: isFound ? Icons.location_searching_rounded : Icons.history_toggle_off_rounded,
                    color: alertColor,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (markerPosition != null)
                          _buildMiniMap(markerPosition, alertColor),

                        _detailRow('sos_detail_event_date'.tr(), isFound ? (data['dataInizio'] ?? data['data_ritrovamento']) : (data['dataSmarrimento'] ?? data['data_smarrimento']), Icons.calendar_today_rounded, alertColor),
                        _detailRow('sos_detail_address'.tr(), data['via'] ?? data['indirizzo'] ?? 'sos_detail_address_nd'.tr(), Icons.map_rounded, alertColor),
                        _detailRow('profile_label_city'.tr(), data['citta'] ?? data['città'] ?? 'gender_not_specified'.tr(), Icons.location_city_rounded, alertColor),
                        _detailRow('sos_detail_region'.tr(), data['regione'] ?? data['provincia'] ?? 'gender_not_specified'.tr(), Icons.explore_outlined, alertColor),

                        if (hasMicrochip) ...[
                          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(height: 1)),
                          _buildMicrochipDisplay(microchip.toString(), alertColor),
                        ],

                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Icon(Icons.notes_rounded, size: 16, color: alertColor.withOpacity(0.7)),
                            const SizedBox(width: 8),
                            Text(isFound ? 'sos_detail_story_found'.tr() : 'sos_detail_story_lost'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                          child: Text(
                            data['raccontoDettagliato'] ?? data['racconto_dettagliato'] ?? data['note'] ?? 'sos_detail_story_empty'.tr(),
                            style: const TextStyle(fontSize: 14, color: deepText, height: 1.6, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DI SUPPORTO ---

  Widget _buildStatusBadge(bool isFound, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isFound ? Icons.verified_user_rounded : Icons.warning_amber_rounded, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            isFound ? 'sos_detail_badge_found'.tr() : 'sos_detail_badge_sos'.tr(),
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value, IconData icon, Color themeColor, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: themeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 0.5)),
                Text(value?.toString() ?? 'gender_not_specified'.tr(), style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicrochipDisplay(String code, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('sos_detail_microchip_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: Colors.grey)),
              Text('sos_detail_microchip_sub'.tr(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          SelectableText(code, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _contactCard(BuildContext context, Color color, List emails, List telefoni, String? whatsapp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _contactTile(Icons.chat_bubble_rounded, 'sos_detail_msg_in_app'.tr(), 'sos_detail_msg_internal'.tr(), color, () => _openInternalChat(context)),
          if (whatsapp != null && whatsapp.toString().isNotEmpty)
            _contactTile(Icons.chat_rounded, 'sos_detail_whatsapp'.tr(), whatsapp.toString(), const Color(0xFF25D366), () => _launch('https://wa.me/${whatsapp.replaceAll('+', '').replaceAll(' ', '')}')),
          ...telefoni.map((t) => _contactTile(Icons.phone_forwarded_rounded, 'sos_detail_call'.tr(), t.toString(), Colors.green, () => _launch('tel:$t'))),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String title, String value, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
      subtitle: Text(value, style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }

  Widget _buildMiniMap(LatLng position, Color color) {
    return Container(
      height: 180, width: double.infinity, margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey[200]!)),
      child: FlutterMap(
        options: MapOptions(initialCenter: position, initialZoom: 15.0),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.petping.app'),
          MarkerLayer(markers: [Marker(point: position, width: 60, height: 60, child: Icon(Icons.location_on_rounded, color: color, size: 45))]),
        ],
      ),
    );
  }

  void _openInternalChat(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(currentUserId: currentUserId, otherUserId: data['uid_utente'] ?? '', otherUsername: data['nome_utente'] ?? 'label_user'.tr(), messageService: MessageService())));
  }

  Future<void> _launch(String url) async => await launchUrl(Uri.parse(url));

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1));

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required Widget content}) => Container(
    width: double.infinity, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 25, offset: const Offset(0, 10))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 20, color: color), const SizedBox(width: 10), Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color, letterSpacing: 0.5))]),
      const SizedBox(height: 25),
      content
    ]),
  );

  void _showOwnerOptions(BuildContext context, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.blue),
              title: Text('sos_edit_report'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ModificaSmarriti(docId: docId!, initialData: data)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: Text('sos_delete_report'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                // Inserire logica delete qui
              },
            ),
          ],
        ),
      ),
    );
  }
}