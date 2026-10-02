import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/models/user_profile_model.dart';
import 'package:petping/utils/ban_service.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('admin_dashboard_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'admin_search_user_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('utenti').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('error_generic'.tr()));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final username = (data['username'] ?? "").toString().toLowerCase();
                  final email = (data['emails'] != null && (data['emails'] as List).isNotEmpty)
                      ? (data['emails'] as List).first.toString().toLowerCase()
                      : "";
                  return username.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return Center(child: Text('admin_no_users_found'.tr()));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final profile = UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    final isBanned = (doc.data() as Map<String, dynamic>)['banned'] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profile.fotoUrl.isNotEmpty ? NetworkImage(profile.fotoUrl) : null,
                          child: profile.fotoUrl.isEmpty ? const Icon(Icons.person) : null,
                        ),
                        title: Text(profile.username.isNotEmpty ? profile.username : 'unnamed_user'.tr()),
                        subtitle: Text(isBanned ? 'status_banned'.tr() : 'status_active'.tr(),
                            style: TextStyle(color: isBanned ? Colors.red : Colors.green)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isBanned)
                              IconButton(
                                icon: const Icon(Icons.undo, color: Colors.green),
                                onPressed: () => _confirmUnban(profile.uid, profile.username),
                                tooltip: 'admin_unban_tooltip'.tr(),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.gavel_rounded, color: Colors.red),
                                onPressed: () => _confirmBan(profile.uid, profile.username),
                                tooltip: 'admin_ban_tooltip'.tr(),
                              ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SocialProfiloUtenteScreen(userId: profile.uid)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBan(String uid, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('admin_ban_confirm_title'.tr()),
        content: Text('admin_ban_confirm_desc'.tr(args: [username])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('btn_cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await BanService.banUser(uid);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('admin_ban_success'.tr())));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error_generic'.tr())));
              }
            },
            child: Text('admin_ban_user_btn'.tr()),
          ),
        ],
      ),
    );
  }

  void _confirmUnban(String uid, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('admin_unban_confirm_title'.tr()),
        content: Text('admin_unban_confirm_desc'.tr(args: [username])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('btn_cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await BanService.unbanUser(uid);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('admin_unban_success'.tr())));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error_generic'.tr())));
              }
            },
            child: Text('admin_unban_user_btn'.tr()),
          ),
        ],
      ),
    );
  }
}
