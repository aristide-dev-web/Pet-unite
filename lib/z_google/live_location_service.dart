import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';

class LiveLocationService {
  static StreamSubscription<Position>? _positionStream;
  static String? _currentLiveId;

  static Future<String?> startSharing({required String chatId, required String userId}) async {
    // 1. Fermiamo eventuali stream attivi prima di iniziarne uno nuovo per evitare leak
    stopSharing();

    debugPrint("DEBUG_GPS: [LIVE] Richiesta avvio condivisione movimenti...");

    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await Permission.locationAlways.request();
    } else {
      debugPrint("DEBUG_GPS: [ERROR] Permessi GPS negati.");
      return null;
    }

    final liveId = "LIVE_${DateTime.now().millisecondsSinceEpoch}";
    _currentLiveId = liveId;

    await FirebaseFirestore.instance.collection('live_locations').doc(liveId).set({
      'chatId': chatId,
      'userId': userId,
      'active': true,
      'lastUpdate': FieldValue.serverTimestamp(),
    });

    // 2. CONFIGURAZIONE SPECIFICA PER PIATTAFORMA
    final LocationSettings locationSettings;
    
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0, // Invia sempre, anche se fermi (così non va in timeout)
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 5), // Ogni 5 secondi per risparmiare batteria
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationText: 'live_location_notification_text'.tr(),
          notificationTitle: 'live_location_notification_title'.tr(),
          enableWakeLock: true,
        )
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true, 
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      );
    }

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      debugPrint("DEBUG_GPS: [LIVE] Invio coordinate a Firestore: ${position.latitude}, ${position.longitude}");
      FirebaseFirestore.instance.collection('live_locations').doc(liveId).update({
        'lat': position.latitude,
        'lng': position.longitude,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    });

    return liveId;
  }

  static void stopSharing() {
    debugPrint("DEBUG_GPS: [LIVE] Interruzione manuale richiesta.");
    if (_currentLiveId != null) {
      FirebaseFirestore.instance.collection('live_locations').doc(_currentLiveId).update({'active': false});
    }
    _positionStream?.cancel();
    _positionStream = null;
    _currentLiveId = null;
  }
}

class LiveTrackingScreen extends StatefulWidget {
  final String liveId;
  final String otherUsername;

  const LiveTrackingScreen({super.key, required this.liveId, required this.otherUsername});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _connWatcher; 
  DateTime? _lastUpdateReceived;
  bool _firstFix = true;
  bool _isDisconnected = false;
  bool _autoCenter = true; 

  @override
  void initState() {
    super.initState();
    _connWatcher = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_lastUpdateReceived != null) {
        final diff = DateTime.now().difference(_lastUpdateReceived!).inSeconds;
        // Se non riceviamo nulla per 40 secondi (più tollerante con l'intervallo a 5s)
        if (diff > 40) {
          if (!_isDisconnected) {
            setState(() => _isDisconnected = true);
            debugPrint("🚨 DEBUG_GPS: [DISCONNESSIONE] @${widget.otherUsername} non invia dati da $diff secondi!");
          }
        } else {
          if (_isDisconnected) {
            setState(() => _isDisconnected = false);
            debugPrint("✅ DEBUG_GPS: [RIPRISTINO] Connessione tornata per @${widget.otherUsername}");
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _connWatcher?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF64B5B4);

    return Scaffold(
      appBar: AppBar(
        title: Text('live_location_tracking_title'.tr(args: [widget.otherUsername]), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (!_autoCenter)
            IconButton(
              onPressed: () => setState(() => _autoCenter = true),
              icon: const Icon(Icons.my_location, color: primaryColor),
            )
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('live_locations').doc(widget.liveId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator());
              
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final bool active = data['active'] ?? false;
              final double? lat = data['lat'];
              final double? lng = data['lng'];
              final Timestamp? serverTime = data['lastUpdate'] as Timestamp?;

              if (serverTime != null) {
                _lastUpdateReceived = serverTime.toDate();
              }

              if (!active) return Center(child: Text('live_location_sharing_stopped'.tr()));
              if (lat == null || lng == null) return Center(child: Text('live_location_waiting_gps'.tr()));

              final targetPos = LatLng(lat, lng);

              if (_autoCenter) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_firstFix) {
                    _mapController.move(targetPos, 16.0);
                    _firstFix = false;
                  } else {
                    _mapController.move(targetPos, _mapController.camera.zoom);
                  }
                });
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: targetPos,
                  initialZoom: 16.0,
                  onPositionChanged: (pos, hasGesture) {
                    if (hasGesture && _autoCenter) {
                      setState(() => _autoCenter = false);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.petping.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: targetPos,
                        width: 70, height: 70,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))]
                              ),
                              child: Text(widget.otherUsername, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryColor)),
                            ),
                            const Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          
          if (_isDisconnected)
            Positioned(
              top: 20, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.white),
                    const SizedBox(width: 15),
                    Expanded(child: Text("${'live_location_signal_lost_title'.tr()}: ${'live_location_signal_lost_desc'.tr()}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
