import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/social/social_comments_sheet.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:petping/social/post/social_edit_post_modal.dart';
import 'package:petping/social/social_memoria_firebase.dart';
import 'package:petping/utils/notific_principal.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';

class SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final String currentUserId;
  final Map<String, dynamic> userData;
  final Position? currentPosition;
  final VoidCallback? onDelete;

  const SocialPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.userData,
    this.currentPosition,
    this.onDelete,
  });

  static const List<List<Color>> _gradientPairs = [
    [Color(0xFF6366F1), Color(0xFF818CF8)], 
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)], 
    [Color(0xFFE67E22), Color(0xFFF39C12)], 
    [Color(0xFF64B5B4), Color(0xFF2C5F78)], 
    [Color(0xFFFA709A), Color(0xFFFEE140)], 
    [Color(0xFF00B4D8), Color(0xFF90E0EF)], 
    [Color(0xFF7209B7), Color(0xFFB5179E)], 
    [Color(0xFF4CC9F0), Color(0xFF4361EE)], 
    [Color(0xFFF72585), Color(0xFF7209B7)], 
    [Color(0xFF2ECC71), Color(0xFF27AE60)], 
    [Color(0xFFF1C40F), Color(0xFFF39C12)], 
    [Color(0xFFE74C3C), Color(0xFFC0392B)], 
    [Color(0xFF1ABC9C), Color(0xFF16A085)], 
    [Color(0xFF9B59B6), Color(0xFF8E44AD)], 
    [Color(0xFFFD746C), Color(0xFFFF9068)], 
    [Color(0xFF1D976C), Color(0xFF93F9B9)], 
    [Color(0xFF0052D4), Color(0xFF4364F7)], 
    [Color(0xFFEB3349), Color(0xFFF45C43)], 
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)], 
    [Color(0xFFF09819), Color(0xFFEDDE5D)], 
  ];

  List<Color> _getPostGradient() {
    final int index = post.id.hashCode.abs() % _gradientPairs.length;
    return _gradientPairs[index];
  }

  @override
  Widget build(BuildContext context) {
    bool isEvento = post.categoria == 'eventi';
    String? distanceStr;
    if (currentPosition != null && post.lat != null && post.lng != null) {
      double distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        post.lat!,
        post.lng!,
      );
      if (distance < 1000) {
        distanceStr = "${distance.toStringAsFixed(0)} m";
      } else {
        distanceStr = "${(distance / 1000).toStringAsFixed(1)} km";
      }
    }

    final List<Color> colors = _getPostGradient();
    final mainColor = colors[0];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: mainColor.withOpacity(0.1), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialProfiloUtenteScreen(
                            userId: post.uid,
                            nomeAutore: post.autore,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: post.fotoProfilo != null ? NetworkImage(post.fotoProfilo!) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SocialProfiloUtenteScreen(
                              userId: post.uid,
                              nomeAutore: post.autore,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.autore,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: mainColor)
                          ),
                          Row(
                            children: [
                              if (distanceStr != null) ...[
                                Icon(Icons.location_on_rounded, size: 10, color: Colors.grey.shade400),
                                const SizedBox(width: 2),
                                Text(distanceStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(color: mainColor.withOpacity(0.08), borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  post.ruoloAutore.toUpperCase(),
                                  style: TextStyle(color: mainColor.withOpacity(0.7), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade300, size: 18),
                    onPressed: post.uid == currentUserId ? () => _showPostOptions(context) : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // SEZIONE EVENTO DETTAGLIATA
            if (isEvento && post.eventDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: mainColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 16, color: mainColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('EEEE dd MMMM', context.locale.languageCode).format(post.eventDate!).toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: mainColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Orario Inizio e Fine ACCORPATI
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                post.eventEndDate == null 
                                  ? 'event_start_at'.tr() + DateFormat('HH:mm').format(post.eventDate!)
                                  : 'event_time_range'.tr(args: [DateFormat('HH:mm').format(post.eventDate!), DateFormat('HH:mm').format(post.eventEndDate!)]),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Se finisce in un altro giorno, lo mostriamo sotto in modo compatto
                      if (post.eventEndDate != null && (post.eventEndDate!.day != post.eventDate!.day || post.eventEndDate!.month != post.eventDate!.month)) 
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Row(
                            children: [
                              Icon(Icons.event_repeat_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Text(
                                'event_until'.tr(args: [DateFormat('dd MMMM', context.locale.languageCode).format(post.eventEndDate!).toUpperCase()]),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 16, color: mainColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              post.eventLocation ?? 'event_location_missing'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (post.eventLink != null && post.eventLink!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(post.eventLink!);
                            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.link_rounded, size: 16, color: mainColor),
                              const SizedBox(width: 8),
                              Text('event_link_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blueAccent)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // TESTO POST
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 6, 15, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEvento) ...[
                    Text('label_description_upper'.tr(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1)),
                    const SizedBox(height: 4),
                  ],
                  _buildClickableText(post.testo),
                ],
              ),
            ),

            // IMMAGINE POST
            if (post.immagineUrl != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 350),
                child: Image.network(
                  post.immagineUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(height: 180, color: mainColor.withOpacity(0.05), child: Center(child: CircularProgressIndicator(color: mainColor, strokeWidth: 2)));
                  },
                ),
              ),

            // FOOTER INTERAZIONI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade50)),
              ),
              child: Row(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('post').doc(post.id).collection('likes').snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return _statItem(Icons.favorite_rounded, '$count', mainColor);
                    }
                  ),
                  const SizedBox(width: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('post').doc(post.id).collection('commenti').snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return _statItem(Icons.chat_bubble_rounded, '$count', Colors.grey.shade300);
                    }
                  ),
                  const Spacer(),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('post').doc(post.id).collection('likes').doc(currentUserId).snapshots(),
                    builder: (context, snapshot) {
                      final hasLiked = snapshot.data?.exists ?? false;
                      return _footerIcon(
                        icon: hasLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: hasLiked ? Colors.redAccent : Colors.grey.shade300,
                        onTap: () => _toggleLike(post.id, post.uid),
                      );
                    }
                  ),
                  _footerIcon(icon: Icons.chat_bubble_outline_rounded, color: Colors.grey.shade300, onTap: () => _showCommentsModal(context)),
                  _footerIcon(icon: Icons.share_rounded, color: Colors.grey.shade300, onTap: () => _sharePost()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.6), size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _footerIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.blue),
              title: Text('btn_edit_post'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SocialEditPostModal(post: post, userData: userData),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text('btn_delete_post'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePost(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('dialog_delete_post_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text('dialog_delete_post_msg'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('btn_cancel'.tr().toUpperCase())),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SocialMemoriaFirebase().eliminaPost(post.id, post.immagineUrl);
              if (onDelete != null) onDelete!();
            },
            child: Text('btn_confirm_delete_upper'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(String postId, String postOwnerId) async {
    final likeRef = FirebaseFirestore.instance.collection('post').doc(postId).collection('likes').doc(currentUserId);
    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
      if (postOwnerId != currentUserId) {
        SocialNotificationService().sendNotification(
          toUserId: postOwnerId,
          type: 'like',
          text: 'ha messo mi piace al tuo post',
          postId: postId,
        );
      }
    }
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialCommentsSheet(
        postId: post.id,
        postOwnerId: post.uid,
        currentUserId: currentUserId,
        userData: userData,
      ),
    );
  }

  void _sharePost() {
    final String content = 'share_post_text'.tr(args: [post.autore, post.testo]);
    if (post.immagineUrl != null) {
      Share.share("${content}\n\n${post.immagineUrl}");
    } else {
      Share.share(content);
    }
  }

  Widget _buildClickableText(String text) {
    final RegExp urlRegex = RegExp(r'((https?://)|(www\.))[^\s/$.?#].[^\s]*', caseSensitive: false);
    final Iterable<RegExpMatch> matches = urlRegex.allMatches(text);
    
    const textStyle = TextStyle(fontSize: 14.5, height: 1.4, color: Colors.black87, fontWeight: FontWeight.w600);

    if (matches.isEmpty) return Text(text, style: textStyle);

    final List<TextSpan> spans = [];
    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      final String url = match.group(0)!;
      final String fullUrl = url.startsWith('http') ? url : 'https://$url';
      spans.add(TextSpan(
        text: url,
        style: textStyle.copyWith(color: const Color(0xFF6366F1), fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()..onTap = () async {
          final Uri uri = Uri.parse(fullUrl);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      ));
      lastIndex = match.end;
    }
    if (lastIndex < text.length) spans.add(TextSpan(text: text.substring(lastIndex)));
    return RichText(text: TextSpan(style: textStyle, children: spans));
  }
}
