import 'package:petping/b_homes/d_message/moderation/message_guard.dart';

void main() {
  testMessageGuard();
}

void testMessageGuard() {
  final testCases = {
    'https://www.google.com/maps/place/Colosseo': false,
    'https://www.openstreetmap.org/#map=5/41.9028/12.4964': false,
    'https://www.apple.com/maps/': false,
    'https://www.bing.com/maps?q=rome': false,
    'https://example.com/image.jpg': false,
    'https://www.youtube.com/watch?v=abc123': true,
    'https://example.com': true,
  };

  for (final entry in testCases.entries) {
    final result = MessageGuard.isBlocked(entry.key);
    final expected = entry.value;
    print('Test: ${entry.key} → ${result == expected ? "✅ OK" : "❌ FAIL"}');
  }
}