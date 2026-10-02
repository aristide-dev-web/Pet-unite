import 'package:flutter/material.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';

class OwnerProfileButton extends StatelessWidget {
  final String userId;
  final String currentUserId;
  final bool compact;

  const OwnerProfileButton({
    super.key,
    required this.userId,
    required this.currentUserId,
    this.compact = false,
    dynamic username,
    dynamic publicPosts,
    dynamic publicData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SocialProfiloUtenteScreen(
              userId: userId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade100, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle_outlined, 
              color: Colors.blue.shade700, 
              size: 14
            ),
            const SizedBox(width: 6),
            Text(
              "PROFILO",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.blue.shade700,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
