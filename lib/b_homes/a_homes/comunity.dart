import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  // Funzione per lanciare gli URL in modo sicuro
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Error: Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8), // Sfondo premium
      appBar: AppBar(
        title: Text(
          'community_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _buildSocialCard(
            icon: Icons.camera_alt,
            socialName: 'Instagram',
            subtitle: 'community_insta_sub'.tr(),
            color: Colors.pink,
            onTap: () => _launchURL('https://www.instagram.com/pet_unite'),
          ),
          const SizedBox(height: 15),
          _buildSocialCard(
            icon: Icons.alternate_email_rounded, // Icona per Threads
            socialName: 'Threads',
            subtitle: 'community_threads_sub'.tr(),
            color: Colors.black,
            onTap: () => _launchURL('https://www.threads.net/@pet_unite'),
          ),
          const SizedBox(height: 15),
          _buildSocialCard(
            icon: Icons.facebook,
            socialName: 'Facebook',
            subtitle: 'community_fb_sub'.tr(),
            color: Colors.blue.shade800,
            onTap: () => _launchURL('https://www.facebook.com/PetUnite'),
          ),
          const SizedBox(height: 15),
          _buildSocialCard(
            icon: Icons.videocam_rounded, 
            socialName: 'TikTok',
            subtitle: 'community_tiktok_sub'.tr(),
            color: Colors.black,
            onTap: () => _launchURL('https://www.tiktok.com/@petunite5'),
          ),
          const SizedBox(height: 15),
          _buildSocialCard(
            icon: Icons.send,
            socialName: 'Telegram',
            subtitle: 'community_tg_sub'.tr(),
            color: Colors.blue.shade500,
            onTap: () => _launchURL('https://t.me/petunite'),
          ),
          const SizedBox(height: 15),
          _buildSocialCard(
            icon: Icons.group_work,
            socialName: 'X (Twitter)',
            subtitle: 'community_x_sub'.tr(),
            color: Colors.black,
            onTap: () => _launchURL('https://www.twitter.com/petunite'),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required String socialName,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    socialName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
