import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _loading = false;

  Future<void> _reauthenticate(String oldPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(cred);
  }

  Future<void> _updateEmailOnly() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (_emailController.text.isNotEmpty && _emailController.text != user?.email) {
        await user?.verifyBeforeUpdateEmail(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('acc_email_verify_msg'.tr())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('msg_error_save'.tr(args: [e.toString()]))));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updatePasswordOnly() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('acc_pass_error_empty'.tr())),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _reauthenticate(_oldPasswordController.text.trim());
      await FirebaseAuth.instance.currentUser?.updatePassword(_newPasswordController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('acc_pass_success'.tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('msg_error_save'.tr(args: [e.toString()]))));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('acc_reset_email_sent'.tr())),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('settings_label_manage_account'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('acc_edit_email'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildRoundedField(_emailController, 'acc_new_email_label'.tr(), TextInputType.emailAddress),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _updateEmailOnly,
                child: _loading ? const CircularProgressIndicator() : Text('acc_btn_save_email'.tr()),
              ),
              const Divider(height: 40),
              Text('acc_edit_pass'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildRoundedField(_oldPasswordController, 'acc_old_pass_label'.tr(), TextInputType.text, obscure: true),
              const SizedBox(height: 12),
              _buildRoundedField(_newPasswordController, 'acc_new_pass_label'.tr(), TextInputType.text, obscure: true),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _updatePasswordOnly,
                child: _loading ? const CircularProgressIndicator() : Text('acc_btn_save_pass'.tr()),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _resetPassword,
                child: Text('acc_btn_reset_pass'.tr()),
              ),
              const SizedBox(height: 16),
              if (user?.email != null)
                Text('acc_current_email'.tr(args: [user!.email!]), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedField(TextEditingController controller, String label, TextInputType type, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (val) {
        if (label.toLowerCase().contains('email') && (val == null || !val.contains('@'))) {
          return 'error_invalid_email'.tr();
        }
        if (label.toLowerCase().contains('password') && (val == null || val.length < 6)) {
          return 'error_pass_min_length'.tr();
        }
        return null;
      },
    );
  }
}