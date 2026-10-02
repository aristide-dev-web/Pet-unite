import 'dart:io';
import 'package:flutter/material.dart';

class SocialStoryEditor extends StatefulWidget {
  final File imageFile;

  const SocialStoryEditor({super.key, required this.imageFile});

  @override
  State<SocialStoryEditor> createState() => _SocialStoryEditorState();
}

class _SocialStoryEditorState extends State<SocialStoryEditor> {
  void _publish() {
    // Restituiamo al FrontSocial la foto
    Navigator.pop(context, {
      'image': widget.imageFile,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Crea Storia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _publish,
            child: const Text("PUBBLICA", style: TextStyle(color: Color(0xFF64B5B4), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ANTEPRIMA FOTO
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.white10, blurRadius: 20)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(widget.imageFile, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
