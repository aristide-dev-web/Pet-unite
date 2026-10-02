import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/models/review_model.dart';
import 'package:petping/petsitting/services/review_service.dart';
import 'package:petping/petsitting/services/sitter_favorites_service.dart';
import 'booking/booking_flow_screen.dart';
import '../registration/sitter_registration_screen.dart';
import 'components/sitter_detail_front.dart';

class SitterDetailScreen extends StatefulWidget {
  final SitterProfile sitter;
  const SitterDetailScreen({super.key, required this.sitter});

  @override
  State<SitterDetailScreen> createState() => _SitterDetailScreenState();
}

class _SitterDetailScreenState extends State<SitterDetailScreen> {
  late Stream<List<PetReview>> _reviewsStream;
  late Stream<List<String>> _favoritesStream;

  @override
  void initState() {
    super.initState();
    // Inizializziamo gli stream una volta sola per evitare il caricamento infinito ad ogni build
    _reviewsStream = ReviewService().getReviewsForSitter(widget.sitter.uid);
    _favoritesStream = SitterFavoritesService().getFavoritesStream();
  }

  bool get _isMyProfile => widget.sitter.uid == FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: _favoritesStream,
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? [];
        final isFavorite = favorites.contains(widget.sitter.uid);

        return SitterDetailFront(
          sitter: widget.sitter,
          isMyProfile: _isMyProfile,
          isFavorite: isFavorite,
          onEditPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => SitterRegistrationScreen(
                isEditing: true,
                sitterProfile: widget.sitter,
                initialStep: 1,
              ),
            ),
          ),
          onAddReviewPressed: () => _showAddReviewSheet(context),
          onBookPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => BookingFlowScreen(sitter: widget.sitter))
          ),
          onSavePressed: () => SitterFavoritesService().toggleFavorite(widget.sitter),
          reviewsStream: _reviewsStream,
        );
      }
    );
  }

  void _showAddReviewSheet(BuildContext context) {
    final commentController = TextEditingController();
    double selectedRating = 5.0;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: EdgeInsets.fromLTRB(25, 20, 25, MediaQuery.of(context).viewInsets.bottom + 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 25),
                Text("ps_review_write_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                const SizedBox(height: 10),
                Text("ps_review_write_sub".tr(args: [widget.sitter.username]), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                // STELLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    double starValue = index + 1.0;
                    return IconButton(
                      icon: Icon(
                        selectedRating >= starValue ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 42,
                      ),
                      onPressed: () => setModalState(() => selectedRating = starValue),
                    );
                  }),
                ),
                const SizedBox(height: 25),
  
                // CAMPO TESTO
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "ps_review_hint".tr(),
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(height: 30),
  
                // BOTTONE SALVA
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      final text = commentController.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ps_review_error_empty".tr())));
                        return;
                      }
                      setModalState(() => isSaving = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        // Recuperiamo i dati completi dal profilo utente su Firestore per avere username e foto
                        final userDoc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
                        String nickname = user.displayName ?? "Utente PetPing";
                        String? fotoUrl;

                        if (userDoc.exists) {
                          nickname = userDoc.data()?['username'] ?? nickname;
                          fotoUrl = userDoc.data()?['fotoUrl'];
                        }
  
                        final review = PetReview(
                          id: "", 
                          sitterId: widget.sitter.uid,
                          reviewerId: user.uid,
                          reviewerName: nickname,
                          reviewerPhotoUrl: fotoUrl,
                          rating: selectedRating,
                          comment: text,
                          timestamp: DateTime.now(),
                        );
  
                        await ReviewService().addReview(review);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("ps_review_success".tr()),
                            backgroundColor: Colors.green,
                          ));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("snack_error_msg".tr(args: [e.toString()]))));
                        }
                      } finally {
                        if (context.mounted) setModalState(() => isSaving = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: isSaving 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("ps_review_btn_publish".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
