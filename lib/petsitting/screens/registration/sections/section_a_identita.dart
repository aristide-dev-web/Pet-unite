import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/utils/image_picker_helper.dart';
import 'package:petping/utils/prefisso.dart';
import 'package:petping/petsitting/services/ocr_service.dart';
import 'package:petping/utils/verification_badges.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:petping/utils/image_optimizer.dart';
import 'foto_preview_widget.dart';
import 'package:petping/zoom.dart';

// --- PARTE 1: SCANNER DOCUMENTO CON CONFERMA ---
class SectionA1Scanner extends StatefulWidget {
  final File? docFronte;
  final Function(File) onDocFrontePicked;
  final Function(bool) onVerificationSuccess;
  final TextEditingController dataNascitaController;
  final TextEditingController nomeController; 
  final TextEditingController cognomeController; 

  const SectionA1Scanner({
    super.key,
    required this.docFronte,
    required this.onDocFrontePicked,
    required this.onVerificationSuccess,
    required this.dataNascitaController,
    required this.nomeController,
    required this.cognomeController,
  });

  @override
  State<SectionA1Scanner> createState() => _SectionA1ScannerState();
}

class _SectionA1ScannerState extends State<SectionA1Scanner> {
  bool _isVerifying = false;
  String? _verificationError;
  final OCRService _ocrService = OCRService();
  Map<String, String>? _extractedData;

  final Color indigoColor = const Color(0xFF6366F1);
  final Color bgLight = const Color(0xFFF8FAFC);

