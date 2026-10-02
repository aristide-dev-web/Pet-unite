import 'package:flutter/material.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/b_homes/d_message/widgets/message_bubble.dart';
import 'package:petping/b_homes/d_message/widgets/message_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/z_google/location_picker_service.dart';
import 'package:petping/z_google/live_location_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/b_homes/d_message/moderation/profanity_filter.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUsername;
  final String? otherUserPhotoUrl; // ✅ Foto dell'altro utente
  final MessageService messageService;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUsername,
    this.otherUserPhotoUrl,
    required this.messageService,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Stream<List<Message>> _messageStream;
  late String _chatId;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _chatId = (widget.currentUserId.compareTo(widget.otherUserId) < 0) 
        ? '${widget.currentUserId}_${widget.otherUserId}' 
        : '${widget.otherUserId}_${widget.currentUserId}';
    _messageStream = widget.messageService.getMessages(_chatId);
  }

  // GESTIONE INVIO POSIZIONE (STATICA O LIVE)
  Future<void> _handleLocationButton() async {
    final result = await LocationPickerService.showPicker(context);
    if (result == null) return;

    setState(() => _isActionLoading = true);
    try {
      if (result['type'] == 'live') {
        // --- CASO POSIZIONE LIVE ---
        final liveId = await LiveLocationService.startSharing(
          chatId: _chatId, 
          userId: widget.currentUserId
        );

        if (liveId != null) {
          await widget.messageService.sendMessage(_chatId, Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: widget.currentUserId,
            receiverId: widget.otherUserId,
            text: "location_msg_realtime".tr(),
            timestamp: DateTime.now(),
            type: 'live_location', 
            bookingData: {'liveId': liveId},
          ));
        }
      } else {
        // --- CASO POSIZIONE STATICA ---
        final String address = result['address'] ?? "location_msg_current".tr();
        await widget.messageService.sendMessage(_chatId, Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: widget.currentUserId,
          receiverId: widget.otherUserId,
          text: "📍 $address: ${result['link']}",
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      debugPrint("Errore invio posizione: $e");
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
              backgroundImage: (widget.otherUserPhotoUrl != null && widget.otherUserPhotoUrl!.isNotEmpty) 
                  ? NetworkImage(widget.otherUserPhotoUrl!) 
                  : null,
              child: (widget.otherUserPhotoUrl == null || widget.otherUserPhotoUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Color(0xFF6366F1), size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUsername, 
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          if (_isActionLoading) const LinearProgressIndicator(),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageStream,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => MessageBubble(
                    message: messages[i],
                    isMe: messages[i].senderId == widget.currentUserId,
                    chatId: _chatId,
                    currentUserId: widget.currentUserId,
                    otherUsername: widget.otherUsername,
                  ),
                );
              },
            ),
          ),
          MessageInput(
            onPlusPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("chat_snack_booking_hint".tr()))
              );
            },
            onLocationPressed: _handleLocationButton,
            onSend: (t) {
              final trimmedText = t.trim();
              if (trimmedText.isEmpty) return;

              // ✅ CONTROLLO PAROLE SCURRILI
              if (ProfanityFilter.containsProfanity(trimmedText)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("chat_profanity_error".tr()),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              widget.messageService.sendMessage(_chatId, Message(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: widget.currentUserId,
                receiverId: widget.otherUserId,
                text: trimmedText,
                timestamp: DateTime.now(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
