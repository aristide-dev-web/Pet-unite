import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/d_message/widgets/booking_request_bubble.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../petsitting/screens/search/components/sections/sitter_ui_helpers.dart';
import '../../../z_google/live_location_service.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String chatId;
  final String currentUserId;
  final String? otherUsername;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.chatId,
    required this.currentUserId,
    this.otherUsername,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == 'booking_request') {
      return BookingRequestBubble(
        message: message,
        isMe: isMe,
        chatId: chatId,
        currentUserId: currentUserId,
      );
    }

    if (message.type == 'security_code') {
      return _buildCodeCard(context);
    }

    if (message.type == 'system') {
      return _buildSystemLabel();
    }

    // GESTIONE GPS LIVE CON TRASFORMAZIONE TASTO REALE
    if (message.type == 'live_location') {
      return _buildLiveLocationBubble(context);
    }

    if (message.text.contains('https://www.google.com/maps')) {
      return _buildLocationBubble(context);
    }

    return _buildTextBubble(context);
  }

  // BOLLA PER IL GPS LIVE (CON ASCOLTO FIRESTORE)
  Widget _buildLiveLocationBubble(BuildContext context) {
    final liveId = message.bookingData?['liveId'];
    if (liveId == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('live_locations').doc(liveId).snapshots(),
      builder: (context, snapshot) {
        bool isActive = true;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          isActive = data['active'] ?? false;
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isActive 
                ? LinearGradient(
                    colors: isMe 
                      ? [Colors.orangeAccent, Colors.orange] 
                      : [const Color(0xFF64B5B4), const Color(0xFF4A908F)],
                  )
                : const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)]), // Grigio se spento
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isActive ? Icons.run_circle_outlined : Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      isActive 
                        ? (isMe ? "location_live_sharing_me".tr() : "location_live_status_active".tr())
                        : (isMe ? "location_live_status_removed".tr() : "location_live_status_stopped".tr()),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 12),
                  if (!isMe)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LiveTrackingScreen(
                          liveId: liveId, 
                          otherUsername: otherUsername ?? "Utente"
                        )));
                      },
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: Text("location_live_btn_follow".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF64B5B4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  if (isMe)
                    TextButton.icon(
                      onPressed: () {
                        // Spegnimento REALE su database
                        FirebaseFirestore.instance.collection('live_locations').doc(liveId).update({'active': false});
                        LiveLocationService.stopSharing();
                      },
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                      label: Text("location_live_btn_stop".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                ],
              ],
            ),
          ),
        );
      }
    );
  }

  // BOLLA PER LA POSIZIONE STATICA
  Widget _buildLocationBubble(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _launchMaps(message.text),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? SitterUIHelpers.primaryIndigo : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, color: isMe ? Colors.white : Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "location_msg_current".tr().toUpperCase(),
                    style: TextStyle(
                      color: isMe ? Colors.white.withOpacity(0.9) : Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "location_view_map".tr(),
                      style: TextStyle(
                        color: isMe ? Colors.white : SitterUIHelpers.primaryIndigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.open_in_new_rounded, size: 14, color: isMe ? Colors.white : SitterUIHelpers.primaryIndigo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchMaps(String text) async {
    final RegExp regex = RegExp(r'(https?://\S+)');
    final match = regex.firstMatch(text);
    if (match != null) {
      final String url = match.group(0)!;
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildSystemLabel() {
    final bool hasEmail = message.text.contains('support.petunite@gmail.com');

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasEmail 
              ? _buildSystemTextWithClickableEmail(message.text)
              : Text(
                  message.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTextWithClickableEmail(String fullText) {
    const email = 'support.petunite@gmail.com';
    final parts = fullText.split(email);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          parts[0],
          style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w800),
        ),
        GestureDetector(
          onTap: () => _launchEmail(),
          child: const Text(
            email,
            style: TextStyle(
              color: SitterUIHelpers.primaryIndigo,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        if (parts.length > 1)
          Text(
            parts[1],
            style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w800),
          ),
      ],
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support.petunite@gmail.com',
      queryParameters: {'subject': 'support_email_subject'.tr()},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Widget _buildCodeCard(BuildContext context) {
    final code = message.text.contains(':')
        ? message.text.split(':').last.trim()
        : message.text;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? [SitterUIHelpers.primaryIndigo, SitterUIHelpers.primaryIndigo.withOpacity(0.8)]
                : [Colors.orangeAccent, Colors.orangeAccent.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isMe ? SitterUIHelpers.primaryIndigo : Colors.orangeAccent).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMe ? Icons.lock_outline_rounded : Icons.vpn_key_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              isMe ? "security_code_mine".tr() : "security_code_received".tr(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBubble(BuildContext context) {
    final bool hasEmail = message.text.contains('support.petunite@gmail.com');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? SitterUIHelpers.primaryIndigo : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: hasEmail 
          ? _buildClickableEmailInText(context)
          : Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : SitterUIHelpers.textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
      ),
    );
  }

  Widget _buildClickableEmailInText(BuildContext context) {
    const email = 'support.petunite@gmail.com';
    final parts = message.text.split(email);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isMe ? Colors.white : SitterUIHelpers.textColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: 'Outfit', // Assumendo il font dell'app
        ),
        children: [
          TextSpan(text: parts[0]),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => _launchEmail(),
              child: Text(
                email,
                style: TextStyle(
                  color: isMe ? Colors.white : SitterUIHelpers.primaryIndigo,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
