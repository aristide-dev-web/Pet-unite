import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class RitrovatoButton extends StatefulWidget {
  final String animalDocId;
  final String ownerId;
  final VoidCallback? onRitrovato;

  const RitrovatoButton({
    super.key,
    required this.animalDocId,
    required this.ownerId,
    this.onRitrovato,
  });

  @override
  State<RitrovatoButton> createState() => _RitrovatoButtonState();
}

class _RitrovatoButtonState extends State<RitrovatoButton> {
  bool _isLoading = false;

  Future<void> _marcareComeRitrovato() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(
          children: [
            const Icon(Icons.celebration_rounded, color: Color(0xFF2ECC71), size: 50),
            const SizedBox(height: 15),
            Text('sos_found_title'.tr(), 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF2C3E50))),
          ],
        ),
        content: Text(
          'sos_found_msg'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.grey),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('btn_not_yet'.tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text('btn_yes_home'.tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Incrementa il contatore globale
      final statsRef = FirebaseFirestore.instance.collection('app_stats').doc('smarriti');
      batch.set(statsRef, {'ritrovati_totali': FieldValue.increment(1)}, SetOptions(merge: true));

      // 2. Incrementa il contatore sull'utente
      final userRef = FirebaseFirestore.instance.collection('utenti').doc(widget.ownerId);
      batch.update(userRef, {'ritrovatiCount': FieldValue.increment(1)});

      // 3. Elimina il post
      final animalRef = FirebaseFirestore.instance.collection('animali_smarriti').doc(widget.animalDocId);
      batch.delete(animalRef);

      await batch.commit();

      if (mounted) {
        if (widget.onRitrovato != null) {
          widget.onRitrovato!();
        } else {
          Navigator.of(context).pop();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('snack_celebration'.tr()),
            backgroundColor: const Color(0xFF27AE60),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27AE60).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _marcareComeRitrovato,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'sos_together_again'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'sos_share_happy_ending'.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
