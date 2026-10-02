import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';
import 'package:petping/b_homes/d_message/chat_screen.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/b_homes/d_message/message_listener.dart';
import 'package:petping/b_homes/d_message/delete_message.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  final int initialTabIndex;

  const ChatListScreen({
    super.key, 
    required this.currentUserId, 
    this.initialTabIndex = 0
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MessageService _messageService = MessageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this, 
      initialIndex: widget.initialTabIndex
    );
    MessageListener().start(widget.currentUserId);
  }

  void _showDeleteDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('chat_list_delete_title'.tr()),
        content: Text('chat_list_delete_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              await DeleteMessageService().deleteLocalChat(chatId);
              if (mounted) Navigator.pop(context);
            },
            child: Text('btn_delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'chat_list_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'chat_list_tab_personal'.tr()),
            Tab(text: 'chat_list_tab_petsitting'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(isBooking: false),
          _buildChatList(isBooking: true),
        ],
      ),
    );
  }

  Widget _buildChatList({required bool isBooking}) {
    final chatBox = Hive.box<ChatPreview>('chatPreviews');

    return ValueListenableBuilder(
      valueListenable: chatBox.listenable(),
      builder: (context, Box<ChatPreview> box, _) {
        final chats = box.values
            .where((chat) => (chat.isBookingChat == isBooking))
            .toList()
          ..sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isBooking ? Icons.pets_outlined : Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 16),
                Text(
                  isBooking ? 'chat_list_empty_petsitting'.tr() : 'chat_list_empty_personal'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
          itemBuilder: (context, index) {
            final chat = chats[index];
            final String time = "${chat.lastTimestamp.hour}:${chat.lastTimestamp.minute.toString().padLeft(2, '0')}";

            // --- LOGICA PARACADUTE FOTO E NICKNAME ---
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('utenti').doc(chat.otherUserId).get(),
              builder: (context, snapshot) {
                String displayName = chat.otherUsername;
                String? displayPhoto = chat.otherUserPhotoUrl;

                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    final String? nick = userData['username'] ?? userData['nickname'];
                    if (nick != null && nick.isNotEmpty) {
                      displayName = nick;
                    }
                    final String? photo = userData['fotoUrl'];
                    if (photo != null && photo.isNotEmpty) {
                      displayPhoto = photo;
                    }
                  }
                }

                // Fallback finale se il nickname è ancora generico
                if (displayName.isEmpty || displayName == 'Utente') {
                  displayName = chat.otherUsername.isNotEmpty ? chat.otherUsername : 'label_user'.tr();
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isBooking ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.blueGrey.shade100,
                        backgroundImage: (displayPhoto != null && displayPhoto.isNotEmpty) 
                            ? NetworkImage(displayPhoto) 
                            : null,
                        child: (displayPhoto == null || displayPhoto.isEmpty)
                            ? Icon(
                                isBooking ? Icons.pets_rounded : Icons.person,
                                color: isBooking ? const Color(0xFF6366F1) : Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                      if (!chat.isRead)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    '${isBooking ? "🐾 " : ""}$displayName',
                    style: TextStyle(
                      fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: chat.isRead ? Colors.grey : Colors.black87,
                      fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 5),
                          if (!chat.isRead)
                            const Icon(Icons.mark_chat_unread, color: Color(0xFF6366F1), size: 16),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _showDeleteDialog(context, chat.chatId),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await _messageService.markChatAsRead(chat.chatId);
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          currentUserId: widget.currentUserId,
                          otherUserId: chat.otherUserId,
                          otherUsername: displayName,
                          otherUserPhotoUrl: displayPhoto,
                          messageService: _messageService,
                        ),
                      ),
                    );
                  },
                );
              }
            );
          },
        );
      },
    );
  }
}
