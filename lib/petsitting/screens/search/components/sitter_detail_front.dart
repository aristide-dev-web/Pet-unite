import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/models/review_model.dart';
import 'package:petping/utils/verification_badges.dart';
import 'sections/sitter_ui_helpers.dart';
import 'sections/sitter_info_section.dart';
import 'sections/sitter_services_section.dart';
import 'sections/sitter_reviews_section.dart';

class SitterDetailFront extends StatefulWidget {
  final SitterProfile sitter;
  final bool isMyProfile;
  final bool isFavorite;
  final VoidCallback onEditPressed;
  final VoidCallback onAddReviewPressed;
  final VoidCallback onBookPressed;
  final VoidCallback onSavePressed;
  final Stream<List<PetReview>> reviewsStream;

  const SitterDetailFront({
    super.key,
    required this.sitter,
    required this.isMyProfile,
    this.isFavorite = false,
    required this.onEditPressed,
    required this.onAddReviewPressed,
    required this.onBookPressed,
    required this.onSavePressed,
    required this.reviewsStream,
  });

  @override
  State<SitterDetailFront> createState() => _SitterDetailFrontState();
}

class _SitterDetailFrontState extends State<SitterDetailFront> {
  int _selectedTab = 0;
  int _currentImage = 0;
  final PageController _imageController = PageController();
  final Color mainColor = const Color(0xFF64B5B4);

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<String> _getGalleryImages() {
    final List<String> images = [];
    if (widget.sitter.fotoChiSei.isNotEmpty) {
      images.addAll(widget.sitter.fotoChiSei.where((img) => img.isNotEmpty && img != widget.sitter.fotoUrl));
    }
    if (widget.sitter.fotoCasa.isNotEmpty) {
      images.addAll(widget.sitter.fotoCasa.where((img) => img.isNotEmpty));
    }
    if (images.isEmpty) {
      if (widget.sitter.fotoUrl.isNotEmpty) {
        images.add(widget.sitter.fotoUrl);
      } else {
        images.add('https://images.unsplash.com/photo-1548191265-cc70d3d45ba1?q=80&w=1000&auto=format&fit=crop');
      }
    }
    return images.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final allImages = _getGalleryImages();
    const Color primaryColor = Color(0xFF6366F1);

    return StreamBuilder<List<PetReview>>(
      stream: widget.reviewsStream,
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        double averageRating = widget.sitter.rating;
        int reviewCount = widget.sitter.numeroRecensioni;

        if (reviews.isNotEmpty) {
          averageRating = reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;
          reviewCount = reviews.length;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B), size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGallery(allImages),
                    _buildProfileHeaderPokeCard(primaryColor, averageRating, reviewCount),
                    _buildPokeTabSelector(primaryColor),
                    _buildTabContent(reviews, isLoading),
                    const SizedBox(height: 120),
                  ],
                ),
              ),

              Positioned(
                top: 50,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavButton(
                      icon: Icons.home_rounded,
                      label: 'home'.tr().toUpperCase(),
                      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    ),
                    const SizedBox(height: 8),
                    _buildNavButton(
                      icon: Icons.public_rounded,
                      label: 'nav_social'.tr().toUpperCase(),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              if (!widget.isMyProfile)
                Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomActionPokeCard(primaryColor)),
            ],
          ),
        );
      }
    );
  }

  Widget _buildNavButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: mainColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: mainColor, fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(List<String> images) {
    return Stack(
      children: [
        SizedBox(
          height: 420,
          width: double.infinity,
          child: PageView.builder(
            controller: _imageController,
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final img = images[index];
              if (img.isEmpty || !img.startsWith('http')) {
                return Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40)
                );
              }
              return Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40)
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 70, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentImage == entry.key ? 22 : 8, height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(_currentImage == entry.key ? 1.0 : 0.5), borderRadius: BorderRadius.circular(10)),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeaderPokeCard(Color primaryColor, double averageRating, int reviewCount) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: const Color(0xFFEEF2FF), width: 4),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 12))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor.withOpacity(0.2), width: 2)),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: (widget.sitter.fotoUrl.isNotEmpty && widget.sitter.fotoUrl.startsWith('http'))
                        ? NetworkImage(widget.sitter.fotoUrl)
                        : null,
                    backgroundColor: Colors.grey.shade50,
                    child: (widget.sitter.fotoUrl.isEmpty || !widget.sitter.fotoUrl.startsWith('http'))
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.sitter.username.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: primaryColor),
                          const SizedBox(width: 4),
                          Text("${widget.sitter.citta}, ${widget.sitter.quartiere}".toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildRatingBadge(averageRating, reviewCount),
                            const SizedBox(width: 10),
                            if (widget.sitter.esperienzaProfessionale) ...[
                              VerificationBadges.premium(label: "Pro", size: 18),
                              const SizedBox(width: 8),
                            ],
                            VerificationBadges.identity(verified: widget.sitter.verificato, size: 18),
                            const SizedBox(width: 8),
                            if (widget.sitter.email.isNotEmpty) ...[
                              VerificationBadges.email(verified: true, size: 18),
                              const SizedBox(width: 8),
                            ],
                            if (widget.sitter.telefono.isNotEmpty) ...[
                              VerificationBadges.phone(verified: true, size: 18),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge(double averageRating, int reviewCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 4),
          Text(averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF92400E))),
          Text(" (${reviewCount})", style: const TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPokeTabSelector(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildPokeTabButton("tab_info".tr(), Icons.info_outline_rounded, 0, primaryColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildPokeTabButton("tab_services".tr(), Icons.pets_rounded, 1, primaryColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildPokeTabButton("tab_reviews".tr(), Icons.star_outline_rounded, 2, primaryColor)),
        ],
      ),
    );
  }

  Widget _buildPokeTabButton(String label, IconData icon, int index, Color primaryColor) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? primaryColor : Colors.grey),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isSelected ? primaryColor : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<PetReview> reviews, bool isLoading) {
    switch (_selectedTab) {
      case 0: return Padding(padding: const EdgeInsets.all(20), child: SitterInfoSection(sitter: widget.sitter, isMyProfile: widget.isMyProfile, onEditPressed: widget.onEditPressed));
      case 1: return Padding(padding: const EdgeInsets.all(20), child: SitterServicesSection(sitter: widget.sitter));
      case 2: return SitterReviewsSection(reviews: reviews, isLoading: isLoading, isMyProfile: widget.isMyProfile, onAddReviewPressed: widget.onAddReviewPressed);
      default: return const SizedBox();
    }
  }

  Widget _buildBottomActionPokeCard(Color primaryColor) {
    return Container(
      margin: const Offset(0, 0) == Offset.zero ? const EdgeInsets.all(20) : EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 15))]),
      child: Row(
        children: [
          IconButton(onPressed: widget.onSavePressed, icon: Icon(widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: primaryColor, size: 32)),
          const SizedBox(width: 20),
          Expanded(child: ElevatedButton(onPressed: widget.onBookPressed, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text("btn_book_now".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)))),
        ],
      ),
    );
  }
}
