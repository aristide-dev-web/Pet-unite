import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petping/social/page/social_page_model.dart';
import 'package:petping/social/page/social_page_service.dart';
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/social/post/social_post_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialPageDetailScreen extends StatefulWidget {
  final String pageId;
  const SocialPageDetailScreen({super.key, required this.pageId});

  @override
  State<SocialPageDetailScreen> createState() => _SocialPageDetailScreenState();
}

class _SocialPageDetailScreenState extends State<SocialPageDetailScreen> {
  final _pageService = SocialPageService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('pagine').doc(widget.pageId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!snapshot.data!.exists) return Scaffold(body: Center(child: Text("social_page_not_found".tr())));

        final page = SocialPage.fromFirestore(snapshot.data!);
        final bool isAdmin = page.adminIds.contains(currentUserId);
        final bool isFollowing = page.followerIds.contains(currentUserId);

        return Scaffold(
          backgroundColor: const Color(0xFFF2F5F8),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(page, isAdmin),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildPageHeader(page, isFollowing, isAdmin),
                    const Divider(height: 1),
                    _buildPagePosts(page),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(SocialPage page, bool isAdmin) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: PetStyle.primary,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black26,
          child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black26,
              child: Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            onPressed: () {
              // Schermata modifica pagina
            },
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (page.fotoCopertina != null)
              Image.network(page.fotoCopertina!, fit: BoxFit.cover)
            else
              Container(color: PetStyle.primary.withOpacity(0.5)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(SocialPage page, bool isFollowing, bool isAdmin) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: page.fotoProfilo != null ? NetworkImage(page.fotoProfilo!) : null,
                    backgroundColor: PetStyle.lightGrey,
                    child: page.fotoProfilo == null ? const Icon(Icons.flag, size: 40, color: Colors.grey) : null,
                  ),
                ),
              ),
              const Spacer(),
              if (!isAdmin)
                ElevatedButton(
                  onPressed: () => _pageService.followPage(page.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? PetStyle.lightGrey : PetStyle.primary,
                    foregroundColor: isFollowing ? Colors.black87 : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(isFollowing ? 'following_btn'.tr().toUpperCase() : 'follow_btn'.tr().toUpperCase()),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(page.nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          Text(page.categoria, style: TextStyle(color: PetStyle.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          if (page.bio != null && page.bio!.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(page.bio!, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              _statItem(page.followerIds.length.toString(), "follow_btn".tr()),
              const SizedBox(width: 20),
              // Qui potremmo mettere altre statistiche
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPagePosts(SocialPage page) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post')
          .where('uid', isEqualTo: page.id)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator()));
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(60),
            child: Center(child: Text("social_page_empty_posts".tr(), style: const TextStyle(color: Colors.grey))),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final post = SocialPost.fromFirestore(docs[index]);
            return _buildPagePostCard(post);
          },
        );
      },
    );
  }

  Widget _buildPagePostCard(SocialPost post) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SocialPostDetailScreen(postId: post.id, currentUserId: currentUserId))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.immagineUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(post.immagineUrl!, fit: BoxFit.cover, width: double.infinity, height: 200),
              ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.testo, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("social_post_details_label".tr(), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
