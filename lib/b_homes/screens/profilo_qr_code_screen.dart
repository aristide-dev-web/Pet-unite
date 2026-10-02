import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final GlobalKey _qrKey = GlobalKey(); 

  Future<void> _openExternalCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      await picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('qr_camera_error'.tr(args: [e.toString()]))),
        );
      }
    }
  }

  Future<void> _downloadQRCode() async {
    try {
      // Controllo permessi per salvare in galleria
      bool hasPermission = await Gal.hasAccess();
      if (!hasPermission) {
        hasPermission = await Gal.requestAccess();
      }

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('qr_save_permission_denied'.tr())),
          );
        }
        return;
      }

      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); 
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // ✅ SALVATAGGIO MODERNO CON GAL
      await Gal.putImageBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('qr_save_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Errore salvataggio QR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('qr_save_error'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color printBlack = Colors.black;
    const Color printWhite = Colors.white;
    final Color primaryAzure = Colors.lightBlue[400]!;
    const Color scannerOrange = Colors.orangeAccent;
    const Color downloadGreen = Color(0xFF10B981);

    if (user == null) {
      return Scaffold(body: Center(child: Text('qr_user_not_authenticated'.tr())));
    }

    final String qrData = 'https://petping-39e1a.web.app/profilo?uid=${user.uid}';

    return Scaffold(
      backgroundColor: printWhite,
      appBar: AppBar(
        title: Text('qr_title'.tr(), style: const TextStyle(color: printBlack, fontWeight: FontWeight.bold)),
        backgroundColor: printWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: printBlack),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: printWhite,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: primaryAzure.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          gapless: true,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: printBlack),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: printBlack),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'qr_petping_id'.tr(args: [user.uid.substring(0, 8).toUpperCase()]),
                          style: TextStyle(color: primaryAzure, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                Text('qr_subtitle'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: printBlack)),
                const SizedBox(height: 10),
                Text(
                  'qr_description'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4, fontWeight: FontWeight.w500),
                ),
                
                const SizedBox(height: 45),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(
                      icon: Icons.share_rounded, 
                      label: 'qr_btn_share'.tr(), 
                      color: primaryAzure,
                      onTap: () => Share.share('qr_share_message'.tr(args: [qrData]))
                    ),
                    _actionButton(
                      icon: Icons.download_for_offline_rounded, 
                      label: 'qr_btn_save'.tr(), 
                      color: downloadGreen,
                      onTap: _downloadQRCode,
                    ),
                    _actionButton(
                      icon: Icons.camera_alt_rounded, 
                      label: 'qr_btn_scanner'.tr(),
                      color: scannerOrange,
                      onTap: () => _openExternalCamera(context),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}