  Future<void> _startLiveVerification() async {
    FocusScope.of(context).unfocus();
    var status = await Permission.camera.status;
    if (!status.isGranted) status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _verificationError = "ps_reg_error_camera_permission".tr());
      return;
    }

    try {
      final picked = await ImagePickerHelper.pickImageFromCamera();
      if (picked == null) return;
      if (!mounted) return;
      setState(() { _isVerifying = true; _verificationError = null; _extractedData = null; });
      
      final data = await _ocrService.scanDocument(picked);
      if (!mounted) return;

      if (data != null && data['dataNascita'] != null) {
        if (OCRService.isAdult(data['dataNascita']!)) {
          setState(() { 
            _isVerifying = false; 
            _extractedData = data; 
          });
          widget.onDocFrontePicked(picked);
        } else {
          setState(() { _isVerifying = false; _verificationError = "ps_reg_error_underage".tr(); });
        }
      } else {
        setState(() { _isVerifying = false; _verificationError = "ps_reg_error_ocr_failed".tr(); });
      }
    } catch (e) {
      setState(() { _isVerifying = false; _verificationError = "ps_reg_error_scanner".tr(); });
    }
  }

  void _confirmData() {
    if (_extractedData != null) {
      widget.dataNascitaController.text = _extractedData!['dataNascita'] ?? "";
      widget.nomeController.text = _extractedData!['nome'] ?? "";
      widget.cognomeController.text = _extractedData!['cognome'] ?? "";
      widget.onVerificationSuccess(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: indigoColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(_extractedData != null ? Icons.fact_check_rounded : Icons.badge_rounded, size: 50, color: indigoColor),
            ),
            const SizedBox(height: 20),
            Text(_extractedData != null ? "ps_reg_confirm_data_title".tr() : "ps_reg_verify_identity_title".tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            Text(
              _extractedData != null 
                ? "ps_reg_confirm_data_sub".tr()
                : "ps_reg_verify_identity_sub".tr(), 
              textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 15, height: 1.4)
            ),
            const SizedBox(height: 30),
            if (_verificationError != null) 
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(_verificationError!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            
            if (_extractedData == null) _buildScanBox() else _buildDataPreview(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScanBox() {
    return GestureDetector(
      onTap: _isVerifying ? null : _startLiveVerification,
      child: Container(
        height: 220, width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(28), 
          border: Border.all(color: indigoColor.withOpacity(0.3), width: 3), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 10))]
        ),
        child: _isVerifying 
          ? Center(child: CircularProgressIndicator(color: indigoColor)) 
          : Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Icon(Icons.camera_enhance_rounded, color: indigoColor, size: 45), 
                const SizedBox(height: 12),
                Text("ps_reg_btn_start_scanner".tr(), style: TextStyle(fontWeight: FontWeight.w900, color: indigoColor, letterSpacing: 1.2, fontSize: 13))
              ]
            ),
      ),
    );
  }

  Widget _buildDataPreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 2),
          ),
          child: Column(
            children: [
              _buildDataRow("profile_label_firstname".tr(), _extractedData!['nome']),
              const Divider(height: 20),
              _buildDataRow("profile_label_lastname".tr(), _extractedData!['cognome']),
              const Divider(height: 20),
              _buildDataRow("profile_label_birthdate_full".tr(), _extractedData!['dataNascita']),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _startLiveVerification();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("ps_reg_btn_retry_scan".tr()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _confirmData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text("btn_confirm_action".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        Text(value ?? "???", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
      ],
    );
  }
}

// --- PARTE 2: COMPLETAMENTO DATI ---
class SectionA2Dati extends StatefulWidget {
  final TextEditingController nicknameController;
  final TextEditingController nomeController;
  final TextEditingController cognomeController;
  final TextEditingController dataNascitaController;
  final TextEditingController nazioneController;
  final TextEditingController regioneController;
  final TextEditingController cittaController;
  final TextEditingController indirizzoController;
  final TextEditingController telefonoController;
  final TextEditingController emailController;
  final TextEditingController quartiereController;
  final String telefonoPrefix; 
  final Function(String) onPrefixChanged; 
  final Function(double lat, double lng) onLocationFound;
  final File? fotoChiSeiPro; 
  final String? existingFotoUrl; 
  final Function(File) onFotoProPicked; 
  final VoidCallback onResetScanner;

  final bool emailVerified;
  final bool phoneVerified;
  final bool identityVerified;
  final Function(bool) onEmailVerifiedChanged;
  final Function(bool) onPhoneVerifiedChanged;

  const SectionA2Dati({
    super.key, 
    required this.nicknameController,
    required this.nomeController, required this.cognomeController, required this.dataNascitaController,
    required this.nazioneController, required this.regioneController, required this.cittaController,
    required this.indirizzoController, required this.telefonoController, required this.telefonoPrefix,
    required this.emailController,
    required this.onPrefixChanged, required this.onLocationFound, required this.fotoChiSeiPro,
    this.existingFotoUrl, 
    required this.onFotoProPicked,
    required this.quartiereController,
    required this.onResetScanner,
    required this.emailVerified,
    required this.phoneVerified,
    required this.identityVerified,
    required this.onEmailVerifiedChanged,
    required this.onPhoneVerifiedChanged,
  });

  @override
  State<SectionA2Dati> createState() => _SectionA2DatiState();
}

class _SectionA2DatiState extends State<SectionA2Dati> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _selectedPosition;
  bool _isSearching = false;
  bool _showConfirmButton = false;

  bool _isSendingEmail = false;
  bool _isEmailTimerRunning = false;
  bool _isSendingOtp = false;
  Timer? _emailCheckTimer;

  final Color bgLight = const Color(0xFFF8FAFC);
  final Color indigoColor = const Color(0xFF6366F1);
  final Color textColor = const Color(0xFF1E293B);
  final Color secondaryTextColor = const Color(0xFF64748B);
  final Color accentEmerald = const Color(0xFF10B981);

  List<dynamic> _locationSuggestions = [];
  Timer? _debounce;

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.length > 2) {
        _fetchLocationSuggestions(query);
      } else {
        setState(() => _locationSuggestions = []);
      }
    });
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse("https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=5&lang=${context.locale.languageCode}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _locationSuggestions = data['features']);
      }
    } catch (e) {
      debugPrint("Errore ricerca Photon: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _applySelectedLocation(dynamic feature) {
    final props = feature['properties'];
    final geometry = feature['geometry']['coordinates'];
    final lat = geometry[1];
    final lng = geometry[0];

    setState(() {
      widget.nazioneController.text = props['country'] ?? '';
      widget.regioneController.text = props['state'] ?? '';
      widget.cittaController.text = props['city'] ?? props['town'] ?? props['village'] ?? '';
      String street = props['street'] ?? props['name'] ?? '';
      String houseNum = props['housenumber'] ?? '';
      widget.indirizzoController.text = "${street} ${houseNum}".trim();
      _selectedPosition = LatLng(lat, lng);
      _locationSuggestions = [];
      _searchController.clear();
      _showConfirmButton = false;
    });

    _mapController.move(_selectedPosition!, 15.0);
    widget.onLocationFound(lat, lng);
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleConfirm() async {
    if (_selectedPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_selectedPosition!.latitude, _selectedPosition!.longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        setState(() {
          widget.indirizzoController.text = "${p.thoroughfare ?? ''} ${p.subThoroughfare ?? ''}".trim();
          widget.cittaController.text = p.locality ?? p.subLocality ?? '';
          widget.regioneController.text = p.administrativeArea ?? '';
          widget.nazioneController.text = p.country ?? '';
          _showConfirmButton = false;
        });
        widget.onLocationFound(_selectedPosition!.latitude, _selectedPosition!.longitude);
      }
    } catch (e) {
      debugPrint("Errore Reverse Geocoding: $e");
      if (mounted) _mostraMessaggio("profile_error_address_not_found".tr());
      setState(() => _showConfirmButton = false);
    }
  }

  Future<void> _searchAddress(String address) async {
    if (address.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPos = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selectedPosition = newPos;
          _showConfirmButton = true;
        });
        _mapController.move(newPos, 15.0);
        FocusScope.of(context).unfocus();

        List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks[0];
          setState(() {
            widget.indirizzoController.text = "${p.thoroughfare ?? ''} ${p.subThoroughfare ?? ''}".trim();
            widget.cittaController.text = p.locality ?? p.subLocality ?? '';
            widget.regioneController.text = p.administrativeArea ?? '';
            widget.nazioneController.text = p.country ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("profile_error_address_not_found".tr())));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // LOGICA VERIFICA TELEFONO
  Future<void> _verifyPhone() async {
    if (widget.telefonoController.text.isEmpty) {
      _mostraMessaggio("ps_reg_error_phone_empty".tr());
      return;
    }
    setState(() => _isSendingOtp = true);

    final fullNumber = widget.telefonoPrefix + widget.telefonoController.text;

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
          widget.onPhoneVerifiedChanged(true);
          setState(() => _isSendingOtp = false);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isSendingOtp = false);
          _mostraMessaggio("login_error_prefix".tr(args: [e.message ?? '']));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isSendingOtp = false);
          _showOtpDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isSendingOtp = false);
      _mostraMessaggio("ps_reg_error_sms".tr());
    }
  }

  // LOGICA VERIFICA EMAIL
  Future<void> _verifyEmail() async {
    final email = widget.emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _mostraMessaggio("ps_reg_error_email_invalid".tr());
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      bool isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');

      if (email == user.email) {
        if (user.emailVerified || isGoogleUser) {
          widget.onEmailVerifiedChanged(true);
          _mostraMessaggio("ps_reg_email_already_verified".tr());
          return;
        }
      } else {
        if (isGoogleUser) {
          _mostraMessaggio("ps_reg_error_google_email".tr());
          widget.emailController.text = user.email ?? "";
          return;
        }
      }

      setState(() {
        _isSendingEmail = true;
        _isEmailTimerRunning = false;
      });

      if (email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      } else {
        await user.sendEmailVerification();
      }

      if (mounted) {
        setState(() {
          _isSendingEmail = false;
          _isEmailTimerRunning = true; 
        });
        _mostraMessaggio("ps_reg_email_sent_link".tr());
      }

      _emailCheckTimer?.cancel();
      _emailCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (!mounted) { timer.cancel(); return; }

        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;

        if (updatedUser != null && updatedUser.emailVerified && (updatedUser.email == email || email == user.email)) {
          widget.onEmailVerifiedChanged(true);
          setState(() => _isEmailTimerRunning = false);
          timer.cancel();
          if (mounted) {
            _mostraMessaggio("ps_reg_email_success".tr());
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      setState(() { _isSendingEmail = false; _isEmailTimerRunning = false; });
      if (e.code == 'requires-recent-login') {
        _mostraMessaggio("ps_reg_error_recent_login".tr());
      } else {
        _mostraMessaggio("login_error_prefix".tr(args: [e.message ?? '']));
      }
    } catch (e) {
      setState(() { _isSendingEmail = false; _isEmailTimerRunning = false; });
      _mostraMessaggio("snack_error_msg".tr(args: ['']));
    }
  }

  void _mostraMessaggio(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }

  void _showOtpDialog(String verificationId) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("ps_reg_otp_dialog_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("ps_reg_otp_dialog_msg".tr()),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "ps_reg_otp_hint".tr(),
                filled: true, fillColor: bgLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("btn_cancel".tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: indigoColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              try {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: codeController.text);
                await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
                widget.onPhoneVerifiedChanged(true);
                Navigator.pop(context);
                _mostraMessaggio("ps_reg_phone_success".tr());
              } catch (e) {
                _mostraMessaggio("ps_reg_error_otp_invalid".tr());
              }
            },
            child: Text("btn_confirm_action".tr(), style: const TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  Future<void> _handlePhotoSelection(File pickedFile) async {
    FocusScope.of(context).unfocus();
    final File? edited = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoEditorPage(imageFile: pickedFile)),
    );
    
    if (edited != null) {
      final optimized = await ImageOptimizer.optimize(file: edited);
      widget.onFotoProPicked(optimized);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 35),

            Column(
              children: [
                Center(child: _buildProfessionalPhoto(widget.fotoChiSeiPro, widget.existingFotoUrl, _handlePhotoSelection)),
                const SizedBox(height: 8),
                Text("ps_reg_label_photo_req".tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: secondaryTextColor.withOpacity(0.5), letterSpacing: 1)),
              ],
            ),

            if (widget.emailVerified || widget.phoneVerified || widget.identityVerified)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Wrap(
                  spacing: 10, runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    VerificationBadges.identity(verified: widget.identityVerified),
                    VerificationBadges.email(verified: widget.emailVerified),
                    VerificationBadges.phone(verified: widget.phoneVerified),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            _buildSectionCard(
              title: "ps_reg_section_prof_identity".tr(), 
              icon: Icons.storefront_rounded, 
              color: const Color(0xFFE0F2FE), 
              accentColor: Colors.blueAccent,
              children: [
                _buildModernField("ps_reg_label_page_name".tr(), widget.nicknameController, hint: "ps_reg_hint_page_name".tr(), readOnly: false, labelColor: Colors.blue[800]!),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "ps_reg_desc_page_name".tr(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                  ),
                ),
              ]
            ),
            const SizedBox(height: 25),

            _buildSectionCard(
              title: "ps_reg_section_personal_info".tr(), 
              icon: Icons.person_rounded, 
              color: const Color(0xFFE0F2FE), 
              accentColor: Colors.blueAccent,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "ps_reg_desc_verify_doc".tr(),
                          style: TextStyle(fontSize: 12, color: secondaryTextColor, fontWeight: FontWeight.bold, height: 1.4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          widget.onResetScanner();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: indigoColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.camera_enhance_rounded, color: indigoColor, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildModernField("profile_label_firstname".tr(), widget.nomeController, readOnly: true, labelColor: Colors.blue[800]!),
                _buildModernField("profile_label_lastname".tr(), widget.cognomeController, readOnly: true, labelColor: Colors.blue[800]!),
                _buildModernField("profile_label_birthdate_full".tr(), widget.dataNascitaController, readOnly: true, labelColor: Colors.blue[800]!),
              ]
            ),
            const SizedBox(height: 25),
            
            _buildSectionCard(
              title: "profile_tab_contacts".tr(), 
              icon: Icons.alternate_email_rounded, 
              color: const Color(0xFFDCFCE7), 
              accentColor: Colors.green[700]!,
              children: [
                _buildVerifiedField(
                  label: "ps_reg_label_email_req".tr(),
                  controller: widget.emailController,
                  isVerified: widget.emailVerified,
                  onVerify: _verifyEmail,
                  icon: Icons.email_rounded,
                  isProcessing: _isSendingEmail,
                  isWaiting: _isEmailTimerRunning,
                  activeColor: Colors.green[700]!
                ),
                _buildVerifiedField(
                  label: "ps_reg_label_phone".tr(), 
                  controller: widget.telefonoController,
                  isVerified: widget.phoneVerified,
                  onVerify: _verifyPhone,
                  icon: Icons.phone_android_rounded,
                  isProcessing: _isSendingOtp,
                  prefix: widget.telefonoPrefix,
                  onPrefixTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrefixSelector(onSelected: widget.onPrefixChanged))),
                  activeColor: Colors.green[700]!
                ),
              ]
            ),
            const SizedBox(height: 25),

            _buildSectionCard(
              title: "ps_reg_section_address".tr(), 
              icon: Icons.map_rounded, 
              color: const Color(0xFFFFF1E6), 
              accentColor: const Color(0xFFFFB347),
              children: [
                _buildLabel("ps_reg_label_search_address".tr(), const Color(0xFFD35400)),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      scrollPadding: const EdgeInsets.only(bottom: 150),
                      decoration: InputDecoration(
                        hintText: "ps_reg_hint_address".tr(),
                        hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.5)),
                        filled: true, fillColor: bgLight,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFFFB347)),
                        suffixIcon: _isSearching 
                          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFB347))) 
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFFB347)),
                              onPressed: () => _searchAddress(_searchController.text),
                            ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (val) => _searchAddress(val),
                    ),
                    if (_locationSuggestions.isNotEmpty)
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _locationSuggestions.length,
                              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                              itemBuilder: (context, index) {
                                final f = _locationSuggestions[index];
                                final p = f['properties'];
                                return ListTile(
                                  leading: const Icon(Icons.location_on, color: Color(0xFFFFB347), size: 20),
                                  title: Text(p['name'] ?? p['street'] ?? "profile_label_address".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text("${p['city'] ?? ''}, ${p['state'] ?? ''} ${p['country'] ?? ''}", style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                                  onTap: () => _applySelectedLocation(f),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFB347).withOpacity(0.3), width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _selectedPosition ?? const LatLng(41.9028, 12.4964),
                          initialZoom: 13.0,
                          onTap: (tp, latlng) => setState(() {
                            _selectedPosition = latlng;
                            _showConfirmButton = true;
                          })
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.petping.app'),
                          if (_selectedPosition != null) MarkerLayer(markers: [Marker(point: _selectedPosition!, width: 40, height: 40, child: const Icon(Icons.location_pin, color: Color(0xFFFFB347), size: 40))]),
                        ]
                      ),
                      if (_showConfirmButton)
                        Positioned(
                          bottom: 15, left: 40, right: 40,
                          child: ElevatedButton(
                            onPressed: _handleConfirm,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB347), elevation: 10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            child: Text("ps_reg_btn_confirm_here".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          )
                        )
                    ])
                  )
                ),
                const SizedBox(height: 25),
                Row(children: [
                  Expanded(child: _buildModernField("profile_label_country".tr(), widget.nazioneController, labelColor: const Color(0xFFD35400))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildModernField("profile_label_region".tr(), widget.regioneController, labelColor: const Color(0xFFD35400))),
                ]),
                Row(children: [
                  Expanded(child: _buildModernField("profile_label_city".tr(), widget.cittaController, labelColor: const Color(0xFFD35400))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildModernField("profile_label_neighborhood".tr(), widget.quartiereController, labelColor: const Color(0xFFD35400))),
                ]),
                _buildModernField("profile_label_address".tr(), widget.indirizzoController, labelColor: const Color(0xFFD35400)),
              ]
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 30, decoration: BoxDecoration(color: indigoColor, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Text("ps_reg_header_sitter_profile".tr(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 8),
        Text("ps_reg_sub_header_sitter_profile".tr(), style: TextStyle(color: secondaryTextColor, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVerifiedField({
    required String label,
    required TextEditingController controller,
    required bool isVerified,
    required VoidCallback onVerify,
    required IconData icon,
    required bool isProcessing,
    bool isWaiting = false,
    String? prefix,
    VoidCallback? onPrefixTap,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isVerified ? accentEmerald : activeColor.withOpacity(0.1), width: isVerified ? 2 : 1),
        ),
        child: Row(
          children: [
            if (prefix != null) ...[
              GestureDetector(
                onTap: isVerified ? null : onPrefixTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Text(prefix, style: TextStyle(fontWeight: FontWeight.w900, color: isVerified ? secondaryTextColor : activeColor, fontSize: 15)),
                      if (!isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: activeColor),
                      ],
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
            ],
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: isVerified || isWaiting,
                keyboardType: prefix != null ? TextInputType.phone : TextInputType.emailAddress,
                style: TextStyle(fontWeight: FontWeight.w600, color: isVerified ? secondaryTextColor : textColor),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (!isVerified)
              GestureDetector(
                onTap: isProcessing ? null : onVerify,
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isProcessing ? Colors.grey.shade100 : activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: isProcessing
                    ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        isWaiting ? "ps_reg_btn_resend".tr() : "ps_reg_btn_verify".tr(),
                        style: TextStyle(color: activeColor, fontWeight: FontWeight.w900, fontSize: 11)
                      ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Icon(Icons.check_circle_rounded, color: accentEmerald, size: 24),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField(String label, TextEditingController controller, {bool readOnly = false, int maxLines = 1, String? hint, Color? labelColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller, 
        readOnly: readOnly,
        maxLines: maxLines, 
        scrollPadding: const EdgeInsets.only(bottom: 150),
        style: TextStyle(fontWeight: FontWeight.w600, color: readOnly ? secondaryTextColor : textColor), 
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: labelColor ?? secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500),
          filled: true, 
          fillColor: readOnly ? bgLight.withOpacity(0.5) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: (labelColor ?? const Color(0xFFE2E8F0)).withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: labelColor ?? indigoColor, width: 2)),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children, required Color color, required Color accentColor}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(32), 
        border: Border.all(color: color, width: 4),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
      ), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(children: [
              Icon(icon, size: 20, color: accentColor), 
              const SizedBox(width: 12), 
              Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.2, fontSize: 13))
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ]
      )
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)));
  }

  Widget _buildProfessionalPhoto(File? file, String? existingUrl, Function(File) onPicked) {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        final p = await ImagePickerHelper.pickImageFromGallery();
        if (p != null) onPicked(p);
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: indigoColor, width: 3),
              boxShadow: [BoxShadow(color: indigoColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: ClipOval(
              child: file != null 
                ? Image.file(file, fit: BoxFit.cover)
                : (existingUrl != null && existingUrl.isNotEmpty 
                    ? Image.network(existingUrl, fit: BoxFit.cover)
                    : Icon(Icons.person_rounded, size: 70, color: Colors.grey[300])),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: indigoColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
