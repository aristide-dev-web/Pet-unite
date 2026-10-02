import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : const AssetImage('assets/images/default_pet.png') as ImageProvider,
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? 'home_user_default'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (user?.email != null)
          Text(
            user!.email!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
