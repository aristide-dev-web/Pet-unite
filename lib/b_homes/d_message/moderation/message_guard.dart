class MessageGuard {
  static bool isBlocked(String text) {
    final cleaned = text.trim().toLowerCase();

    // Blocca link non consentiti
    if (_containsBlockedLink(cleaned)) return true;

    // In futuro: aggiungi qui altri controlli (spam, flood, ecc.)

    return false;
  }

  static bool _containsBlockedLink(String text) {
    final urlPattern = RegExp(r'https?:\/\/[^\s]+', caseSensitive: false);
    final matches = urlPattern.allMatches(text);

    for (final match in matches) {
      final url = match.group(0)!;

      final isImage = url.endsWith('.jpg') ||
          url.endsWith('.jpeg') ||
          url.endsWith('.png') ||
          url.endsWith('.gif');

      final isAllowedMap = url.contains('google.com/maps') ||
          url.contains('openstreetmap.org') ||
          url.contains('apple.com/maps') ||
          url.contains('bing.com/maps');

      if (!isImage && !isAllowedMap) return true;
    }

    return false;
  }
}