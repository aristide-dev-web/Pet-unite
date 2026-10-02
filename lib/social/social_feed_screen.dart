import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/social/social_memoria_firebase.dart';
import 'package:petping/social/social_stories_bar.dart';
import 'package:petping/social/story/social_story_editor.dart';
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/d_tab_sds/services/sds_cache_service.dart';
import 'package:petping/social/story/social_story_model.dart';
import 'package:petping/social/post/social_post_card.dart';
import 'package:petping/social/post/social_create_post_sheet.dart';
import 'package:petping/utils/image_optimizer.dart';

class SocialFeedScreen extends StatefulWidget {
  final String currentUserId;
  const SocialFeedScreen({super.key, required this.currentUserId});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _socialService = SocialMemoriaFirebase();
  Position? _currentPosition;
  bool _isLoadingStories = false;
  bool _isPaginationLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _inizializzaPosizione();
    _socialService.caricaBatchPost(categoria: 'generale');

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  Future<void> _inizializzaPosizione() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _currentPosition = pos);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadStory(Map<String, dynamic> userData) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SocialStoryEditor(imageFile: File(image.path))),
      );

      if (result != null && result is Map) {
        setState(() => _isLoadingStories = true);
        try {
          File optimizedImage = await ImageOptimizer.optimize(
            file: result['image'],
            quality: 70,
            maxWidth: 1080,
          );

          await _socialService.creaStoria(
            uid: widget.currentUserId,
            autore: userData['username'] ?? 'social_feed_default_user'.tr(),
            fotoProfilo: userData['fotoUrl'],
            immagineFile: optimizedImage,
            lat: _currentPosition?.latitude,
            lng: _currentPosition?.longitude,
          );
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('social_feed_story_published'.tr())));
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('social_feed_error_prefix'.tr(args: [e.toString()]))));
        } finally {
          if (mounted) setState(() => _isLoadingStories = false);
        }
      }
    }
  }

  Future<void> _loadMorePosts(String road) async {
    if (_isPaginationLoading) return;
    setState(() => _isPaginationLoading = true);
    await _socialService.caricaBatchPost(categoria: road, limit: 6);
    if (mounted) setState(() => _isPaginationLoading = false);
  }

  void _showCreatePostModal(String categoria, Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialCreatePostSheet(
        currentUserId: widget.currentUserId,
        categoria: categoria,
        userData: userData,
        currentPosition: _currentPosition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('utenti').doc(widget.currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        return Scaffold(
          backgroundColor: PetStyle.background,
          body: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 120.0,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Pet Unite",
                            style: const TextStyle(
                              color: PetStyle.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.pets_rounded, color: PetStyle.primary.withOpacity(0.5), size: 18),
                        ],
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, PetStyle.primary.withOpacity(0.05)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: _buildPostInputBox(userData),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: _buildStoriesSection(userData),
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabDelegate(
                      Container(
                        height: 60,
                        color: PetStyle.background,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: _buildNavigationTabs(),
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostList('generale', userData),
                    _buildPostList('eventi', userData),
                    _buildPostList('avvistamenti', userData),
                  ],
                ),
              ),
              if (_isLoadingStories)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator(color: PetStyle.primary)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostInputBox(Map<String, dynamic> userData) {
    String placeholder = 'social_input_placeholder_default'.tr();
    if (_tabController.index == 1) placeholder = 'social_input_placeholder_event'.tr();
    if (_tabController.index == 2) placeholder = 'social_input_placeholder_sighting'.tr();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: PetStyle.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PetStyle.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: PetStyle.lightGrey,
              backgroundImage: userData['fotoUrl'] != null ? NetworkImage(userData['fotoUrl']) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                String road = 'generale';
                if (_tabController.index == 1) road = 'eventi';
                if (_tabController.index == 2) road = 'avvistamenti';
                _showCreatePostModal(road, userData);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: PetStyle.lightGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  placeholder,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: PetStyle.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      labelColor: Colors.white,
      unselectedLabelColor: PetStyle.grey,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelPadding: EdgeInsets.zero,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
      tabs: [
        Tab(text: "social_tab_feed".tr()),
        Tab(text: "social_tab_events".tr()),
        Tab(text: "social_tab_sightings".tr()),
      ],
    );
  }

  Widget _buildPostList(String road, Map<String, dynamic> userData) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          _loadMorePosts(road);
        }
        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: Hive.box<SocialPost>(SDSCacheService.postsBoxName).listenable(),
        builder: (context, Box<SocialPost> box, _) {
          var allPosts = box.values.where((p) => p.categoria == road).toList();

          if (_currentPosition != null) {
            allPosts.sort((a, b) {
              if (a.lat != null && a.lng != null && b.lat != null && b.lng != null) {
                double distA = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, a.lat!, a.lng!);
                double distB = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, b.lat!, b.lng!);
                return distA.compareTo(distB);
              }
              if (a.lat != null && a.lng != null) return -1;
              if (b.lat != null && b.lng != null) return 1;
              return (b.timestamp ?? DateTime.now()).compareTo(a.timestamp ?? DateTime.now());
            });
          } else {
            allPosts.sort((a, b) => (b.timestamp ?? DateTime.now()).compareTo(a.timestamp ?? DateTime.now()));
          }

          if (allPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets_rounded, size: 64, color: PetStyle.primary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    "social_empty_feed".tr(),
                    style: TextStyle(color: PetStyle.grey.withOpacity(0.5), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 100),
            physics: const BouncingScrollPhysics(),
            itemCount: allPosts.length + (_isPaginationLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == allPosts.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: PetStyle.primary, strokeWidth: 2)),
                );
              }
              final post = allPosts[index];
              return SocialPostCard(
                post: post,
                currentUserId: widget.currentUserId,
                userData: userData,
                currentPosition: _currentPosition,
                onDelete: () => setState(() {}),
              );
            },
          );
        }
      ),
    );
  }

  Widget _buildStoriesSection(Map<String, dynamic> userData) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SocialStory>(SDSCacheService.storiesBoxName).listenable(),
      builder: (context, Box<SocialStory> box, _) {
        final stories = box.values.toList();
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          padding: const EdgeInsets.only(bottom: 10),
          child: SocialStoriesBar(
            mainColor: PetStyle.primary,
            userPhotoUrl: userData['fotoUrl'],
            onAddStory: () => _pickAndUploadStory(userData),
            stories: stories,
          ),
        );
      },
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverTabDelegate(this.child);

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => true;
}
