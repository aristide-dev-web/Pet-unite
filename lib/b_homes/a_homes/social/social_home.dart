import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/utils/image_picker_helper.dart';
import 'package:petping/utils/firebase_storage_helper.dart';
import 'front_social.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialHome extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onSwitchBack;
  final Map<String, dynamic>? userData; // Dati opzionali passati dal parent

  const SocialHome({
    super.key, 
    required this.currentUserId, 
    required this.onSwitchBack,
    this.userData,
  });

  Future<void> _updateCoverPhoto(BuildContext context) async {
    final image = await ImagePickerHelper.pickImageFromGallery();
    if (image != null) {
      // Usiamo la versione posizionale che ho appena ripristinato
      final url = await FirebaseStorageHelper.uploadImage(image, 'cover_images');
      
      if (url != null) {
        await FirebaseFirestore.instance
            .collection('utenti')
            .doc(currentUserId)
            .update({'coverUrl': url});
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('social_cover_updated'.tr()))
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('utenti').doc(currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return Center(child: Text("profile_not_found".tr()));

        return FrontSocialScreen(
          currentUserId: currentUserId,
          userData: data,
          onUpdateCover: () => _updateCoverPhoto(context),
          onSwitchBack: onSwitchBack,
        );
      }
    );
  }
}
