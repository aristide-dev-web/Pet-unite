import 'dart:async';
import 'package:flutter/material.dart';
import 'package:petping/social/story/social_story_model.dart';

class SocialStoriesBar extends StatelessWidget {
  final Color mainColor;
  final String? userPhotoUrl;
  final VoidCallback onAddStory;
  final List<SocialStory> stories;

  const SocialStoriesBar({
    super.key,
    required this.mainColor,
    this.userPhotoUrl,
    required this.onAddStory,
    required this.stories,
  });

  // Palette Premium Completa (Stessa dei Post)
  static const List<List<Color>> _premiumGradients = [
    [Color(0xFF6366F1), Color(0xFF818CF8)], // Indigo/Blue
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)], // Purple/Pink
    [Color(0xFFE67E22), Color(0xFFF39C12)], // Orange/Yellow
    [Color(0xFF64B5B4), Color(0xFF2C5F78)], // Teal/Deep Blue
    [Color(0xFFFA709A), Color(0xFFFEE140)], // Pink/Yellow
    [Color(0xFF00B4D8), Color(0xFF90E0EF)], // Sky Blue
    [Color(0xFF7209B7), Color(0xFFB5179E)], // Deep Purple/Magenta
    [Color(0xFF4CC9F0), Color(0xFF4361EE)], // Bright Blue
    [Color(0xFFF72585), Color(0xFF7209B7)], // Neon Pink/Purple
    [Color(0xFF2ECC71), Color(0xFF27AE60)], // Emerald Green
    [Color(0xFFF1C40F), Color(0xFFF39C12)], // Gold/Orange
    [Color(0xFFE74C3C), Color(0xFFC0392B)], // Soft Red
    [Color(0xFF1ABC9C), Color(0xFF16A085)], // Mint/Turquoise
    [Color(0xFF9B59B6), Color(0xFF8E44AD)], // Amethyst Purple
    [Color(0xFFFD746C), Color(0xFFFF9068)], // Coral Sunset
    [Color(0xFF1D976C), Color(0xFF93F9B9)], // Fresh Grass
    [Color(0xFF0052D4), Color(0xFF4364F7)], // Classic Blue
    [Color(0xFFEB3349), Color(0xFFF45C43)], // Cherry Gradient
  ];

  List<Color> _getUserGradient(String uid) {
    final int index = uid.hashCode.abs() % _premiumGradients.length;
    return _premiumGradients[index];
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<SocialStory>> groupedStories = {};
    for (var story in stories) {
      final String uid = story.uid;
      if (uid.isEmpty) continue;
      if (!groupedStories.containsKey(uid)) {
        groupedStories[uid] = [];
      }
      groupedStories[uid]!.add(story);
    }

    final List<String> userIds = groupedStories.keys.toList();

    return Container(
      height: 135,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: userIds.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildAddStoryAvatar(context);
          
          final String uid = userIds[index - 1];
          final List<SocialStory> userStories = groupedStories[uid]!;
          final String autore = userStories.first.autore;
          final String? fotoProfilo = userStories.first.fotoProfilo;
          final String storyImage = userStories.first.immagineUrl;
          final List<Color> gradient = _getUserGradient(uid);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SocialStoryViewer(
                    groupedStories: groupedStories,
                    initialUserIndex: index - 1,
                  ),
                ),
              );
            },
            child: _buildUserStoryAvatar(autore, fotoProfilo, storyImage, gradient),
          );
        },
      ),
    );
  }

  Widget _buildAddStoryAvatar(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white,
        border: Border.all(color: mainColor.withOpacity(0.5), width: 2.5),
        boxShadow: [
          BoxShadow(color: mainColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              color: Colors.grey.shade50,
              child: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                  ? Image.network(userPhotoUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  : const Center(child: Icon(Icons.person, color: Colors.grey, size: 30)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          const Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Text(
              'AGGIUNGI',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 11,
                backgroundColor: mainColor,
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onAddStory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStoryAvatar(String nome, String? foto, String? storyImage, List<Color> gradient) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white,
        border: Border.all(color: gradient[0].withOpacity(0.8), width: 2.5),
        boxShadow: [
          BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: storyImage != null && storyImage.isNotEmpty
                ? Image.network(storyImage, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                : Container(color: Colors.grey.shade300),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7)
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                backgroundImage: (foto != null && foto.isNotEmpty) ? NetworkImage(foto) : null,
                child: (foto == null || foto.isEmpty) ? const Icon(Icons.person, size: 12) : null,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 6,
            right: 6,
            child: Text(
              nome.split(' ').first.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 10, 
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialStoryViewer extends StatefulWidget {
  final Map<String, List<SocialStory>> groupedStories;
  final int initialUserIndex;

  const SocialStoryViewer({
    super.key,
    required this.groupedStories,
    required this.initialUserIndex,
  });

  @override
  State<SocialStoryViewer> createState() => _SocialStoryViewerState();
}

class _SocialStoryViewerState extends State<SocialStoryViewer> {
  late PageController _userPageController;
  late int _currentUserIndex;
  int _currentStoryIndex = 0;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _userPageController = PageController(initialPage: widget.initialUserIndex);
    _startTimer();
  }

  void _startTimer() {
    _progress = 0.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          if (_progress < 1.0) {
            _progress += 0.01; 
          } else {
            _timer?.cancel();
            _nextStory();
          }
        });
      }
    });
  }

  void _nextStory() {
    final List<String> userIds = widget.groupedStories.keys.toList();
    final List<SocialStory> stories = widget.groupedStories[userIds[_currentUserIndex]]!;

    if (_currentStoryIndex < stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _startTimer();
      });
    } else if (_currentUserIndex < userIds.length - 1) {
      _userPageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _startTimer();
      });
    } else if (_currentUserIndex > 0) {
      _userPageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _userPageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> userIds = widget.groupedStories.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _userPageController,
        onPageChanged: (index) {
          setState(() {
            _currentUserIndex = index;
            _currentStoryIndex = 0; 
            _startTimer();
          });
        },
        itemCount: userIds.length,
        itemBuilder: (context, userIndex) {
          final List<SocialStory> userStories = widget.groupedStories[userIds[userIndex]]!;
          
          final int displayIdx = (userIndex == _currentUserIndex) 
              ? _currentStoryIndex.clamp(0, userStories.length - 1) 
              : 0;
          
          final story = userStories[displayIdx];
          final String imageUrl = story.immagineUrl;

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: imageUrl.isNotEmpty 
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain, 
                        key: ValueKey(imageUrl), 
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 50)
                        ),
                      )
                    : const Center(child: Text("Immagine non disponibile", style: TextStyle(color: Colors.white))),
                ),
              ),
              
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(userStories.length, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: LinearProgressIndicator(
                                value: (userIndex == _currentUserIndex && index == displayIdx) 
                                    ? _progress 
                                    : (index < displayIdx ? 1.0 : 0.0),
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: (story.fotoProfilo != null && story.fotoProfilo!.isNotEmpty)
                                ? NetworkImage(story.fotoProfilo!) : null,
                            child: (story.fotoProfilo == null || story.fotoProfilo!.isEmpty) 
                                ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            story.autore, 
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 1))]
                            )
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 28), 
                            onPressed: () => Navigator.pop(context)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _previousStory, 
                      behavior: HitTestBehavior.opaque, 
                      child: Container(color: Colors.transparent)
                    )
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _nextStory, 
                      behavior: HitTestBehavior.opaque, 
                      child: Container(color: Colors.transparent)
                    )
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
