import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  void _inviaFeedback() {
    if (_formKey.currentState!.validate()) {
      final messaggio = _messageController.text.trim();
      final email = _emailController.text.trim();

      // TODO: invia il feedback via email o API
      // es: inviaFeedbackAPI(messaggio, email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('feedback_success_msg'.tr())),
      );

      _formKey.currentState!.reset();
      _messageController.clear();
      _emailController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('feedback_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'feedback_msg_label'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (val) =>
                val != null && val.trim().isNotEmpty ? null : 'feedback_error_empty'.tr(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'support.petunite@gmail.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val != null && val.isNotEmpty && !val.contains('@')) {
                    return 'error_invalid_email'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _inviaFeedback,
                child: Text('btn_send'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}