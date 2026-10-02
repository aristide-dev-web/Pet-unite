import 'package:flutter/material.dart';

class PetStyle {
  // Brand Colors
  static const Color primary = Color(0xFF64B5B4);
  static const Color background = Color(0xFFF2F5F8);
  static const Color grey = Color(0xFF65676B);
  static const Color lightGrey = Color(0xFFF0F2F5);

  // Icons
  static const IconData photo = Icons.photo_library_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData location = Icons.location_on_rounded;
  static const IconData mood = Icons.emoji_emotions_rounded;
  static const IconData public = Icons.public_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData notifications = Icons.notifications_none_rounded;

  // Text Styles
  static const TextStyle headerTitle = TextStyle(
    color: Colors.black87,
    fontWeight: FontWeight.bold,
    fontSize: 17,
  );

  static const TextStyle postInput = TextStyle(
    fontSize: 18,
    color: Colors.black,
    height: 1.4,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: grey,
  );

  /// Widget Icona Tag: Usa l'immagine caricata dall'utente (e695626822617e7d.PNG)
  static Widget petTagIcon({double size = 32}) {
    return Image.asset(
      'assets/images/e695626822617e7d.PNG',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.alternate_email_rounded,
        color: primary,
        size: size,
      ),
    );
  }

  // Common Widgets
  static Widget toolButton({
    required Widget iconWidget,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: iconWidget,
      ),
    );
  }
}
