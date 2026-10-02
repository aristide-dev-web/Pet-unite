import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:petping/petsitting/models/booking_model.dart';
import 'package:petping/strip/stripe_service.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/utils/notific_principal.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _boxName = 'bookings_box';

  void startBookingSync() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _db.collection('bookings')
       .where(Filter.or(
         Filter('ownerId', isEqualTo: user.uid),
         Filter('sitterId', isEqualTo: user.uid)
       ))
       .snapshots()
       .listen((snapshot) async {
      final box = await Hive.openBox<PetBooking>(_boxName);

      for (var change in snapshot.docChanges) {
        final doc = change.doc;
        
        if (change.type == DocumentChangeType.removed) {
          await box.delete(doc.id);
        } else {
          final booking = PetBooking.fromFirestore(doc);
          await box.put(doc.id, booking);
        }
      }
    });
  }

  Future<void> createBooking(PetBooking booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toMap());
    final box = await Hive.openBox<PetBooking>(_boxName);
    await box.put(booking.id, booking);
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status.toString().split('.').last,
    });
  }

  // --- LOGICA DI PAGAMENTO E CONFERMA SCHEDA ---

  Future<Map<String, dynamic>> payAndConfirm({
    required PetBooking booking,
  }) async {
    final result = await StripeService.instance.pagaInSospensione(
      amount: (booking.totalPrice * 100).round(),
      sitterId: booking.sitterId,
      bookingId: booking.id,
    );

    if (result['success'] == true) {
      final updates = {
        'paymentStatus': 'authorized',
        'status': 'accepted', 
        'stripePaymentIntentId': result['id'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('bookings').doc(booking.id).update(updates);

      await _cancelOverlappingRequests(booking);

      final box = await Hive.openBox<PetBooking>(_boxName);
      final updatedBooking = PetBooking(
        id: booking.id,
        ownerId: booking.ownerId,
        sitterId: booking.sitterId,
        petId: booking.petId,
        serviceType: booking.serviceType,
        status: BookingStatus.accepted,
        startDate: booking.startDate,
        endDate: booking.endDate,
        checkInTime: booking.checkInTime,
        checkOutTime: booking.checkOutTime,
        totalPrice: booking.totalPrice,
        note: booking.note,
        petCount: booking.petCount,
        paymentStatus: 'authorized',
        deletedByOwner: booking.deletedByOwner,
        deletedBySitter: booking.deletedBySitter,
      );
      await box.put(booking.id, updatedBooking);

      await sendSystemMessage(
        booking.sitterId, 
        "ha confermato la prenotazione e bloccato i fondi! 🐾",
        sysText: "✅ PRENOTAZIONE CONFERMATA E FONDI BLOCCATI!"
      );

      return {'success': true};
    }
    return {'success': false, 'message': result['message']};
  }

  Future<void> _cancelOverlappingRequests(PetBooking confirmed) async {
    try {
      final sitterId = confirmed.sitterId;
      final start = DateTime(confirmed.startDate.year, confirmed.startDate.month, confirmed.startDate.day);
      final end = DateTime(confirmed.endDate.year, confirmed.endDate.month, confirmed.endDate.day);

      final snapshot = await _db.collection('bookings')
          .where('sitterId', isEqualTo: sitterId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in snapshot.docs) {
        if (doc.id == confirmed.id) continue;
        
        final other = PetBooking.fromFirestore(doc);
        final oStart = DateTime(other.startDate.year, other.startDate.month, other.startDate.day);
        final oEnd = DateTime(other.endDate.year, other.endDate.month, other.endDate.day);

        bool overlaps = (oStart.isBefore(end) || oStart.isAtSameMomentAs(end)) &&
                        (start.isBefore(oEnd) || start.isAtSameMomentAs(oEnd));

        if (overlaps) {
          await updateBookingStatus(other.id, BookingStatus.cancelled);
          
          final dateStr = oStart == oEnd 
              ? DateFormat('dd/MM').format(oStart)
              : "${DateFormat('dd/MM').format(oStart)} - ${DateFormat('dd/MM').format(oEnd)}";

          await sendSystemMessage(
            other.ownerId, 
            "La tua richiesta per $dateStr è stata annullata automaticamente perché il Sitter ha appena confermato un altro impegno in questo periodo. 🐾",
            sysText: "🚫 RICHIESTA ANNULLATA AUTOMATICAMENTE (SLOT GIÀ OCCUPATO)"
          );
        }
      }
    } catch (e) {
      debugPrint("Errore durante l'annullamento delle sovrapposizioni: $e");
    }
  }

  Future<Map<String, dynamic>> confirmSitterArrival(String bookingId, String sitterId) async {
    final result = await StripeService.instance.releasePayment(
      bookingId: bookingId,
      code: "OWNER_CONFIRMED",
    );

    if (result['success'] == true) {
      final double sitterNet = (result['sitterNet'] ?? 0.0).toDouble();
      
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'completed',
        'paymentStatus': 'captured',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await sendSystemMessage(
        sitterId, 
        "ha confermato il tuo arrivo! Pagamento sbloccato. Accredito netto: $sitterNet € 🐾💰", 
        sysText: "✅ ARRIVO CONFERMATO. ACCREDITO NETTO: $sitterNet €"
      );
      return {'success': true};
    }
    return {'success': false, 'message': result['message']};
  }

  /// Gestisce l'annullamento con rimborso parziale (richiesto dal Cliente)
  Future<Map<String, dynamic>> cancelWithPartialRefund({
    required String bookingId,
    required double penaltyAmount, 
    required String reason,
  }) async {
    try {
      // Nota: Qui non chiamiamo più releasePayment direttamente se vogliamo che l'index gestisca tutto.
      // Ma per sicurezza, se vogliamo un rimborso totale pilotato dal codice,
      // aggiorniamo solo Firestore e lasciamo che la Cloud Function (index.js) faccia il resto.

      await _db.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'penaltyAmount': penaltyAmount,
        'cancelReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// ✅ NUOVO: Gestisce l'annullamento totale richiesto dal SITTER
  Future<Map<String, dynamic>> cancelBySitter({
    required String bookingId,
    required String reason,
  }) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelledBySitter': true, // Questo flag attiva il rimborso 100% in index.js
        'cancelReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> sendSystemMessage(String toId, String pushMsg, {String? sysText}) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final chatId = (currentUserId.compareTo(toId) < 0) ? '${currentUserId}_$toId' : '${toId}_$currentUserId';
      
      await SocialNotificationService().sendNotification(toUserId: toId, type: 'booking_update', text: pushMsg);
      
      final msg = Message(
        id: "sys_${DateTime.now().millisecondsSinceEpoch}", 
        senderId: currentUserId, 
        receiverId: toId, 
        text: sysText ?? "📢 ${pushMsg.toUpperCase()}", 
        timestamp: DateTime.now(), 
        type: 'system'
      );
      await MessageService().sendMessage(chatId, msg, isBooking: true);
    } catch (e) {
      print("Errore invio messaggio sistema: $e");
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _db.collection('bookings').doc(bookingId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final bool isOwner = data['ownerId'] == uid;
    
    final bool alreadyDeletedByOther = isOwner 
        ? (data['deletedBySitter'] ?? false) 
        : (data['deletedByOwner'] ?? false);

    if (alreadyDeletedByOther) {
      await docRef.delete();
      final box = await Hive.openBox<PetBooking>(_boxName);
      await box.delete(bookingId);
    } else {
      await docRef.update({
        isOwner ? 'deletedByOwner' : 'deletedBySitter': true,
      });
    }
  }
}
