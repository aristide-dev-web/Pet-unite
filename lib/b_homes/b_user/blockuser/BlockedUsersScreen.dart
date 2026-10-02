import 'package:flutter/material.dart';
import 'package:petping/b_homes/b_user/blockuser/block_user_service.dart';
import 'package:easy_localization/easy_localization.dart';

class BlockedUsersScreen extends StatefulWidget {
  final String currentUserId;

  const BlockedUsersScreen({super.key, required this.currentUserId});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late Future<List<Map<String, dynamic>>> _blockedUsersFuture;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  void _loadBlockedUsers() {
    _blockedUsersFuture = BlockUserService.getBlockedUsers(widget.currentUserId);
  }

  void _unblockUser(String blockedId) async {
    await BlockUserService.unblockUser(
      blockerId: widget.currentUserId,
      blockedId: blockedId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('snack_unblocked_user'.tr())),
      );
      setState(() {
        _loadBlockedUsers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_label_blocked_users'.tr())),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _blockedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('auth_loading_error'.tr()));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('settings_blocked_empty'.tr()));
          }

          final blockedUsers = snapshot.data!;

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return ListTile(
                leading: const Icon(Icons.person_off),
                title: Text(user['username']),
                trailing: IconButton(
                  icon: const Icon(Icons.lock_open),
                  onPressed: () => _unblockUser(user['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}