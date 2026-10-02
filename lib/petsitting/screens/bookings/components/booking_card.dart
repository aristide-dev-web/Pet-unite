import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:petping/petsitting/models/booking_model.dart';
import 'package:petping/petsitting/services/booking_service.dart';
import 'package:petping/b_homes/d_message/chat_screen.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class BookingCard extends StatefulWidget {
  final PetBooking booking;
  final bool isSitterView;
  final Color primaryColor;
  final Map<String, dynamic> rawDoc;

  const BookingCard({
    super.key,
    required this.booking, 
    required this.isSitterView, 
    required this.primaryColor,
    required this.rawDoc,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isProcessing = false;

  DateTime _getStartDateTime() {
    DateTime startDateTime = widget.booking.startDate;
    if (widget.booking.checkInTime.isNotEmpty) {
      try {
        final parts = widget.booking.checkInTime.split(':');
        startDateTime = DateTime(
          startDateTime.year,
          startDateTime.month,
          startDateTime.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      } catch (_) {
        debugPrint("Errore parsing orario: ${widget.booking.checkInTime}");
      }
    }
    return startDateTime;
  }

  bool _isServiceStarted() {
    return DateTime.now().isAfter(_getStartDateTime());
  }

  double _getRemainingHours() {
    return _getStartDateTime().difference(DateTime.now()).inMinutes / 60.0;
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.accepted: return Colors.green;
      case BookingStatus.declined: return Colors.red;
      case BookingStatus.completed: return widget.primaryColor;
      case BookingStatus.cancelled: return Colors.grey;
    }
  }

  Future<void> _launchEmailSupport(String reason) async {
    final String subject = 'booking_card_dispute_subject'.tr(args: [widget.booking.id]);
    final String body = 'booking_card_dispute_body'.tr(args: [widget.booking.id, reason]);
    
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support.petunite@gmail.com',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDisputeDialog(String reasonContext) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(
          children: [
            const Icon(Icons.contact_support_rounded, color: Colors.orange, size: 40),
            const SizedBox(height: 10),
            Text('help_center_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'booking_card_help_center_desc'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => _launchEmailSupport(reasonContext),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.primaryColor.withOpacity(0.2), width: 2.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined, color: widget.primaryColor, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "support.petunite@gmail.com",
                          style: TextStyle(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('email_tap_instruction'.tr(), style: TextStyle(fontSize: 9, color: widget.primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'booking_card_admin_verification_note'.tr(args: [widget.booking.id]),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_close'.tr().toUpperCase(), style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeInfoBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'booking_card_dispute_active_msg'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'booking_card_dispute_instruction'.tr(),
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _launchEmailSupport("Problema segnalato dalla dashboard."),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: Text(
                "support.petunite@gmail.com",
                style: TextStyle(
                  color: widget.primaryColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayAndConfirm() async {
    setState(() => _isProcessing = true);
    final result = await BookingService().payAndConfirm(
      booking: widget.booking,
    );
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('booking_card_pay_confirm_success'.tr())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [result['message'] ?? 'Operazione fallita']))));
      }
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _handleConfirmArrival() async {
    final confirmed = await _showStyledConfirmDialog(
      context,
      'booking_card_confirm_arrival_title'.tr(),
      'booking_card_confirm_arrival_content'.tr(),
      Icons.check_circle_outline_rounded,
      Colors.green
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);
    final result = await BookingService().confirmSitterArrival(
      widget.booking.id,
      widget.booking.sitterId,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('booking_card_arrival_confirmed_success'.tr())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('booking_card_unlock_failed'.tr(args: [result['message']]))));
      }
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _handleReportNoShow() async {
    final confirmed = await _showStyledConfirmDialog(
      context,
      'booking_card_report_no_show_title'.tr(),
      'booking_card_report_no_show_content'.tr(),
      Icons.warning_amber_rounded,
      Colors.redAccent
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).update({
        'noShowReported': true,
        'noShowTimestamp': FieldValue.serverTimestamp(),
      });

      await BookingService().sendSystemMessage(
        widget.booking.sitterId,
        'booking_card_report_msg_sitter'.tr(),
        sysText: 'booking_card_sys_msg_owner_report'.tr(args: [widget.booking.id])
      );

      if (mounted) _showDisputeDialog('booking_card_sitter_no_show_reason'.tr());
    } catch (e) {}
    setState(() => _isProcessing = false);
  }

  Future<void> _handleReportOwnerNoShow() async {
    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).update({
        'ownerNoShowReported': true,
        'ownerNoShowTimestamp': FieldValue.serverTimestamp(),
      });

      // MESSAGGIO IN CHAT AUTOMATICO
      await BookingService().sendSystemMessage(
        widget.booking.ownerId, 
        'booking_card_report_msg_owner'.tr(), 
        sysText: 'booking_card_sys_msg_sitter_report'.tr(args: [widget.booking.id])
      );

      if (mounted) _showDisputeDialog('booking_card_owner_no_show_reason'.tr());
    } catch (e) {}
    setState(() => _isProcessing = false);
  }

  Future<bool> _showStyledConfirmDialog(BuildContext context, String title, String content, IconData icon, Color color) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
          ],
        ),
        content: Text(content, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('btn_cancel'.tr().toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('btn_confirm'.tr().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text('booking_card_delete_history_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text('booking_card_delete_confirm_msg'.tr(), style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('btn_cancel'.tr().toUpperCase(), style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await BookingService().deleteBooking(widget.booking.id);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('btn_delete'.tr().toUpperCase(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    final paymentStatus = widget.rawDoc['paymentStatus'] ?? 'none';

    if (paymentStatus == 'none' || paymentStatus == '') {
      _showSimpleCancelDialog();
      return;
    }

    // CALCOLO PRECISO BASATO SU DATA + ORA
    final startDateTime = _getStartDateTime();
    final diffInHours = startDateTime.difference(DateTime.now()).inMinutes / 60.0;

    double penaltyPerc = 1.0;
    String policyText = "";
    if (diffInHours > 24) {
      policyText = "Rimborso 90% (Penale 10%)";
      penaltyPerc = 0.10;
    } else if (diffInHours > 12) {
      policyText = "Rimborso 70% (Penale 30%)";
      penaltyPerc = 0.30;
    } else if (diffInHours > 8) {
      policyText = "Rimborso 60% (Penale 40%)";
      penaltyPerc = 0.40;
    } else if (diffInHours > 4) {
      policyText = "Rimborso 40% (Penale 60%)";
      penaltyPerc = 0.60;
    } else if (diffInHours > 2) {
      policyText = "Rimborso 20% (Penale 80%)";
      penaltyPerc = 0.80;
    } else {
      policyText = "Nessun rimborso (Penale 100%)";
      penaltyPerc = 1.0;
    }

    final double penaltyAmount = widget.booking.totalPrice * penaltyPerc;
    final double refundAmount = widget.booking.totalPrice - penaltyAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'booking_card_cancel_refund_title'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('booking_card_cancel_refund_desc'.tr(), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.withOpacity(0.1))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('booking_card_policy_label'.tr(args: [policyText]), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.red)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('booking_card_penalty_label'.tr(), style: const TextStyle(fontSize: 11)),
                      Text("€${penaltyAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('booking_card_refund_client_label'.tr(), style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                      Text("€${refundAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text('booking_card_penalty_desc'.tr(), style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('btn_back'.tr().toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _handlePartialRefund(penaltyAmount, policyText);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text('booking_card_confirm_cancel_btn'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePartialRefund(double penaltyAmount, String reason) async {
    setState(() => _isProcessing = true);

    final result = await BookingService().cancelWithPartialRefund(
      bookingId: widget.booking.id,
      penaltyAmount: penaltyAmount,
      reason: reason
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('booking_card_cancel_partial_success'.tr())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [result['message']])), backgroundColor: Colors.red));
      }
    }
    setState(() => _isProcessing = false);
  }

  /// ✅ Funzione per l'annullamento TOTALE richiesto dal SITTER
  Future<void> _handleSitterFullRefund() async {
    final confirmed = await _showStyledConfirmDialog(
      context,
      'booking_card_sitter_cancel_title'.tr(),
      'booking_card_sitter_cancel_content'.tr(args: [widget.booking.totalPrice.toString()]),
      Icons.cancel_presentation_rounded,
      Colors.redAccent
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);
    
    // Usiamo il nuovo metodo cancelBySitter che attiva il rimborso 100% in index.js
    final result = await BookingService().cancelBySitter(
      bookingId: widget.booking.id,
      reason: "Annullamento richiesto dal Sitter (Rimborso Totale)."
    );

    if (mounted) {
      if (result['success']) {
        await BookingService().sendSystemMessage(
          widget.booking.ownerId, 
          'booking_card_sitter_cancel_msg_owner'.tr(args: [widget.booking.totalPrice.toString()]),
          sysText: 'booking_card_sitter_cancel_sys_msg'.tr()
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('booking_card_sitter_cancel_success'.tr())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [result['message']])), backgroundColor: Colors.red));
      }
    }
    setState(() => _isProcessing = false);
  }

  void _showSimpleCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text('booking_card_simple_cancel_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('chat_list_delete_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('no'.tr().toUpperCase())),
          ElevatedButton(
            onPressed: () async {
              await BookingService().updateBookingStatus(widget.booking.id, BookingStatus.cancelled);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('yes'.tr().toUpperCase(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _goToChat(BuildContext context, String otherUserId, String otherUsername) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
          otherUserId: otherUserId,
          otherUsername: otherUsername,
          messageService: MessageService(),
        ),
      ),
    );
  }

  Widget _buildSitterCountdown() {
    final start = _getStartDateTime();
    final now = DateTime.now();
    final diff = start.difference(now);
    
    final dayName = DateFormat('EEEE', context.locale.languageCode).format(start).toUpperCase();
    final dateStr = DateFormat('dd MMMM yyyy', context.locale.languageCode).format(start);
    
    String countdown = "";
    if (diff.isNegative) {
      if (now.isBefore(widget.booking.endDate)) {
        countdown = 'booking_card_in_progress'.tr();
      } else {
        countdown = 'booking_card_ended'.tr();
      }
    } else if (diff.inDays > 0) {
      countdown = diff.inDays == 1 ? 'booking_card_starts_in_day'.tr(args: [diff.inDays.toString()]) : 'booking_card_starts_in_days'.tr(args: [diff.inDays.toString()]);
    } else if (diff.inHours > 0) {
      countdown = diff.inHours == 1 ? 'booking_card_starts_in_hour'.tr(args: [diff.inHours.toString()]) : 'booking_card_starts_in_hours'.tr(args: [diff.inHours.toString()]);
    } else {
      countdown = 'booking_card_starts_soon'.tr();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: widget.primaryColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$dayName, $dateStr",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: widget.primaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.booking.checkInTime.isNotEmpty && widget.booking.checkOutTime.isNotEmpty)
                      Text(
                        "🕒 Dalle ${widget.booking.checkInTime} alle ${widget.booking.checkOutTime}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: widget.primaryColor.withOpacity(0.75)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.black54, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  countdown,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.booking.status);
    final paymentStatus = widget.rawDoc['paymentStatus'] ?? 'none';
    final otherUserId = widget.isSitterView ? widget.booking.ownerId : widget.booking.sitterId;

    final bool noShowReported = widget.rawDoc['noShowReported'] ?? false;
    final bool ownerNoShowReported = widget.rawDoc['ownerNoShowReported'] ?? false;
    final bool disputeActive = widget.rawDoc['disputeActive'] ?? false;
    final bool checkInRequested = widget.rawDoc['checkInRequested'] ?? false;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('utenti').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final nickname = userData?['username'] ?? userData?['nickname'] ?? 'label_user'.tr();
        final photoUrl = userData?['fotoUrl'] ?? '';
        final realName = userData?['nome'] ?? '';
        final phone = userData?['telefono'] ?? '';

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('animali').doc(widget.booking.petId).get(),
          builder: (context, petSnapshot) {
            final petData = petSnapshot.data?.data() as Map<String, dynamic>?;
            final petName = petData?['nome'] ?? 'label_none'.tr();
            final petPhoto = petData?['fotoUrl'] ?? '';

            final bool canShowDelete = widget.booking.status == BookingStatus.completed || 
                                     widget.booking.status == BookingStatus.cancelled || 
                                     widget.booking.status == BookingStatus.declined;

            final bool isTerminalStatus = widget.booking.status == BookingStatus.completed || 
                                        widget.booking.status == BookingStatus.cancelled || 
                                        widget.booking.status == BookingStatus.declined;

            return Container(
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: widget.primaryColor.withOpacity(0.15),
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Column(
                  children: [
                    if (_isProcessing) const LinearProgressIndicator(),
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: widget.primaryColor.withOpacity(0.05),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _goToChat(context, otherUserId, nickname),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: widget.primaryColor.withOpacity(0.1),
                              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                              child: photoUrl.isEmpty ? Icon(Icons.person, color: widget.primaryColor) : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isSitterView ? 'booking_card_client_label'.tr(args: [nickname]) : 'booking_card_sitter_label'.tr(args: [nickname]),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  disputeActive ? 'booking_card_in_dispute'.tr() : widget.booking.status.name.toUpperCase(),
                                  style: TextStyle(color: disputeActive ? Colors.orange : statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          if (canShowDelete)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _showDeleteConfirmation(),
                            ),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: widget.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "€${widget.booking.totalPrice.toInt()}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
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
                          if (disputeActive || (widget.isSitterView && ownerNoShowReported) || (!widget.isSitterView && noShowReported))
                            _buildDisputeInfoBox(),

                          _buildDetailRow(
                            Icons.pets_rounded, 
                            'booking_card_animal_label'.tr(), 
                            petName,
                            subValue: "ID: ${widget.booking.petId.substring(0, min(5, widget.booking.petId.length))}...",
                            image: petPhoto,
                          ),
                          const Divider(height: 30),
                          _buildDetailRow(
                            Icons.category_rounded, 
                            "Servizio", 
                            widget.booking.serviceType.toUpperCase(),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailRow(
                                  Icons.calendar_today_rounded, 
                                  'booking_card_start_label'.tr(), 
                                  DateFormat('dd MMM', context.locale.languageCode).format(widget.booking.startDate),
                                  subValue: widget.booking.checkInTime,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailRow(
                                  Icons.event_rounded, 
                                  'booking_card_end_label'.tr(), 
                                  DateFormat('dd MMM', context.locale.languageCode).format(widget.booking.endDate),
                                  subValue: widget.booking.checkOutTime,
                                ),
                              ),
                            ],
                          ),

                          // MOSTRA NOME REALE E TELEFONO DEL SITTER AL CLIENTE DOPO IL PAGAMENTO
                          if (!widget.isSitterView && paymentStatus == 'authorized') ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.contact_phone_outlined, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text('booking_card_sitter_contacts_unlocked'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blue)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text('booking_card_name_label'.tr(args: [realName]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                  if (phone.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => launchUrl(Uri.parse("tel:$phone")),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone, size: 14, color: Colors.blue),
                                          const SizedBox(width: 5),
                                          Expanded(child: Text(phone, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    )
                                  else
                                    Text('booking_card_phone_unavailable'.tr(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          if (disputeActive)
                            _buildInfoRow(Icons.gavel_rounded, 'booking_card_admin_investigation_msg'.tr(), Colors.orange)
                          else if (!widget.isSitterView) ...[ 
                             if (widget.booking.status == BookingStatus.accepted && paymentStatus == 'none')
                              Column(
                                children: [
                                  SizedBox(width: double.infinity, child: _buildActionButton('booking_card_pay_confirm_btn'.tr(), Icons.lock_outline_rounded, Colors.black87, () => _handlePayAndConfirm(), isFull: true)),
                                  const SizedBox(height: 8),
                                ],
                              )
                             else if (paymentStatus == 'authorized') ...[
                                if (noShowReported)
                                  const SizedBox.shrink()
                                else if (ownerNoShowReported)
                                  Column(
                                    children: [
                                      Text('booking_card_sitter_says_no_response'.tr(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                      const SizedBox(height: 10),
                                      _buildActionButton('booking_card_i_am_here_btn'.tr(), Icons.check_circle_outline, Colors.green, () => _handleConfirmArrival(), isFull: true),
                                      const SizedBox(height: 8),
                                      _buildActionButton('booking_card_not_true_report_btn'.tr(), Icons.security, Colors.orange, () => _showDisputeDialog('booking_card_no_response_but_here_reason'.tr()), isFull: true),
                                    ],
                                  )
                                else if (checkInRequested)
                                  Column(
                                    children: [
                                      _buildActionButton('booking_card_confirm_arrival_unlock_btn'.tr(), Icons.check_circle_outline, Colors.green, () => _handleConfirmArrival(), isFull: true),
                                      const SizedBox(height: 8),
                                      TextButton(onPressed: () => _showDisputeDialog('booking_card_sitter_claims_arrived_i_deny'.tr()), child: Text('booking_report_false'.tr(), style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                                    ],
                                  )
                                else
                                  _buildInfoRow(Icons.timer_outlined, 'booking_card_waiting_sitter'.tr(), widget.primaryColor),
                             ] else if (paymentStatus == 'captured' || widget.booking.status == BookingStatus.completed)
                               _buildInfoRow(Icons.check_circle_rounded, 'booking_card_service_completed'.tr(), widget.primaryColor),

                             if (!isTerminalStatus)
                               Padding(
                                 padding: const EdgeInsets.only(top: 15),
                                 child: SizedBox(
                                   width: double.infinity,
                                   child: TextButton.icon(
                                     onPressed: () => _showCancelDialog(),
                                     icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                                     label: Text(
                                       paymentStatus == 'none' ? 'booking_card_cancel_request_btn'.tr() : 'booking_card_request_refund_cancel_btn'.tr(),
                                       style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                                     ),
                                     style: TextButton.styleFrom(
                                       backgroundColor: Colors.redAccent.withOpacity(0.05),
                                       padding: const EdgeInsets.symmetric(vertical: 12),
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                     ),
                                   ),
                                 ),
                               ),
                          ] else ...[
                             // SEZIONE RICEVUTE (SITTER)
                             if (!isTerminalStatus) _buildSitterCountdown(),

                             if (widget.booking.status == BookingStatus.pending)
                               SizedBox(width: double.infinity, child: _buildActionButton('booking_card_go_to_chat_respond_btn'.tr(), Icons.message_rounded, widget.primaryColor, () => _goToChat(context, otherUserId, nickname), isFull: true))
                             else if (paymentStatus == 'authorized') ...[
                               if (ownerNoShowReported)
                                 const SizedBox.shrink()
                               else if (noShowReported)
                                  Column(
                                    children: [
                                      Text('booking_card_owner_says_not_here'.tr(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                      const SizedBox(height: 10),
                                      _buildActionButton('booking_card_not_true_report_btn'.tr(), Icons.security, Colors.orange, () => _showDisputeDialog('booking_card_owner_claims_not_here_i_am_here'.tr()), isFull: true),
                                    ],
                                  )
                               else if (checkInRequested)
                                 const SizedBox.shrink()
                               else
                                 Column(
                                   children: [
                                     _buildActionButton('booking_card_i_have_arrived_btn'.tr(), Icons.location_on_rounded, widget.primaryColor, () async {
                                        await FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).update({'checkInRequested': true});
                                        await BookingService().sendSystemMessage(widget.booking.ownerId, 'booking_card_sitter_arrived_msg_owner'.tr(), sysText: 'booking_card_sitter_arrived_sys_msg'.tr());
                                     }, isFull: true),
                                     const SizedBox(height: 8),
                                     TextButton(onPressed: () => _handleReportOwnerNoShow(), child: Text('booking_card_owner_not_responding_btn'.tr(), style: const TextStyle(color: Colors.redAccent, fontSize: 11, decoration: TextDecoration.underline))),
                                   ],
                                 )
                             ] else if (paymentStatus == 'captured')
                               _buildInfoRow(Icons.check_circle_rounded, 'booking_card_payment_received'.tr(), Colors.green),

                             // ✅ TASTO ANNULLA E RIMBORSA TOTALE (SOTTO "VAI IN CHAT")
                             if (!isTerminalStatus && (widget.booking.status == BookingStatus.accepted || paymentStatus == 'authorized'))
                               Padding(
                                 padding: const EdgeInsets.only(top: 15),
                                 child: SizedBox(
                                   width: double.infinity,
                                   child: Column(
                                     children: [
                                       _buildActionButton('booking_card_go_to_chat_btn'.tr(), Icons.message_rounded, widget.primaryColor, () => _goToChat(context, otherUserId, nickname), isFull: true),
                                       
                                       const SizedBox(height: 12),
                                       
                                       TextButton.icon(
                                         onPressed: () => _handleSitterFullRefund(),
                                         icon: const Icon(Icons.cancel_presentation_rounded, size: 16, color: Colors.redAccent),
                                         label: Text(
                                           'booking_card_cancel_refund_full_sitter_btn'.tr(),
                                           style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                                         ),
                                         style: TextButton.styleFrom(
                                           backgroundColor: Colors.redAccent.withOpacity(0.05),
                                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                           minimumSize: const Size(double.infinity, 50),
                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {String? subValue, String? image}) {
    return Row(
      children: [
        if (image != null && image.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(image, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _iconBox(icon)),
          )
        else
          _iconBox(icon),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
              if (subValue != null) Text(subValue, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: widget.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: widget.primaryColor, size: 20),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap, {bool isFull = false}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: isFull ? 18 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}