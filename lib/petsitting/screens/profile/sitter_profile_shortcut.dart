import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/screens/search/sitter_detail_screen.dart';
import 'package:petping/petsitting/screens/registration/sitter_registration_screen.dart';

class SitterProfileShortcut extends StatelessWidget {
  final Color mainColor;
  
  const SitterProfileShortcut({
    super.key, 
    this.mainColor = const Color(0xFF64B5B4),
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: Hive.box<SitterProfile>('sitters_box').listenable(keys: [user.uid]),
      builder: (context, Box<SitterProfile> box, _) {
        final sitterProfile = box.get(user.uid);

        return GestureDetector(
          onTap: () {
            if (sitterProfile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SitterDetailScreen(sitter: sitterProfile),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SitterRegistrationScreen(),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sitterProfile != null ? Icons.pets_rounded : Icons.add_task_rounded,
                  color: mainColor,
                  size: 18
                ),
                const SizedBox(width: 6),
                Text(
                  sitterProfile != null ? 'ps_shortcut_profile'.tr().toUpperCase() : 'ps_shortcut_become'.tr().toUpperCase(),
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
