import 'package:geolocator/geolocator.dart';
import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371; // Raggio della Terra in km
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _degToRad(double deg) => deg * (pi / 180);

class LocationService {
  /// Ottiene la posizione attuale dell'utente
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servizi di localizzazione disabilitati');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permessi di localizzazione negati');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permessi di localizzazione negati permanentemente');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Calcola la distanza in km tra due coordinate
  static double calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Filtra una lista di oggetti con lat/lon in base alla distanza
  static List<T> filterByDistance<T>(
      List<T> items,
      double userLat,
      double userLon,
      double maxDistanceKm,
      double Function(T) getLat,
      double Function(T) getLon,
      ) {
    return items.where((item) {
      final distance = calculateDistanceKm(
        userLat,
        userLon,
        getLat(item),
        getLon(item),
      );
      return distance <= maxDistanceKm;
    }).toList();
  }

  /// Ordina una lista di oggetti per distanza crescente
  static List<T> sortByDistance<T>(
      List<T> items,
      double userLat,
      double userLon,
      double Function(T) getLat,
      double Function(T) getLon,
      ) {
    items.sort((a, b) {
      final distA = calculateDistanceKm(userLat, userLon, getLat(a), getLon(a));
      final distB = calculateDistanceKm(userLat, userLon, getLat(b), getLon(b));
      return distA.compareTo(distB);
    });
    return items;
  }
}