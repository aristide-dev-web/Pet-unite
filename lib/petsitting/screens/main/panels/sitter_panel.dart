import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/screens/registration/sitter_registration_screen.dart';
import 'package:petping/petsitting/services/sitter_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SitterPanel extends StatefulWidget {
  const SitterPanel({super.key});

  @override
  State<SitterPanel> createState() => _SitterPanelState();
}

class _SitterPanelState extends State<SitterPanel> {
  bool _isPetSitter = false;
  SitterProfile? _profile;
  bool _loading = true;

  final Color sitterColor = const Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _ascoltaAggiornamentiSitter();
  }

  void _ascoltaAggiornamentiSitter() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data();
        final bool isSitter = data?['isPetSitter'] ?? false;
        
        if (isSitter != _isPetSitter) {
          if (!isSitter) {
            _resetToNormal();
          } else {
            _loadStatus();
          }
        } else if (isSitter) {
          final bool stripeComplete = data?['stripeOnboardingComplete'] ?? false;
          if (_profile != null && stripeComplete != _profile!.stripeOnboardingComplete) {
            _loadStatus();
          }
        }
      }
    });
  }

  Future<void> _resetToNormal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final settingsBox = await Hive.openBox('settings_box');
    await settingsBox.put('isPetSitter_${user.uid}', false);

    if (mounted) {
      setState(() {
        _isPetSitter = false;
        _profile = null;
        _loading = false;
      });
    }
  }

  Future<void> _loadStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
    final bool status = userDoc.data()?['isPetSitter'] ?? false;

    if (!status) {
      if (mounted) {
        setState(() {
          _isPetSitter = false;
          _loading = false;
        });
      }
      return;
    }

    await SitterService().syncProfile(user.uid);
    SitterProfile? profile = await SitterService().getSitterProfile(user.uid);

    if (mounted) {
      setState(() {
        _isPetSitter = status;
        _profile = profile;
        _loading = false;
      });
    }
  }

  void _mostraPopupCongratulazioni() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          "ps_panel_congrats_title".tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFD97706)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ps_panel_congrats_msg1".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              "ps_panel_congrats_msg2".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("ps_panel_congrats_btn".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: sitterColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          border: Border.all(color: sitterColor.withOpacity(0.1), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sitterColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: sitterColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: sitterColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: sitterColor.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    // Se l'utente NON è ancora un Pet Sitter
    if (!_isPetSitter) {
      return _buildActionCard(
        title: "ps_panel_become_sitter_title".tr(),
        subtitle: "ps_panel_become_sitter_sub".tr(),
        icon: Icons.assignment_ind_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SitterRegistrationScreen()),
          ).then((_) async {
            await _loadStatus();
            if (_isPetSitter && (_profile?.stripeOnboardingComplete != true)) {
              _mostraPopupCongratulazioni();
            }
          });
        },
      );
    }

    // Se l'utente È Pet Sitter
    bool isStripeComplete = _profile?.stripeOnboardingComplete ?? false;

    return _buildActionCard(
      title: isStripeComplete ? "ps_panel_active_payments_title".tr() : "ps_panel_config_payments_title".tr(),
      subtitle: isStripeComplete 
          ? "ps_panel_active_payments_sub".tr()
          : "ps_panel_config_payments_sub".tr(),
      icon: isStripeComplete ? Icons.account_balance_wallet_rounded : Icons.payments_rounded,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SitterRegistrationScreen(
              isEditing: true,
              sitterProfile: _profile,
              initialStep: 8, // Saltiamo lo step 7 (Inviato/Profilo Attivo) e andiamo diretti allo step 8 (Pagamenti)
            ),
          ),
        ).then((_) => _loadStatus());
      },
    );
  }
}
