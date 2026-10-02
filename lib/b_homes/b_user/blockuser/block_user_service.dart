import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/b_homes/b_user/blockuser/block_user.dart';

class BlockUserService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection('blocked_users');

  /// Lista locale sincronizzata per controlli rapidi (opzionale, ma utile per UI fluida)
  static List<String> _blockedIds = [];
  static List<String> get blockedIds => _blockedIds;

  /// Inizializza la lista dei blocchi all'avvio dell'app
  static Future<void> init(String currentUserId) async {
    _blockedIds = await getBlockedUserIds(currentUserId);
  }

  /// Blocca un utente
  static Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    final docId = '${blockerId}_$blockedId';
    final data = BlockedUser(
      blockerId: blockerId,
      blockedId: blockedId,
      timestamp: DateTime.now(),
    ).toMap();

    await _collection.doc(docId).set(data);
    if (!_blockedIds.contains(blockedId)) {
      _blockedIds.add(blockedId);
    }
  }

  static Future<List<Map<String, dynamic>>> getBlockedUsers(String blockerId) async {
    final snapshot = await _collection
        .where('blockerId', isEqualTo: blockerId)
        .get();

    List<Map<String, dynamic>> blocked = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final userId = data['blockedId'];
      final userDoc = await _firestore.collection('utenti').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        blocked.add({
          'id': userId,
          'username': userData['username'] ?? 'Utente senza nome',
          'fotoUrl': userData['fotoUrl'] ?? '',
        });
      } else {
        blocked.add({'id': userId, 'username': 'Account eliminato', 'fotoUrl': ''});
      }
    }

    return blocked;
  }

  /// Sblocca un utente
  static Future<void> unblockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    final docId = '${blockerId}_$blockedId';
    await _collection.doc(docId).delete();
    _blockedIds.remove(blockedId);
  }

  /// Controlla se esiste un blocco attivo tra due utenti (Blocker o Blocked)
  static Future<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  }) async {
    // Controllo bidirezionale: io ho bloccato lui O lui ha bloccato me
    final docMeToHim = await _collection.doc('${currentUserId}_$otherUserId').get();
    if (docMeToHim.exists) return true;
    
    final docHimToMe = await _collection.doc('${otherUserId}_$currentUserId').get();
    return docHimToMe.exists;
  }

  /// Restituisce la lista degli ID degli utenti bloccati da un utente specifico
  static Future<List<String>> getBlockedUserIds(String blockerId) async {
    final query = await _collection
        .where('blockerId', isEqualTo: blockerId)
        .get();

    return query.docs
        .map((doc) => doc['blockedId'] as String)
        .toList();
  }

  /// Restituisce la lista degli ID di chi ha bloccato l'utente corrente
  static Future<List<String>> getUsersWhoBlockedMe(String userId) async {
    final query = await _collection
        .where('blockedId', isEqualTo: userId)
        .get();

    return query.docs
        .map((doc) => doc['blockerId'] as String)
        .toList();
  }
}
