import 'package:flutter/material.dart';
import 'user_model.dart';
import 'user_follow_service.dart';
import 'package:easy_localization/easy_localization.dart';

class FollowUsersScreen extends StatefulWidget {
  final String currentUserId;
  const FollowUsersScreen({super.key, required this.currentUserId});

  @override
  State<FollowUsersScreen> createState() => _FollowUsersScreenState();
}

class _FollowUsersScreenState extends State<FollowUsersScreen> {
  final List<UserModel> utenti = [
    UserModel(id: '1', nome: 'Luna', avatarUrl: 'https://...'),
    UserModel(id: '2', nome: 'Milo', avatarUrl: 'https://...'),
    UserModel(id: '3', nome: 'Zoe', avatarUrl: 'https://...'),
  ];

  final UserFollowService _followService = UserFollowService();

  void _toggleFollow(UserModel utente) async {
    setState(() => utente.seguito = !utente.seguito);
    if (utente.seguito) {
      await _followService.segui(widget.currentUserId, utente.id);
    } else {
      await _followService.smettiDiSeguire(widget.currentUserId, utente.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('follow_users_title'.tr())),
      body: ListView.builder(
        itemCount: utenti.length,
        itemBuilder: (context, index) {
          final utente = utenti[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(utente.avatarUrl)),
            title: Text(utente.nome),
            trailing: ElevatedButton(
              onPressed: () => _toggleFollow(utente),
              child: Text(utente.seguito ? 'following_btn'.tr() : 'follow_btn'.tr()),
            ),
          );
        },
      ),
    );
  }
}