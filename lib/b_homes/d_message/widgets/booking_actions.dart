import 'dart:math';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/strip/stripe_service.dart';
import 'package:petping/utils/notific_principal.dart';
import 'package:petping/social/social_memoria_firebase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../petsitting/screens/search/components/sections/sitter_ui_helpers.dart';

class BookingActions extends StatefulWidget {
  final String bid;
  final String status;
  final String payStatus;
  final double price;
  final String sitterId;
  final String? serviceCode;
  final DateTime? startDate;
  final String? checkInTime;
  final bool isMe; // true se è il proprietario (owner), false se è il sitter
  final String chatId;
  final String currentUserId;
  final Message originalMessage;

  const BookingActions({
    super.key,
    required this.bid,
    required this.status,
    required this.payStatus,
    required this.price,
    required this.sitterId,
    required this.serviceCode,
    this.startDate,
    this.checkInTime,
    required this.isMe,
    required this.chatId,
    required this.currentUserId,
    required this.originalMessage,
  });

  @override
  State<BookingActions> createState() => _BookingActionsState();
}

class _BookingActionsState extends State<BookingActions> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 3, color: SitterUIHelpers.primaryIndigo),
        ),
      );
    }

    if (widget.status == 'declined' || widget.status == 'cancelled') {
      return _buildInfoRow(Icons.error_outline_rounded, "booking_status_closed".tr(), Colors.redAccent);
    }

    if (widget.status == 'completed' || widget.payStatus == 'captured') {
      return _buildSuccessBanner("booking_status_completed".tr());
    }

    if (widget.payStatus == 'authorized') {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').doc(widget.bid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          if (data == null) return const SizedBox.shrink();

          final bool checkInRequested = data['checkInRequested'] ?? false;
          final bool noShowReported = data['noShowReported'] ?? false;
          final bool ownerNoShowReported = data['ownerNoShowReported'] ?? false;
          final bool disputeActive = data['disputeActive'] ?? false;

          if (disputeActive) {
            return Column(
              children: [
                if (widget.isMe) _buildDisputeInfoBox(),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.gavel_rounded, "booking_dispute_active".tr(), Colors.orange),
              ],
            );
          }

          if (widget.isMe) { // PROPRIETARIO
            if (noShowReported) {
              return Column(
                children: [
                  _buildDisputeInfoBox(),
                  const SizedBox(height: 12),
                  _buildWaitingText("booking_waiting_sitter_response".tr(), Colors.orange),
                ],
              );
            }
            if (ownerNoShowReported) {
               return Column(
                children: [
                  Text("booking_sitter_not_here".tr(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  const SizedBox(height: 10),
                  _buildMainButton("booking_confirm_presence".tr(), SitterUIHelpers.accentEmerald, () => _confirmSitterArrival()),
                  const SizedBox(height: 8),
                  _buildSecondaryButton("booking_report_false".tr(), Icons.security, Colors.orange, () => _showDisputeDialog("Il Sitter dice che non rispondi, ma io sono qui.")),
                ],
              );
            }
            if (checkInRequested) {
              return Column(
                children: [
                  _buildMainButton("booking_confirm_arrival".tr(), SitterUIHelpers.accentEmerald, () => _confirmSitterArrival()),
                  const SizedBox(height: 8),
                  _buildTextButton("booking_report_false".tr(), Colors.redAccent, () => _reportCheckInDispute()),
                ],
              );
            }
            return Column(
              children: [
                _buildInfoRow(Icons.timer_outlined, "booking_waiting_sitter".tr(), SitterUIHelpers.primaryIndigo),
              ],
            );
          } else { // SITTER
            if (noShowReported) {
              return Column(
                children: [
                  Text("booking_owner_not_here".tr(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  const SizedBox(height: 10),
                  _buildMainButton("booking_accept_refund".tr(), Colors.redAccent, () => _acceptNoShowRefund()),
                  const SizedBox(height: 8),
                  _buildSecondaryButton("booking_report_false".tr(), Icons.security, Colors.orange, () => _showDisputeDialog("Il Proprietario dice che non ci sono, ma io sono qui.")),
                ],
              );
            }
            if (ownerNoShowReported) {
              return Column(
                children: [
                  _buildDisputeInfoBox(),
                  const SizedBox(height: 12),
                  _buildWaitingText("booking_waiting_owner".tr(), Colors.orange),
                ],
              );
            }
            if (checkInRequested) {
              return _buildWaitingText("booking_waiting_owner".tr(), SitterUIHelpers.accentEmerald);
            }
            return Column(
              children: [
                _buildMainButton("booking_sitter_arrived".tr(), SitterUIHelpers.primaryIndigo, () => _requestCheckIn(), icon: Icons.location_on_rounded),
                const SizedBox(height: 8),
                _buildTextButton("booking_owner_not_responding".tr(), Colors.redAccent, () => _reportOwnerNoShow()),
              ],
            );
          }
        },
      );
    }

    if (!widget.isMe) return _buildSitterActions();
    if (widget.isMe) return _buildOwnerActions();

    return const SizedBox.shrink();
  }

  Widget _buildDisputeInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
                  "booking_dispute_title".tr(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "booking_dispute_text".tr(),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _launchEmailSupport("Problema con la prenotazione."),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: const Text(
                "support.petunite@gmail.com",
                style: TextStyle(
                  color: SitterUIHelpers.primaryIndigo,
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

  Future<void> _launchEmailSupport(String reason) async {
    final String subject = 'RECLAMO PRENOTAZIONE ${widget.bid}';
    final String body = 'Dettagli reclamo:\nID: ${widget.bid}\nMotivo: $reason\n\nInviaci qui eventuali prove (screenshot o foto).';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support.petunite@gmail.com',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    }
  }

  // --- POPUP PROFESSIONALE CON EMAIL CLICCABILE ---
  void _showDisputeDialog(String reasonContext) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            const Icon(Icons.security_rounded, color: Colors.orange, size: 40),
            const SizedBox(height: 10),
            Text("help_center_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "help_center_text".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // EMAIL CLICCABILE
            GestureDetector(
              onTap: () => _launchEmailSupport(reasonContext),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: SitterUIHelpers.primaryIndigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SitterUIHelpers.primaryIndigo.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined, color: SitterUIHelpers.primaryIndigo, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "support.petunite@gmail.com",
                          style: TextStyle(
                            color: SitterUIHelpers.primaryIndigo,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("email_tap_instruction".tr(), style: const TextStyle(fontSize: 9, color: SitterUIHelpers.primaryIndigo, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "admin_investigation_note".tr(args: [widget.bid]),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("btn_close".tr(), style: const TextStyle(color: SitterUIHelpers.primaryIndigo, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Future<void> _reportCheckInDispute() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("booking_report_action_title".tr()),
        content: Text("booking_report_action_text".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("btn_cancel".tr())),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text("btn_confirm".tr())),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({
        'disputeActive': true,
        'disputeBy': widget.currentUserId,
        'disputeTimestamp': FieldValue.serverTimestamp(),
      });

      // Messaggio al SITTER
      await _sendSystemMessage(
        widget.sitterId,
        "sta segnalando un'azione non riconosciuta riguardo al tuo arrivo. ⚠️",
        sysText: "⚠️ IL PROPRIETARIO STA SEGNALANDO UN'AZIONE NON RICONOSCIUTA (ID: ${widget.bid})"
      );

      // Messaggio al PROPRIETARIO
      await _sendSystemMessage(
        widget.currentUserId,
        "Hai segnalato un'azione non riconosciuta. Scrivi a support.petunite@gmail.com per i dettagli.",
        sysText: "ℹ️ ISTRUZIONI: Contattaci via email (ID: ${widget.bid}). L'admin indagherà entro 3-7gg lavorativi."
      );

      if (mounted) {
        _showDisputeDialog("Il Sitter dichiara di essere arrivato, ma io nego.");
      }
    } catch (e) {
      debugPrint("Errore: $e");
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _requestCheckIn() async {
    setState(() => _isProcessing = true);
    await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({
      'checkInRequested': true,
      'checkInTimestamp': FieldValue.serverTimestamp(),
    });
    await _sendSystemMessage(widget.originalMessage.senderId, "dichiara di essere arrivato! Conferma la sua presenza per sbloccare le istruzioni. 🐾", sysText: "📍 IL SITTER DICHIARA DI ESSERE ARRIVATO");
    setState(() => _isProcessing = false);
  }

  Future<void> _acceptNoShowRefund() async {
    debugPrint("DEBUG_REFUND: Avvio _acceptNoShowRefund per BID: ${widget.bid}");
    setState(() => _isProcessing = true);

    try {
      // 1. Aggiorniamo Firestore
      debugPrint("DEBUG_REFUND: Aggiornamento Firestore...");
      await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({
        'status': 'cancelled',
        'paymentStatus': 'refunding',
        'refundReason': 'sitter_confirmed_no_show'
      });
      debugPrint("DEBUG_REFUND: Firestore aggiornato.");

      // 2. Chiamata a Stripe (Simulata o Reale tramite Service)
      debugPrint("DEBUG_REFUND: Chiamata a StripeService per sbloccare fondi...");
      // Nota: Qui dovremmo aggiungere un metodo specifico per il rimborso/cancel se authorized
      // Per ora logghiamo il tentativo.

      await _sendSystemMessage(widget.originalMessage.senderId, "ha confermato la mancata presenza. Il rimborso è stato avviato. ⚠️", sysText: "🔄 RIMBORSO AVVIATO (SITTER NON PRESENTE)");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("snack_refund_success".tr()))
        );
      }
    } catch (e) {
      debugPrint("DEBUG_REFUND: ERRORE CRITICO: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("snack_refund_error".tr(args: [e.toString()])), backgroundColor: Colors.red)
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _reportNoShow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("booking_report_no_show_title".tr()),
        content: Text("booking_report_no_show_text".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("btn_cancel".tr())),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text("btn_confirm".tr())),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() => _isProcessing = true);
    await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({
      'noShowReported': true,
      'noShowTimestamp': FieldValue.serverTimestamp(),
    });

    // Invia messaggio al SITTER
    await _sendSystemMessage(
      widget.sitterId,
      "sta segnalando un'azione non riconosciuta: dice che non sei presente. ⚠️",
      sysText: "⚠️ IL PROPRIETARIO STA SEGNALANDO UN'AZIONE NON RICONOSCIUTA (ID: ${widget.bid})"
    );

    // Invia messaggio diretto al PROPRIETARIO (che compare in chat)
    await _sendSystemMessage(
      widget.currentUserId,
      "Hai segnalato la mancata presenza. Scrivi a support.petunite@gmail.com per i dettagli.",
      sysText: "ℹ️ ISTRUZIONI: Scrivi a support.petunite@gmail.com (ID: ${widget.bid}). L'admin indagherà entro 3-7gg lavorativi."
    );

    setState(() => _isProcessing = false);
  }

  Future<void> _reportOwnerNoShow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("booking_report_owner_not_responding_title".tr()),
        content: Text("booking_report_owner_not_responding_text".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("btn_cancel".tr())),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text("btn_confirm".tr())),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() => _isProcessing = true);
    await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({
      'ownerNoShowReported': true,
      'ownerNoShowTimestamp': FieldValue.serverTimestamp(),
    });

    // Invia messaggio al PROPRIETARIO
    await _sendSystemMessage(
      widget.originalMessage.senderId,
      "sta segnalando un'azione non riconosciuta: dice che non rispondi o non sei presente. ⚠️",
      sysText: "⚠️ IL SITTER STA SEGNALANDO UN'AZIONE NON RICONOSCIUTA (ID: ${widget.bid})"
    );

    // Invia messaggio diretto al SITTER (che compare in chat)
    await _sendSystemMessage(
      widget.currentUserId,
      "Hai segnalato che il proprietario non risponde. Scrivi a support.petunite@gmail.com per i dettagli.",
      sysText: "ℹ️ ISTRUZIONI: Scrivi a support.petunite@gmail.com (ID: ${widget.bid}). L'admin indagherà entro 3-7gg lavorativi."
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      _showDisputeDialog("Il Proprietario non risponde alle comunicazioni.");
    }
  }

  Future<void> _confirmSitterArrival() async {
    setState(() => _isProcessing = true);
    final result = await StripeService.instance.releasePayment(bookingId: widget.bid, code: "OWNER_CONFIRMED");
    if (result['success'] == true) {
      await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({'status': 'completed', 'paymentStatus': 'captured'});
      await _sendSystemMessage(widget.sitterId, "booking_sys_confirmed".tr(), sysText: "✅ ARRIVO CONFERMATO E PAGAMENTO SBLOCCATO!");
    }
    setState(() => _isProcessing = false);
  }

  Widget _buildSitterActions() {
    if (widget.status == 'pending') {
      return Column(children: [_buildMainButton("booking_accept_request".tr(), SitterUIHelpers.accentEmerald, () => _updateStatus('accepted')), const SizedBox(height: 8), Row(children: [_buildSecondaryButton("booking_counter_offer".tr(), Icons.edit_note_rounded, Colors.orangeAccent, () => _showCounterDialog()), const SizedBox(width: 8), _buildSecondaryButton("booking_decline".tr(), Icons.close_rounded, Colors.redAccent, () => _updateStatus('declined'))])]);
    }
    return _buildWaitingText(widget.status == 'counter_offered' ? "booking_waiting_owner".tr() : "booking_waiting_payment".tr(), widget.status == 'counter_offered' ? Colors.orangeAccent : SitterUIHelpers.accentEmerald);
  }

  Widget _buildOwnerActions() {
    if (widget.status == 'counter_offered') return Column(children: [_buildMainButton("booking_accept_counter".tr(), SitterUIHelpers.accentEmerald, () => _updateStatus('accepted')), const SizedBox(height: 8), _buildTextButton("booking_decline_close".tr(), Colors.redAccent, () => _updateStatus('declined'))]);
    if (widget.status == 'accepted' && widget.payStatus == 'none') return _buildMainButton("booking_pay_lock".tr(), SitterUIHelpers.textColor, () => _payNow(), icon: Icons.lock_outline_rounded);
    return _buildWaitingText("booking_waiting_sitter_response".tr(), SitterUIHelpers.primaryIndigo);
  }

  Widget _buildMainButton(String label, Color color, VoidCallback onPressed, {IconData? icon}) {
    return SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: onPressed, icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12), overflow: TextOverflow.ellipsis), style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))));
  }

  Widget _buildSecondaryButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(child: OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon, size: 16), label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis), style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))));
  }

  Widget _buildTextButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(width: double.infinity, child: TextButton(onPressed: onPressed, child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, decoration: TextDecoration.underline))));
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10), textAlign: TextAlign.center))]));
  }

  Widget _buildSuccessBanner(String text) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [SitterUIHelpers.accentEmerald.withOpacity(0.1), SitterUIHelpers.accentEmerald.withOpacity(0.05)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: SitterUIHelpers.accentEmerald.withOpacity(0.2))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle_rounded, color: SitterUIHelpers.accentEmerald, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: SitterUIHelpers.accentEmerald, fontWeight: FontWeight.w900, fontSize: 12), textAlign: TextAlign.center))]));
  }

  Widget _buildWaitingText(String text, Color color) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: color.withOpacity(0.5))), const SizedBox(width: 12), Expanded(child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w900)))]));
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isProcessing = true);
    await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({'status': status});

    // Recupero il nickname del mittente per il messaggio di sistema
    final senderDoc = await FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).get();
    final senderNickname = senderDoc.data()?['username'] ?? 'Utente';

    final targetId = widget.isMe ? widget.sitterId : widget.originalMessage.senderId;
    await _sendSystemMessage(
      targetId,
      status == 'accepted' ? 'booking_sys_accepted'.tr() : 'booking_sys_declined'.tr(),
      senderName: senderNickname
    );
    setState(() => _isProcessing = false);
  }

  Future<void> _payNow() async {
    setState(() => _isProcessing = true);
    final result = await StripeService.instance.pagaInSospensione(
      amount: (widget.price * 100).round(),
      sitterId: widget.sitterId,
      bookingId: widget.bid
    );
    if (result['success'] == true) {
      // Recupero nickname proprietario
      final senderDoc = await FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).get();
      final senderNickname = senderDoc.data()?['username'] ?? 'Utente';

      await _sendSystemMessage(
        widget.sitterId,
        "booking_sys_authorized".tr(),
        sysText: "💳 PAGAMENTO EFFETTUATO CON SUCCESSO!",
        senderName: senderNickname
      );
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _sendSystemMessage(String toId, String pushMsg, {String? sysText, String? senderName}) async {
    try {
      await SocialNotificationService().sendNotification(toUserId: toId, type: 'booking_update', text: pushMsg);

      final msg = Message(
        id: "sys_${DateTime.now().millisecondsSinceEpoch}",
        senderId: widget.currentUserId,
        receiverId: toId,
        text: sysText ?? "📢 ${pushMsg.toUpperCase()}",
        timestamp: DateTime.now(),
        type: 'system'
      );

      await MessageService().sendMessage(
        widget.chatId,
        msg,
        isBooking: true,
        senderName: senderName // Uso il nickname recuperato
      );
    } catch (e) {}
  }

  void _showCounterDialog() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), title: Text("booking_counter_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900)), content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: "booking_new_price_label".tr(), prefixText: "€ ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("btn_cancel".tr())), ElevatedButton(onPressed: () { final p = double.tryParse(controller.text.replaceAll(',', '.')); if (p != null) { Navigator.pop(ctx); _sendCounter(p); } }, child: Text("btn_send".tr()))]));
  }

  Future<void> _sendCounter(double newPrice) async {
    setState(() => _isProcessing = true);
    await FirebaseFirestore.instance.collection('bookings').doc(widget.bid).update({'totalPrice': newPrice, 'status': 'counter_offered'});

    final senderDoc = await FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).get();
    final senderNickname = senderDoc.data()?['username'] ?? 'Utente';

    await _sendSystemMessage(
      widget.originalMessage.senderId,
      "ti ha inviato una controproposta di $newPrice €! 🐾",
      sysText: "💰 NUOVA PROPOSTA: $newPrice €",
      senderName: senderNickname
    );
    setState(() => _isProcessing = false);
  }
}
