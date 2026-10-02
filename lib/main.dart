import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notif;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:app_links/app_links.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/vet/aggiungi_esame.dart';
import 'firebase_options.dart';
import 'package:petping/token.dart';
import 'package:petping/a_main/auth_gate.dart';
import 'package:petping/a_main/tab/main_screen.dart';
import 'package:petping/a_registrazione/a/terms_conditions.dart';
import 'package:petping/a_registrazione/a/privacy_policy.dart';
import 'package:petping/a_main/memory/main_login.dart';
import 'package:petping/d_tab_sds/d_smarriti/addpet/pet_mark.dart';
import 'package:petping/settings/privacy_settings.dart';
import 'package:petping/settings/logout_screen.dart';
import 'package:petping/settings/delete_account_screen.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';
import 'package:petping/notific.dart';
import 'package:petping/b_homes/d_message/unread_counter.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/vet/scegli_animale_per_esame.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/vet/a/esame_model.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/calendario/notifiche_calendario.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/calendario/evento.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/social/notific/social_notification_model.dart';
import 'package:petping/social/page/social_page_model.dart';
import 'package:petping/social/post/social_post_detail_screen.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/models/booking_model.dart';
import 'package:petping/petsitting/models/review_model.dart';
import 'package:petping/models/user_profile_model.dart';
import 'package:petping/d_tab_sds/models/sds_models.dart';
import 'package:petping/d_tab_sds/services/sds_cache_service.dart';
import 'package:petping/social/story/social_story_model.dart';
import 'package:petping/petsitting/services/sitter_cache_service.dart';
import 'package:petping/petsitting/services/booking_service.dart';
import 'package:petping/b_homes/d_message/chat_list_screen.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/calendario/calendario.dart';
import 'package:petping/b_homes/d_message/chat_screen.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:petping/b_homes/b_user/social_profilo_utente_screen.dart';
import 'package:petping/a_registrazione/a_alenguage/translations_loader.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inizializzazioni CRITICHE (Bloccanti)
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await EasyLocalization.ensureInitialized();
    await Hive.initFlutter();

    // REGISTRAZIONE ADAPTER
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MessageAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ChatPreviewAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(EsameAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(AnimaleAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SocialPostAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(SocialNotificationAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(SocialPageAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(SitterProfileAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(BookingStatusAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(PetBookingAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(UserProfileAdapter());
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(LostAnimalAdapter());
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(CustodiaAnimalAdapter());
    if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(AdozioneAnimalAdapter());
    if (!Hive.isAdapterRegistered(14)) Hive.registerAdapter(SocialStoryAdapter());
    if (!Hive.isAdapterRegistered(15)) Hive.registerAdapter(PetReviewAdapter());

    // APERTURA BOX CRITICI (Spostati qui per evitare NoSuchMethodError all'apertura schermate)
    await _openBoxSafe('device');
    await _openBoxSafe<ChatPreview>('chatPreviews'); // ✅ Aperto all'avvio per notifiche
    await _openBoxSafe<Animale>(animaliBoxName);
    await _openBoxSafe<SocialPost>(SDSCacheService.postsBoxName);
    await _openBoxSafe<SocialStory>(SDSCacheService.storiesBoxName);
    await _openBoxSafe<PetReview>('reviews_box');
    await _openBoxSafe<SitterProfile>('sitters_box');
    await _openBoxSafe<PetBooking>('bookings_box');
    await _openBoxSafe<UserProfile>('user_profile_box');
    await _openBoxSafe<SocialNotification>('social_notifications_box'); // ✅ Aperto all'avvio

    // Inizializzazione sincronizzazione atomica
    await SDSCacheService.sincronizzaTutto();

  } catch (e) {
    debugPrint("🚨 Errore critico avvio: $e");
  }

  // 2. Inizializzazioni (Attendiamo i servizi necessari per le notifiche)
  await _initServicesBackground();

  // Recupero dati sharing
  final initialSharedFiles = await ReceiveSharingIntent.instance.getInitialMedia();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      assetLoader: const MultiFileAssetLoader(),
      child: PetPingApp(initialSharedFiles: initialSharedFiles),
    ),
  );
}

Future<void> _initServicesBackground() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    // Apertura box Hive secondari
    await _openBoxSafe<Message>('messages');
    await _openBoxSafe<Esame>('esami');
    await _openBoxSafe('calendar_events');
    await _openBoxSafe('notifiche_box');
    await _openBoxSafe<SocialPage>('social_pages_box');
    await _openBoxSafe<LostAnimal>(SDSCacheService.lostBoxName);
    await _openBoxSafe<CustodiaAnimal>(SDSCacheService.custodiaBoxName);
    await _openBoxSafe<AdozioneAnimal>(SDSCacheService.adozioneBoxName);

    sincronizzaAnimaliConHive();
    SitterCacheService.sincronizzaSitters();
    BookingService().startBookingSync();

    await initNotificheCalendario();

    tz.initializeTimeZones();
    UnreadCounter().init();
    DeviceTokenService().init();

    await NotificationService().initialize(onOpen: (data) async {
      // 1. ATTESA NAVIGATOR: Ad app chiusa il Navigator impiega tempo a caricarsi
      int tentativi = 0;
      while (navigatorKey.currentState == null && tentativi < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        tentativi++;
      }

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null || navigatorKey.currentState == null) return;

      // 2. SICUREZZA HIVE: Se il box non è aperto, lo apriamo prima di entrare in chat
      if (!Hive.isBoxOpen('chatPreviews')) {
        await Hive.openBox<ChatPreview>('chatPreviews');
      }

      debugPrint("🔔 Notifica aperta! Dati ricevuti: $data");

      // 1. NOTIFICHE SOCIAL (LIKE, COMMENTI, TAG)
      if (data.containsKey('postId')) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SocialPostDetailScreen(
              postId: data['postId'],
              currentUserId: currentUserId,
            ),
          ),
        );
      }
      // 2. NOTIFICHE MESSAGGI / CHAT
      else if (data.containsKey('chatId')) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              currentUserId: currentUserId,
              otherUserId: data['otherUserId'] ?? data['senderId'] ?? '',
              otherUsername: data['otherUsername'] ?? 'Utente',
              messageService: MessageService(),
            ),
          ),
        );
      }
      // 3. NOTIFICHE FOLLOW / PROFILO PUBBLICO (Indirizzato al Social)
      else if (data['type'] == 'follow' || data.containsKey('followerId')) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SocialProfiloUtenteScreen(
              userId: data['followerId'] ?? data['senderId'] ?? '',
            ),
          ),
        );
      }
      // 4. NOTIFICHE CALENDARIO PET
      else if (data['type'] == 'calendar') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => CalendarioPage(
              animaleId: data['animalId'] ?? '',
              nomeAnimale: '',
            ),
          ),
        );
      }
      // 5. NOTIFICHE PETSITTING (PRENOTAZIONI)
      else if (data['category'] == 'petsitting' || data['type'] == 'booking_update') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => ChatListScreen(currentUserId: currentUserId)),
        );
      }
    });

    await richiediPermessiNotifica();

    // Stripe
    try {
      Stripe.publishableKey = "pk_live_51TDiBBK3hPtldFmLHeYZVD5EktHhmy6N6PNM8qxPOPlCu3QqhuUAMxXjwt80sdyLI2CFyP42GC4FpC98i4OfHnsc003z3pcVLi";
      Stripe.merchantIdentifier = "merchant.com.petping.app";
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint("🚨 Errore Stripe: $e");
    }

    debugPrint("✅ Background Services Ready.");

  } catch (e) {
    debugPrint("🚨 Errore background init: $e");
  }
}

