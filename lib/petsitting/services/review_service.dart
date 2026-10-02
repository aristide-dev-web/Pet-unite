import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/petsitting/models/review_model.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _boxName = 'reviews_box';

  // Metodo che accetta l'oggetto PetReview e lo salva con ID generato
  Future<void> addReview(PetReview review) async {
    final reviewId = _db.collection('reviews').doc().id;
    
    // Creiamo una copia della recensione con l'ID generato e includiamo la FOTO
    final finalReview = PetReview(
      id: reviewId,
      sitterId: review.sitterId,
      reviewerId: review.reviewerId,
      reviewerName: review.reviewerName,
      reviewerPhotoUrl: review.reviewerPhotoUrl, // ✅ MANCAVA QUESTO!
      rating: review.rating,
      comment: review.comment,
      timestamp: review.timestamp,
    );

    // 1. Salva su Firestore
    await _db.collection('reviews').doc(reviewId).set(finalReview.toMap());

    // 2. Aggiorna il rating del Sitter
    await _updateSitterRating(finalReview.sitterId, finalReview.rating);

    // 3. Salva in cache locale Hive
    final box = await Hive.openBox<PetReview>(_boxName);
    await box.put(reviewId, finalReview);
  }

  Future<void> _updateSitterRating(String sitterId, double newRating) async {
    final sitterRef = _db.collection('sitters').doc(sitterId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(sitterRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      double currentRating = (data['rating'] ?? 0.0).toDouble();
      int count = data['numeroRecensioni'] ?? 0;

      double updatedRating = ((currentRating * count) + newRating) / (count + 1);
      int updatedCount = count + 1;

      transaction.update(sitterRef, {
        'rating': updatedRating,
        'numeroRecensioni': updatedCount,
      });
    });
  }

  Stream<List<PetReview>> getReviewsForSitter(String sitterId) {
    return _db.collection('reviews')
        .where('sitterId', isEqualTo: sitterId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PetReview.fromMap(doc.data(), doc.id)).toList());
  }
}
