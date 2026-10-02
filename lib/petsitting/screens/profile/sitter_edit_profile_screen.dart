import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/services/sitter_service.dart';
import 'package:petping/petsitting/screens/registration/sitter_registration_screen.dart';

class SitterEditProfileScreen extends StatefulWidget {
  const SitterEditProfileScreen({super.key});

  @override
  State<SitterEditProfileScreen> createState() => _SitterEditProfileScreenState();
}

class _SitterEditProfileScreenState extends State<SitterEditProfileScreen> {
  bool _isLoading = true;
  bool _isDeleting = false;
  SitterProfile? _profile;

  final Color primaryIndigo = const Color(0xFF6366F1);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = await SitterService().getSitterProfile(user.uid);
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _confermaEliminazioneSitter() async {
    final confermato = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Text("ps_edit_delete_dialog_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("ps_edit_delete_dialog_msg".tr(), style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("btn_cancel_upper".tr(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("ps_edit_btn_delete_confirm".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confermato == true) {
      setState(() => _isDeleting = true);
      try {
        await SitterService().deleteSitterProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("ps_edit_delete_success".tr()), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("snack_error_msg".tr(args: [e.toString()])), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: Text("ps_edit_header".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
        backgroundColor: primaryIndigo,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isDeleting 
        ? const Center(child: CircularProgressIndicator(color: Colors.red))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePreview(),
                const SizedBox(height: 25),
                _buildQuickActions(),
                const SizedBox(height: 25),
                _buildServiceSummary(),
                const SizedBox(height: 25),
                _buildDangerZone(),
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }

  Widget _buildProfilePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: primaryIndigo.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: bgLight,
                backgroundImage: (_profile?.fotoUrl != null && _profile!.fotoUrl.isNotEmpty) 
                    ? NetworkImage(_profile!.fotoUrl) 
                    : null,
                child: (_profile?.fotoUrl == null || _profile!.fotoUrl.isEmpty) 
                    ? Icon(Icons.person, size: 45, color: primaryIndigo.withOpacity(0.5)) 
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_profile?.username ?? "Pet Sitter", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textColor)),
                    const SizedBox(height: 4),
                    Text(_profile?.email ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text("ps_edit_status_active".tr().toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("ps_reg_exp_title".tr(), "${_profile?.anniEsperienza ?? 0} ${"pet_age_years".tr()}"),
              _buildStat("ps_reg_radius_title".tr(), "${_profile?.raggioKm.toInt() ?? 0} km"),
              _buildStat("ps_edit_stat_services".tr(), "${_profile?.serviziAttivi.length ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryIndigo)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ps_edit_quick_actions".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B), fontSize: 12, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                "ps_edit_btn_edit_info".tr().toUpperCase(), 
                Icons.edit_document, 
                Colors.blue, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => SitterRegistrationScreen(isEditing: true, sitterProfile: _profile))).then((_) => _loadProfile())
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _actionCard(
                "ps_edit_btn_view_profile".tr().toUpperCase(), 
                Icons.visibility, 
                Colors.orange, 
                () {
                  // Azione opzionale: apre il dettaglio pubblico
                }
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSummary() {
    final servizi = _profile?.serviziAttivi ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ps_edit_services_active".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 15),
          if (servizi.isEmpty)
            Text("ps_edit_services_none".tr(), style: const TextStyle(color: Colors.grey, fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: servizi.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: primaryIndigo.withOpacity(0.1))),
                child: Text(s, style: TextStyle(color: primaryIndigo, fontSize: 12, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text("ps_edit_danger_zone".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _confermaEliminazioneSitter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.delete_forever_rounded),
              label: Text("ps_edit_btn_delete_sitter".tr().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
