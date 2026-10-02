import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoService {
  /// Ottiene la posizione attuale dell'utente in modo sicuro
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  /// Calcola la distanza in chilometri tra due punti
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }

  /// Algoritmo di ordinamento automatico per vicinanza
  /// Prende la lista di documenti e la posizione utente, restituisce la lista ordinata
  static List<QueryDocumentSnapshot> sortByProximity(List<QueryDocumentSnapshot> docs, Position userPos) {
    List<Map<String, dynamic>> distanceMapped = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      double distance = 999999; // Valore altissimo se mancano coordinate

      double? petLat = (data['lat'] ?? data['latitude'])?.toDouble();
      double? petLng = (data['lng'] ?? data['longitude'])?.toDouble();

      if (petLat != null && petLng != null) {
        distance = calculateDistance(userPos.latitude, userPos.longitude, petLat, petLng);
      } else if (data['posizione'] is GeoPoint) {
        final gp = data['posizione'] as GeoPoint;
        distance = calculateDistance(userPos.latitude, userPos.longitude, gp.latitude, gp.longitude);
      }

      return {'doc': doc, 'distance': distance};
    }).toList();

    // Ordina dal più vicino al più lontano
    distanceMapped.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return distanceMapped.map((e) => e['doc'] as QueryDocumentSnapshot).toList();
  }
}
