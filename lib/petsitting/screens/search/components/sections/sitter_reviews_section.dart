import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petping/petsitting/models/review_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'sitter_ui_helpers.dart';

class SitterReviewsSection extends StatelessWidget {
  final List<PetReview> reviews;
  final bool isLoading;
  final bool isMyProfile;
  final VoidCallback onAddReviewPressed;

  const SitterReviewsSection({
    super.key,
    required this.reviews,
    required this.isLoading,
    required this.isMyProfile,
    required this.onAddReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Se sta caricando e non abbiamo ancora recensioni in cache
    if (isLoading && reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40), 
          child: CircularProgressIndicator(strokeWidth: 2, color: SitterUIHelpers.primaryIndigo)
        )
      );
    }

    // Se non ci sono recensioni
    if (reviews.isEmpty) {
      return Column(
        children: [
          if (!isMyProfile) _buildAddReviewButton(),
          _buildEmptyState(),
        ],
      );
    }

    // Calcolo statistiche
    Map<int, int> ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double sum = 0;
    for (var r in reviews) {
      int rInt = r.rating.round().clamp(1, 5);
      ratingCounts[rInt] = (ratingCounts[rInt] ?? 0) + 1;
      sum += r.rating;
    }
    double average = sum / reviews.length;

    return Column(
      children: [
        _buildSmartStatsPanel(average, reviews.length, ratingCounts),
        if (!isMyProfile) _buildAddReviewButton(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: reviews.length,
          itemBuilder: (ctx, index) => _buildReviewCard(reviews[index]),
        ),
      ],
    );
  }

  Widget _buildAddReviewButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAddReviewPressed,
          icon: const Icon(Icons.rate_review_rounded, size: 18),
          label: Text("ps_review_btn_publish".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
          style: ElevatedButton.styleFrom(
            backgroundColor: SitterUIHelpers.primaryIndigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSmartStatsPanel(double average, int total, Map<int, int> counts) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: SitterUIHelpers.primaryIndigo.withOpacity(0.1), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(average.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: i < average.round() ? Colors.amber : Colors.grey.shade200,
                    )),
                  ),
                  const SizedBox(height: 4),
                  Text("${total} ${'tab_reviews'.tr()}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1)),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    double percent = total == 0 ? 0 : (counts[star]! / total);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text("$star", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  star >= 4 ? Colors.amber : (star == 3 ? Colors.orange : Colors.redAccent)
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(PetReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: SitterUIHelpers.primaryIndigo.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: SitterUIHelpers.primaryIndigo.withOpacity(0.1),
                backgroundImage: (review.reviewerPhotoUrl != null && review.reviewerPhotoUrl!.isNotEmpty)
                    ? NetworkImage(review.reviewerPhotoUrl!)
                    : null,
                child: (review.reviewerPhotoUrl == null || review.reviewerPhotoUrl!.isEmpty)
                    ? const Icon(Icons.person_rounded, size: 20, color: SitterUIHelpers.primaryIndigo)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E293B))),
                    Text(DateFormat('dd MMM yyyy').format(review.timestamp), style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: i < review.rating ? Colors.amber : Colors.grey.shade200,
                )),
              )
            ],
          ),
          const SizedBox(height: 14),
          Text(review.comment, style: const TextStyle(color: SitterUIHelpers.textColor, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text("ps_reviews_empty".tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
