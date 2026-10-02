import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';

class SectionFPagamenti extends StatefulWidget {
  final String? stripeAccountId;
  final bool onboardingComplete;
  final Function(String) onAccountCreated;
  final Function(bool) onOnboardingComplete;
  final VoidCallback? onVerified;
  final bool isPanel; 

  const SectionFPagamenti({
    super.key,
    this.stripeAccountId,
    this.onboardingComplete = false,
    required this.onAccountCreated,
    required this.onOnboardingComplete,
    this.onVerified,
    this.isPanel = false,
  });

  @override
  State<SectionFPagamenti> createState() => _SectionFPagamentiState();
}

class _SectionFPagamentiState extends State<SectionFPagamenti> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _isWaitingForStripe = false;

  final Color indigoColor = const Color(0xFF6366F1);
  final Color sitterOrange = const Color(0xFFD97706);
  final Color bgLight = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ascoltaStatoFirestore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForStripe && !widget.onboardingComplete) {
      _verificaStatoRealeStripe(silently: true);
    }
  }

  void _ascoltaStatoFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data();
        bool isComplete = data?['stripeOnboardingComplete'] ?? false;
        String? accId = data?['stripeAccountId'];
        
        if (accId != null && accId != widget.stripeAccountId) {
          widget.onAccountCreated(accId);
        }

        if (isComplete && !widget.onboardingComplete) {
          _sincronizzaHiveEDati(true);
        }
      }
    });
  }

  Future<void> _sincronizzaHiveEDati(bool status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final box = Hive.box<SitterProfile>('sitters_box');
        final profile = box.get(user.uid);
        if (profile != null) {
          await box.put(user.uid, profile.copyWith(stripeOnboardingComplete: status));
        }
      } catch (e) {
        debugPrint("⚠️ Errore Hive: $e");
      }
    }
    widget.onOnboardingComplete(status);
    if (mounted) setState(() => _isWaitingForStripe = false);
  }

  Future<void> _verificaStatoRealeStripe({bool silently = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      
      final response = await http.post(
        Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/checkStripeAccountStatus'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'data': {}}),
      );

      final decoded = jsonDecode(response.body);
      final result = decoded['result'] ?? decoded;

      if (result['success'] == true && result['details_submitted'] == true) {
        await _sincronizzaHiveEDati(true);
        if (widget.onVerified != null) widget.onVerified!();
      } else if (!silently) {
        _mostraMessaggio("ps_reg_pay_error_incomplete".tr());
      }
    } catch (e) {
      if (!silently) debugPrint("❌ Errore verifica: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _avviaOnboardingStripe() async {
    setState(() {
      _isLoading = true;
      _isWaitingForStripe = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/createStripeAccountLink'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'data': {}}),
      );
      final result = jsonDecode(response.body)['result'];
      if (result != null && result['url'] != null) {
        await launchUrl(Uri.parse(result['url']), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Errore onboarding: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _apriDashboardStripe() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/createStripeLoginLink'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'data': {}}),
      );
      final decoded = jsonDecode(response.body);
      final result = decoded['result'] ?? decoded;
      if (result != null && result['url'] != null) {
        await launchUrl(Uri.parse(result['url']), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Errore dashboard: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostraMessaggio(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    bool isConfigured = widget.onboardingComplete;
    bool hasAccount = widget.stripeAccountId != null && widget.stripeAccountId!.isNotEmpty;

    if (widget.isPanel) return _buildPanelVersion(isConfigured, hasAccount);

    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  if (isConfigured) _buildActiveDashboard()
                  else ...[
                    _buildConnectBox(hasAccount),
                    if (hasAccount) ...[
                      const SizedBox(height: 20),
                      _buildVerificationActionBox(),
                    ],
                  ],
                  if (!isConfigured) ...[
                    const SizedBox(height: 25),
                    _buildHelpBox(),
                  ],
                  const SizedBox(height: 20),
                  _buildSecurityInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDashboard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("ps_reg_pay_active_title".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)), const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24)]),
          const SizedBox(height: 15),
          Text("ps_reg_pay_active_sub".tr(), style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _apriDashboardStripe,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_isLoading) const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))
              else ...[Text("ps_reg_pay_btn_dashboard".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(width: 8), const Icon(Icons.open_in_new_rounded, size: 16)]
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelVersion(bool isConfigured, bool hasAccount) {
    Color accentColor = isConfigured ? Colors.green : (hasAccount ? Colors.orange : indigoColor);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 2)),
      child: Row(
        children: [
          Icon(isConfigured ? Icons.account_balance_wallet_rounded : Icons.payments_rounded, color: accentColor, size: 28),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isConfigured ? "ps_panel_active_payments_title".tr() : "ps_panel_config_payments_title".tr(), style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 13)), Text(isConfigured ? "ps_panel_active_payments_sub".tr() : "ps_panel_config_payments_sub".tr(), style: const TextStyle(color: Colors.grey, fontSize: 10))])),
          Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 14),
        ],
      ),
    );
  }

  Widget _buildVerificationActionBox() {
    return GestureDetector(
      onTap: _isLoading ? null : _verificaStatoRealeStripe,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.orange.shade200, width: 2)),
        child: Row(
          children: [
            if (_isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
            else const Icon(Icons.hourglass_empty_rounded, color: Colors.orange, size: 20),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("ps_reg_pay_verify_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 14)), Text("ps_reg_pay_verify_sub".tr(), style: const TextStyle(color: Colors.orange, fontSize: 11))])),
            const Icon(Icons.check_circle_outline_rounded, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectBox(bool hasAccount) {
    Color accentColor = hasAccount ? Colors.orange : indigoColor;
    return GestureDetector(
      onTap: _isLoading ? null : _avviaOnboardingStripe,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: accentColor.withValues(alpha: 0.1), width: 2)),
        child: Row(
          children: [
            Icon(Icons.account_balance, color: accentColor, size: 30),
            const SizedBox(width: 15),
            Expanded(child: Text(hasAccount ? "ps_reg_pay_btn_edit".tr() : "ps_reg_pay_btn_config".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: accentColor))),
            Icon(Icons.open_in_new_rounded, color: accentColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 5, height: 30, decoration: BoxDecoration(color: indigoColor, borderRadius: BorderRadius.circular(10))), const SizedBox(width: 15), Text("ps_reg_pay_header".tr(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))]),
      const SizedBox(height: 8),
      Text("ps_reg_pay_sub_header".tr(), style: const TextStyle(color: Color(0xFF64748B), fontSize: 15)),
    ]);
  }

  Widget _buildHelpBox() {
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sitterOrange.withValues(alpha: 0.1))), child: Text("ps_reg_pay_help_msg".tr(), style: const TextStyle(fontSize: 10, color: Colors.grey)));
  }

  Widget _buildSecurityInfo() {
    return Center(child: Text("ps_reg_pay_security_info".tr(), style: const TextStyle(fontSize: 10, color: Colors.grey)));
  }
}
