import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

class MapLauncherService {
  /// Mostra un Dialog Premium prima di accedere alla posizione
  static Future<void> searchNearby(BuildContext context, String keyword) async {
    final bool? accessGranted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PremiumPermissionDialog(
        title: 'map_permission_title'.tr(),
        message: 'map_permission_msg'.tr(),
        icon: Icons.location_on_rounded,
        accentColor: Colors.lightBlue[400]!,
      ),
    );

    if (accessGranted != true) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar(context, 'snack_gps_required'.tr());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      _showSnackBar(context, 'snack_locating'.tr());

      // Otteniamo la posizione con alta precisione
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final String encodedQuery = Uri.encodeComponent(keyword);
      Uri url;

      if (Platform.isAndroid) {
        // Su Android, lo schema "geo" forza Google Maps a cercare esattamente in quel raggio
        url = Uri.parse("geo:${position.latitude},${position.longitude}?q=$encodedQuery");
      } else {
        // Su iOS o Web, usiamo il formato Apple/Google standard
        url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedQuery");
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback se lo schema geo fallisce
        final googleUrl = Uri.parse("https://www.google.com/maps/search/$encodedQuery/@${position.latitude},${position.longitude},15z");
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Errore Mappe: $e");
      _showSnackBar(context, 'snack_location_error'.tr());
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

class _PremiumPermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;

  const _PremiumPermissionDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('btn_cancel'.tr(), style: const TextStyle(color: Colors.white38)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('btn_allow'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
