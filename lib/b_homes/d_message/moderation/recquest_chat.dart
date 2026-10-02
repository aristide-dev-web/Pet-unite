import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class RequestChatScreen extends StatefulWidget {
  final String fromUserId;
  final String toUserId;

  const RequestChatScreen({
    super.key,
    required this.fromUserId,
    required this.toUserId,
  });

  @override
  State<RequestChatScreen> createState() => _RequestChatScreenState();
}

class _RequestChatScreenState extends State<RequestChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendRequest() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    await FirebaseFirestore.instance
        .collection('chatRequests')
        .doc(widget.toUserId)
        .collection('requests')
        .add({
      'fromUserId': widget.fromUserId,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => _isSending = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('chat_request_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('chat_request_msg'.tr()),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'chat_request_hint'.tr(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSending ? null : _sendRequest,
              child: _isSending
                  ? const CircularProgressIndicator()
                  : Text('chat_request_btn_send'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}