Future<void> _openBoxSafe<T>(String boxName) async {
  try {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<T>(boxName);
    }
  } catch (e) {
    debugPrint("⚠️ Box '$boxName' resettata.");
    await Hive.deleteBoxFromDisk(boxName);
    await Hive.openBox<T>(boxName);
  }
}

class PetPingApp extends StatefulWidget {
  final List<SharedMediaFile>? initialSharedFiles;
  const PetPingApp({super.key, this.initialSharedFiles});

  @override
  State<PetPingApp> createState() => _PetPingAppState();
}

class _PetPingAppState extends State<PetPingApp> {
  late StreamSubscription _intentDataStreamSubscription;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        final paths = value.map((file) => file.path).toList();
        if (FirebaseAuth.instance.currentUser != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => ScegliAnimalePerEsame(filePaths: paths, isFromShare: true)),
          );
        }
      }
    });
  }

  // // --- LOGICA DEEP LINK (QR CODE & STRIPE) ---
  void _initDeepLinks() {
    _appLinks = AppLinks();

    // 1. Gestione link all'avvio dell'app (se aperta da link)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri);
    });

    // 2. Gestione link mentre l'app è in esecuzione
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    debugPrint("🔗 Link ricevuto: $uri");

    // LOGICA DI SMISTAMENTO (IL "CENTRALINO")
    // Se il link contiene 'profilo', estraiamo l'ID utente (uid) e apriamo il profilo Social
    if (uri.toString().contains('profilo')) {
      final uid = uri.queryParameters['uid'];
      if (uid != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => SocialProfiloUtenteScreen(userId: uid)),
        );
      }
    }
    // Qui puoi aggiungere altre logiche se necessario, es. per Stripe
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      title: 'PetPing',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: user != null ? const MainScreen() : const AuthGate(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/terms': (context) => const TermsConditionsScreen(),
        '/privacy': (context) => const PrivacyPolicyScreen(),
        '/login': (context) => const LoginScreen(),
        '/mappa': (context) => const PetMark(),
        '/settings/privacy': (context) => const PrivacySettings(),
        '/settings/logout': (context) => const LogoutScreen(),
        '/settings/delete': (context) => const DeleteAccountScreen(),
      },
    );
  }
}
