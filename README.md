# 🐾 Pet Unite - L'Ecosistema Definitivo per la Protezione Animale

**Pet Unite** è una piattaforma rivoluzionaria nata per trasformare radicalmente il modo in cui proteggiamo e ci prendiamo cura dei nostri animali. Sviluppata interamente da me come **sviluppatore solista in soli 3-4 mesi**, l'app rappresenta il culmine di un percorso di apprendimento intenso, dove ho affrontato e risolto "problemi invisibili" partendo da zero, creando un'architettura **cross-platform (Flutter & Dart)** d'eccellenza, ottimizzata perfettamente per iOS e Android.

---

## 🚀 La Visione: Sicurezza Passiva & Futuro Digitale

L'obiettivo di Pet Unite è superare i limiti dei sistemi di ritrovamento attuali, proiettandosi verso una tecnologia invisibile e automatica:

* **Segnalazione & Mappa Smarrimenti in Tempo Reale**: Una mappa interattiva che permette di segnalare e ritrovare rapidamente gli animali smarriti con notifiche geolocalizzate istantanee.
* **Calendario Intelligente & Notifiche "App Killata"**:
  * Un sistema di promemoria avanzato progettato per **suonare anche se l'applicazione è stata chiusa forzatamente (killata)** dal sistema.
  * **Sistema Ibrido di Notifiche**: Firebase invia il trigger iniziale per "svegliare" il sistema, dopodiché le notifiche vengono gestite internamente dal modulo locale per garantire precisione millimetrica e affidabilità totale.
* **Geolocalizzazione & Mappe Native**: L'app non utilizza API a pagamento di terze parti, ma si integra direttamente con i **Maps nativi dei telefoni (Apple e Google)**. Questo garantisce performance massime e **zero costi di licenza**.
* **Messaggistica Real-time**: Una chat proprietaria avanzata e funzionante anche ad app chiusa, fondamentale per gestire le emergenze e i ritrovamenti istantanei.
* **AI Integrata**: Un'intelligenza artificiale dedicata che assiste l'utente nella gestione quotidiana del pet e arricchisce l'esperienza d'uso.

---

## 💻 Architettura & Snippet di Codice (Flutter & Dart)

Ecco una selezione dell'architettura e del codice sorgente di Pet Unite:

### 🔔 1. Gesture Notifiche in Background ("App-Killed" Handler)
```dart
// Handler Top-Level eseguito dal VM Entry-Point anche ad applicazione chiusa/killata
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final localNotif = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  
  await localNotif.initialize(
    InitializationSettings(android: androidInit, iOS: iosInit)
  );

  final data = message.data;
  final String title = data['title'] ?? message.notification?.title ?? 'PetUnite';
  final String body = data['text'] ?? message.notification?.body ?? 'Nuova attività';
  
  // Canale dinamico per Petsitting vs Smarrimenti/Notifiche Generali
  final bool isPetsitting = data['category'] == 'petsitting';

  final androidDetails = AndroidNotificationDetails(
    isPetsitting ? 'petsitting_channel' : 'high_importance_channel',
    isPetsitting ? 'Notifiche Petsitting' : 'Notifiche Importanti',
    importance: Importance.max,
    priority: Priority.high,
    color: isPetsitting ? const Color(0xFF00AAA0) : const Color(0xFF6366F1),
  );

  await localNotif.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(android: androidDetails),
    payload: jsonEncode(data),
  );
}
```

### 🐶 2. Modulo Pet-Sitting & Stripe Integration
```dart
// Controller di gestione prenotazione Pet-Sitter con Stripe Payment Sheet
class PetSittingBookingController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> processBookingPayment({
    required String bookingId,
    required String sitterId,
    required double amount,
  }) async {
    try {
      // Inizializza la sessione Stripe Payment Sheet in modo sicuro
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: 'YOUR_STRIPE_CLIENT_SECRET',
          merchantDisplayName: 'PetUnite Services',
          style: ThemeMode.dark,
        ),
      );

      // Presenta la schermata di pagamento nativa
      await Stripe.instance.presentPaymentSheet();

      // Aggiorna lo stato della prenotazione su Firestore
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
        'paidAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Errore durante il pagamento: $e');
      return false;
    }
  }
}
```

---

## 🎨 Design Innovativo & Psicologia dell'Interfaccia

Il design di Pet Unite non è solo estetica, ma un vero e proprio **percorso psicologico** studiato per guidare lo stato d'animo dell'utente:

* **Psicologia del Colore**:
  * **SOS Smarrimenti**: In questa sezione critica, la palette cromatica è stata scelta appositamente per trasmettere **tranquillità** (per evitare il panico del proprietario) ma mantenendo un forte senso di **importanza e urgenza** che spinge all'azione corretta e veloce.
* **3 Home Personali**: L'app offre tre interfacce diverse, modellate appositamente per le diverse necessità dell'utente, rendendo l'esperienza fluida, intuitiva e coinvolgente.
* **Design Curato e Moderno**: Forme, icone e colori cambiano dinamicamente in base alla funzione selezionata, rendendo l'app bella da vedere e facilissima da usare.

---

## 🎮 Il "Pet Dex", Mini-Social & Pet Sitting

* **Pet Dex**: Ho trasformato la cura e l'educazione degli animali in un **gioco**. Gli utenti possono imparare e divertirsi "collezionando" informazioni e traguardi sui propri pet, aumentando l'engagement e il divertimento quotidiano.
* **Social Network Integrato**: Una piattaforma social completa con profili, messaggistica, bacheche e chat tra proprietari per condividere esperienze e consigli.
* **Modulo Pet Sitting & Stripe**: Un sistema di gestione Pet Sitter professionale già completo al 100%, integrato con **Stripe** per gestire pagamenti sicuri.

---

## 🔒 Sicurezza, Privacy & Business

* **Identità Protetta**: La privacy è garantita da sistemi che tengono l'identità al sicuro. L'utente decide esplicitamente quando e quali dati personali mostrare, garantendo totale controllo sulla propria privacy.
* **Architettura Scalabile**: Progettata per supportare migliaia di utenti simultanei senza cali di prestazioni.

---

## 🔗 Link Ufficiali (Clicca per accedere)

* 🍎 **App Store (iPhone)**: [Scarica Pet Unite per iOS](https://apps.apple.com/it/app/petunite/id6768807586)  
  *(Versione ufficiale già funzionante e disponibile)*
* 🤖 **Google Play (Android)**: [Scarica Pet Unite per Android](https://play.google.com/store/apps/details?id=com.petping.app)
* 🧪 **Versione Beta / Testing (Solo Android)**: [Accedi al Test Android](https://play.google.com/apps/testing/com.petping.app)  
  *⚠️ Nota: L'accesso è limitato e concesso su richiesta diretta allo sviluppatore (Aristide).*

---

### Nota dello Sviluppatore:
Questo progetto rappresenta una sfida vinta contro la complessità tecnica e burocratica. Ho costruito ogni singola riga di codice, risolto bug "invisibili" e studiato la psicologia dietro ogni funzione per creare un prodotto d'eccellenza pronto per il mercato globale.
