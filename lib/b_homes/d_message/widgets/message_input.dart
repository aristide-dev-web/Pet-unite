import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onPlusPressed;
  final VoidCallback? onLocationPressed; // Aggiunto per la posizione

  const MessageInput({
    super.key, 
    required this.onSend, 
    this.onPlusPressed,
    this.onLocationPressed,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // TASTO PIU (Prenotazioni)
            if (widget.onPlusPressed != null)
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                onPressed: widget.onPlusPressed,
              ),
            // TASTO POSIZIONE (📍)
            if (widget.onLocationPressed != null)
              IconButton(
                icon: const Icon(Icons.location_on_outlined, color: Colors.redAccent),
                onPressed: widget.onLocationPressed,
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'chat_input_hint'.tr(),
                  hintStyle: const TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
