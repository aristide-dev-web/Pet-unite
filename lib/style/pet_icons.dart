import 'package:flutter/material.dart';

class PetIcons {
  // Brand Colors
  static const Color primary = Color(0xFF64B5B4);
  static const Color background = Color(0xFFF2F5F8);
  static const Color grey = Color(0xFF65676B);

  // Icons
  static const IconData tagPet = Icons.pets_rounded;
  static const IconData photo = Icons.photo_library_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData location = Icons.location_on_rounded;
  static const IconData mood = Icons.emoji_emotions_rounded;
  static const IconData public = Icons.public_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData options = Icons.more_horiz_rounded;
  
  // Custom Icon Wrapper for Toolbar
  static Widget toolButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 26),
      tooltip: tooltip,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      splashRadius: 24,
    );
  }
}
