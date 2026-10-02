import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/b_homes/d_message/chat_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    const Color primaryAzure = Color(0xFF03A9F4);
    const Color deepText = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: deepText),
        title: Text('profile_public_title'.tr(), style: const TextStyle(color: deepText, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('utenti').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryAzure));
          if (!snapshot.hasData || !snapshot.data!.exists) return Center(child: Text('profile_not_found'.tr()));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final vis = Map<String, dynamic>.from(data['visibilita'] ?? {});
          bool visible(String key) => vis[key] == true;

          final String name = data['nome'] ?? '';
          final String surname = data['cognome'] ?? '';
          final String username = data['username'] ?? 'label_user'.tr();
          final String? photoUrl = (data['fotoUrl'] as String?)?.isNotEmpty == true ? data['fotoUrl'] : null;

          final List<dynamic> telefoni = data['telefoni'] ?? [];
          final List<dynamic> emails = data['emails'] ?? [];
          final dynamic whatsappData = data['whatsapp'];
          final List<dynamic> whatsapps = whatsappData is List ? whatsappData : (whatsappData != null ? [whatsappData] : []);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // HEADER SECTION
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: primaryAzure.withOpacity(0.1),
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null ? const Icon(Icons.person, size: 45, color: primaryAzure) : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: deepText, letterSpacing: -0.5)),
                            if (name.isNotEmpty || surname.isNotEmpty)
                              Text("$name $surname", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: deepText.withOpacity(0.5))),
                            const SizedBox(height: 10),
                            if (currentUserId != null && currentUserId != userId)
                              _actionButton(
                                context,
                                Icons.chat_bubble_rounded,
                                'profile_msg_action_upper'.tr(),
                                primaryAzure,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(currentUserId: currentUserId, otherUserId: userId, otherUsername: username, messageService: MessageService()))),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CONTATTI - STILE PREMIUM
                      if (visible('telefoni') || visible('emails') || visible('whatsapp')) ...[
                        _buildSectionTitle('profile_contacts_section_title'.tr()),

                        if (visible('whatsapp'))
                          ...whatsapps.map((w) => _contactCard(Icons.chat_rounded, "WhatsApp", w.toString(), const Color(0xFF25D366), () => launchUrl(Uri.parse('https://wa.me/${w.toString().replaceAll('+', '').replaceAll(' ', '')}')))),

                        if (visible('telefoni'))
                          ...telefoni.map((t) => _contactCard(Icons.phone_rounded, 'profile_label_phones'.tr(), t.toString(), primaryAzure, () => launchUrl(Uri.parse('tel:$t')))),

                        if (visible('emails'))
                          ...emails.map((e) => _contactCard(Icons.email_rounded, 'profile_label_emails'.tr(), e.toString(), Colors.orangeAccent, () => launchUrl(Uri.parse('mailto:$e')))),

                        const SizedBox(height: 25),
                      ],

                      // ALTRE INFO
                      _buildSectionCard(
                        title: 'settings_section_info'.tr(),
                        icon: Icons.info_outline_rounded,
                        color: Colors.blueGrey,
                        content: Column(
                          children: [
                            if (visible('bio') && data['bio'] != null) _detailRow('profile_label_bio'.tr(), data['bio']),
                            if (visible('dataNascita')) _detailRow('profile_birthday_label'.tr(), data['dataNascita']),
                            if (visible('sesso')) _detailRow('profile_label_gender'.tr(), data['sesso']),
                            if (visible('luogo')) ...[
                              _detailRow('profile_label_city'.tr(), data['citta']),
                              _detailRow('profile_label_region'.tr(), data['regione']),
                              _detailRow('profile_label_address'.tr(), data['indirizzo'], isLast: true),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
    );
  }

  Widget _contactCard(IconData icon, String title, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value, {bool isLast = false}) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(width: 20),
          Expanded(child: Text(value.toString(), textAlign: TextAlign.end, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 12))),
        ],
      ),
    );
  }
}
