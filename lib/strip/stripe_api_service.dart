import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

class StripeApiService {
  StripeApiService._();
  static final StripeApiService instance = StripeApiService._();

  Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String sitterId,
    String? bookingId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final String? token = await user?.getIdToken();
      
      final response = await http.post(
        Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/createStripePaymentV2'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'data': {
            'amount': amount,
            'sitterId': sitterId,
            'bookingId': bookingId,
          }
        }),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        dev.log("❌ STRIPE_API_ERROR: Status ${response.statusCode} - Body: $errorBody");
        return null;
      }

      final decoded = jsonDecode(response.body);
      return decoded['result'];
    } catch (e) {
      dev.log("❌ STRIPE_API_EXCEPTION: $e");
      return null;
    }
  }

  /// Crea una sessione di Checkout per l'abbonamento SOS
  Future<String?> createSosSubscriptionSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final String? token = await user?.getIdToken();
      
      final response = await http.post(
        Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/createStripeSubscriptionSOS'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'data': {}
        }),
      );

      if (response.statusCode != 200) {
        dev.log("❌ SOS_SUBSCRIPTION_API_ERROR: ${response.body}");
        return null;
      }

      final decoded = jsonDecode(response.body);
      return decoded['result']?['url'];
    } catch (e) {
      dev.log("❌ SOS_SUBSCRIPTION_API_EXCEPTION: $e");
      return null;
    }
  }

  /// Crea una sessione per il Portale Clienti Stripe (gestione/cancellazione)
  Future<String?> createStripePortalSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final String? token = await user?.getIdToken();
      
      final response = await http.post(
        Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/createStripePortalSession'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'data': {}}),
      );

      if (response.statusCode != 200) {
        dev.log("❌ PORTAL_SESSION_API_ERROR: ${response.body}");
        return null;
      }

      final decoded = jsonDecode(response.body);
      return decoded['result']?['url'];
    } catch (e) {
      dev.log("❌ PORTAL_SESSION_API_EXCEPTION: $e");
      return null;
    }
  }

  Future<void> confirmBookingInFirestore(String bookingId, String piId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'paymentStatus': 'authorized',
      'stripePaymentIntentId': piId,
      'status': 'authorized_waiting_service',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> capturePayment(String bookingId, String code, {double? amountToCapture}) async {
    final String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.post(
      Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/captureStripePayment'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'data': {
          'bookingId': bookingId, 
          'code': code,
          'amountToCapture': amountToCapture // Passiamo l'importo parziale se presente
        }
      }),
    );
    return jsonDecode(response.body);
  }

  Future<String?> getSetupIntent() async {
    try {
      final String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('https://us-central1-petping-39e1a.cloudfunctions.net/createStripeSetupIntent'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'data': {}}),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        dev.log("❌ SETUP_INTENT_ERROR: Status ${response.statusCode} - Body: $errorBody");
        return null;
      }

      final body = jsonDecode(response.body);
      return body['result']?['client_secret'];
    } catch (e) {
      dev.log("❌ SETUP_INTENT_EXCEPTION: $e");
      return null;
    }
  }
}
