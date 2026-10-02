import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petping/petsitting/screens/main/panels/search_panel.dart';
import 'package:petping/petsitting/screens/main/panels/favorites_panel.dart';
import 'package:petping/petsitting/screens/main/panels/bookings_panel.dart';
import 'package:petping/petsitting/screens/main/panels/sitter_panel.dart';
import 'package:easy_localization/easy_localization.dart';

class PetsittingMainScreen extends StatefulWidget {
  final String userId;
  final bool isActive;
  const PetsittingMainScreen({super.key, required this.userId, required this.isActive});

  @override
  State<PetsittingMainScreen> createState() => _PetsittingMainScreenState();
}

class _PetsittingMainScreenState extends State<PetsittingMainScreen> {
  bool _popupGiaMostratoInSessione = false;

  @override
  void didUpdateWidget(covariant PetsittingMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _checkWelcomePopup();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _checkWelcomePopup();
    }
  }

  Future<void> _checkWelcomePopup() async {
    if (_popupGiaMostratoInSessione) return;
    final prefs = await SharedPreferences.getInstance();
    final bool shown = prefs.getBool('petsitting_welcome_shown_${widget.userId}') ?? false;
    if (!shown) {
      _popupGiaMostratoInSessione = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _mostraBenvenuto();
        await prefs.setBool('petsitting_welcome_shown_${widget.userId}', true);
      });
    }
  }

  Future<void> _mostraBenvenuto() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          children: [
            const Icon(Icons.volunteer_activism_rounded, color: Color(0xFFA18CD1)),
            const SizedBox(width: 10),
            Text("dialog_welcome_petsitting_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "dialog_welcome_petsitting_msg1".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 15),
            Text(
              "dialog_welcome_petsitting_msg2".tr(),
              style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("btn_start_petsitting".tr(), style: const TextStyle(color: Color(0xFFA18CD1), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text("label_petsitting_header".tr(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                    Text("label_petsitting_subtitle".tr(), style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SearchPanel(),
                        const SizedBox(height: 20),
                        const FavoritesPanel(),
                        const SizedBox(height: 20),
                        const BookingsPanel(),
                        const SizedBox(height: 20),
                        const SitterPanel(),
                        const SizedBox(height: 40),
                        Text(
                          "label_petsitting_safety".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
