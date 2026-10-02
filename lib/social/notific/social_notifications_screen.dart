import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:petping/style/pet_style.dart';
import 'package:intl/intl.dart';
import 'package:petping/social/post/social_post_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/b_homes/d_message/chat_list_screen.dart';

class SocialNotificationsScreen extends StatefulWidget {
  const SocialNotificationsScreen({super.key});

  @override
  State<SocialNotificationsScreen> createState() => _SocialNotificationsScreenState();
}

class _SocialNotificationsScreenState extends State<SocialNotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    // Segniamo come lette dopo un piccolo delay per permettere all'utente di vedere i pallini se presenti
    Future.delayed(const Duration(seconds: 2), () => _markAllAsRead());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    if (!mounted) return;
    final box = Hive.box<SocialNotification>('social_notifications_box');
    for (var i = 0; i < box.length; i++) {
      final notif = box.getAt(i);
      if (notif != null && !notif.isRead) {
        notif.isRead = true;
        notif.save();
      }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return "Adesso";
    if (difference.inMinutes < 60) return "${difference.inMinutes} min fa";
    if (difference.inHours < 24) return "${difference.inHours} ore fa";
    if (difference.inDays < 7) return "${difference.inDays} giorni fa";
    return DateFormat('dd/MM/yyyy').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attività',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: PetStyle.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: PetStyle.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          tabs: const [
            Tab(text: "NOTIFICHE"),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<SocialNotification>('social_notifications_box').listenable(),
        builder: (context, Box<SocialNotification> box, _) {
          final allNotifications = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Divisione notifiche
          final listGeneral = allNotifications.where((n) => n.type != 'sitter' && n.type != 'booking').toList();
          final listSitter = allNotifications.where((n) => n.type == 'sitter' || n.type == 'booking').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(listGeneral),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(List<SocialNotification> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    // Organizzazione per periodi temporali
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    List<SocialNotification> listToday = [];
    List<SocialNotification> listYesterday = [];
    List<SocialNotification> listThisWeek = [];
    List<SocialNotification> listOlder = [];

    for (var n in notifications) {
      final date = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
      if (date == today) {
        listToday.add(n);
      } else if (date == yesterday) {
        listYesterday.add(n);
      } else if (n.timestamp.isAfter(sevenDaysAgo)) {
        listThisWeek.add(n);
      } else {
        listOlder.add(n);
      }
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (listToday.isNotEmpty) ...[
          _buildHeader("Oggi"),
          _buildSliverList(listToday),
        ],
        if (listYesterday.isNotEmpty) ...[
          _buildHeader("Ieri"),
          _buildSliverList(listYesterday),
        ],
        if (listThisWeek.isNotEmpty) ...[
          _buildHeader("Questa settimana"),
          _buildSliverList(listThisWeek),
        ],
        if (listOlder.isNotEmpty) ...[
          _buildHeader("Più vecchie"),
          _buildSliverList(listOlder),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverList(List<SocialNotification> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildNotificationItem(context, items[index]),
        childCount: items.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: PetStyle.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, size: 60, color: PetStyle.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            'Nessuna novità al momento',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ti avviseremo qui quando succederà qualcosa!',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, SocialNotification notif) {
    return Container(
      color: notif.isRead ? Colors.transparent : PetStyle.primary.withOpacity(0.04),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          if (!notif.isRead) {
            notif.isRead = true;
            notif.save();
          }
          if (notif.type == 'sitter' || notif.type == 'booking') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatListScreen(currentUserId: FirebaseAuth.instance.currentUser?.uid ?? ''),
              ),
            );
          } else if (notif.postId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SocialPostDetailScreen(
                  postId: notif.postId!,
                  currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
              ),
            );
          }
        },
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: (notif.fromUserPhoto != null && notif.fromUserPhoto!.startsWith('http')) 
                  ? NetworkImage(notif.fromUserPhoto!) 
                  : null,
              backgroundColor: PetStyle.lightGrey,
              child: (notif.fromUserPhoto == null || !notif.fromUserPhoto!.startsWith('http')) 
                  ? const Icon(Icons.person, color: Colors.white) 
                  : null,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getColor(notif.type),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(_getIcon(notif.type), size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.3),
            children: [
              TextSpan(text: notif.fromUsername, style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' ${notif.text}'),
              TextSpan(
                text: '  ${_formatTimestamp(notif.timestamp)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        trailing: !notif.isRead 
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: PetStyle.primary, shape: BoxShape.circle),
            )
          : null,
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'tag': return Icons.alternate_email_rounded;
      case 'like': return Icons.favorite_rounded;
      case 'comment': return Icons.chat_bubble_rounded;
      case 'sos': return Icons.warning_rounded;
      case 'sitter':
      case 'booking': return Icons.volunteer_activism_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'tag': return Colors.blueAccent;
      case 'like': return Colors.redAccent;
      case 'comment': return Colors.greenAccent.shade700;
      case 'sos': return Colors.red;
      case 'sitter':
      case 'booking': return Colors.indigoAccent;
      default: return PetStyle.primary;
    }
  }
}
