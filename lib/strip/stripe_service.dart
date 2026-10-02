import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stripe_api_service.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<Map<String, dynamic>> pagaInSospensione({
    required int amount,
    required String sitterId,
    String? bookingId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email;

      final data = await StripeApiService.instance.createPaymentIntent(
        amount: amount,
        sitterId: sitterId,
        bookingId: bookingId,
      );

      if (data == null || data['client_secret'] == null) {
        debugPrint("❌ ERRORE: Il backend non ha restituito il client_secret");
        throw "Errore API";
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['client_secret'],
          merchantDisplayName: 'PetPing',
          customerId: data['customer'], 
          customerEphemeralKeySecret: data['ephemeralKey'],
          billingDetails: BillingDetails(email: userEmail),
          // ✅ Configurazione per nascondere CAP/Regione
          billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
            address: AddressCollectionMode.never,
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'IT',
            testEnv: true,
            label: 'PetPing',
          ),
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'IT'),
          style: ThemeMode.light,
          // ✅ Importante per PayPal e altri metodi con redirect
          returnURL: 'petping://stripe-redirect',
          allowsDelayedPaymentMethods: true, // ✅ Necessario per alcuni metodi PayPal
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      
      if (bookingId != null) {
        await StripeApiService.instance.confirmBookingInFirestore(bookingId, data['id']);
      }

      return {
        'success': true,
        'id': data['id'],
      };
    } catch (e) {
      debugPrint("❌ ERRORE STRIPE: $e");
      if (e is StripeException) {
        return {'success': false, 'id': null, 'message': e.error.localizedMessage};
      }
      return {'success': false, 'id': null, 'message': e.toString()};
    }
  }

  // --- Cattura i fondi (Totale o Parziale) ---
  Future<Map<String, dynamic>> releasePayment({
    required String bookingId, 
    required String code,
    double? amountToCapture,
  }) async {
    try {
      debugPrint("DEBUG_STRIPE: Richiesta cattura per $bookingId con importo: $amountToCapture");
      final response = await StripeApiService.instance.capturePayment(
        bookingId, 
        code, 
        amountToCapture: amountToCapture
      );
      return {
        'success': response['result']?['success'] == true, 
        ...response['result'] ?? {}
      };
    } catch (e) { 
      debugPrint("DEBUG_STRIPE: Eccezione in releasePayment: $e");
      return {'success': false, 'message': e.toString()}; 
    }
  }

  Future<String?> getSetupIntentClientSecret() async { return await StripeApiService.instance.getSetupIntent(); }
}
