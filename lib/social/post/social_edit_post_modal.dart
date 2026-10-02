import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:petping/social/post/social_post_model.dart';
import 'package:petping/social/social_memoria_firebase.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/utils/image_optimizer.dart';
import 'package:easy_localization/easy_localization.dart';

class SocialEditPostModal extends StatefulWidget {
  final SocialPost post;
  final Map<String, dynamic> userData;

  const SocialEditPostModal({super.key, required this.post, required this.userData});

  @override
  State<SocialEditPostModal> createState() => _SocialEditPostModalState();
}

class _SocialEditPostModalState extends State<SocialEditPostModal> {
  late TextEditingController _textController;
  late TextEditingController _eventLocationController;
  late TextEditingController _eventLinkController;
  DateTime? _selectedEventDate;
  File? _newImage;
  String? _currentImageUrl;
  bool _isSaving = false;
  List<dynamic> _addressSuggestions = [];
  Timer? _debounceTimer;
  final _socialService = SocialMemoriaFirebase();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.post.testo);
    _eventLocationController = TextEditingController(text: widget.post.eventLocation);
    _eventLinkController = TextEditingController(text: widget.post.eventLink);
    _selectedEventDate = widget.post.eventDate;
    _currentImageUrl = widget.post.immagineUrl;
  }

  @override
  void dispose() {
    _textController.dispose();
    _eventLocationController.dispose();
    _eventLinkController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 3) {
      setState(() => _addressSuggestions = []);
      return;
    }
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
      final response = await http.get(url, headers: {'User-Agent': 'PetPingApp'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() => _addressSuggestions = data);
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        _newImage = File(img.path);
        _currentImageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEvento = widget.post.categoria == 'eventi';

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.black87)),
                    Expanded(
                      child: Center(
                        child: Text('social_post_edit_title'.tr(), 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 0.5)
                        ),
                      ),
                    ),
                    _isSaving 
                      ? const Padding(padding: EdgeInsets.only(right: 15), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : TextButton(
                          onPressed: () async {
                            setState(() => _isSaving = true);
                            try {
                              File? finalImage = _newImage;
                              if (finalImage != null) {
                                finalImage = await ImageOptimizer.optimize(
                                  file: finalImage,
                                  quality: 70,
                                  maxWidth: 1080,
                                );
                              }

                              await _socialService.aggiornaPost(
                                postId: widget.post.id,
                                testo: _textController.text,
                                immagineUrl: _currentImageUrl,
                                nuovaImmagine: finalImage,
                                eventDate: _selectedEventDate,
                                eventLocation: _eventLocationController.text,
                                eventLink: _eventLinkController.text,
                                lat: widget.post.lat,
                                lng: widget.post.lng,
                              );
                              if (mounted) Navigator.pop(context, true);
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()]))));
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                          style: TextButton.styleFrom(backgroundColor: PetStyle.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          child: Text('btn_save'.tr().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (isEvento) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                          border: Border.all(color: PetStyle.primary.withOpacity(0.15))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, color: PetStyle.primary, size: 20),
                                const SizedBox(width: 8),
                                Text("DETTAGLI EVENTO".toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: PetStyle.primary, letterSpacing: 1.2)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedEventDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) setState(() => _selectedEventDate = date);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, color: PetStyle.primary, size: 22),
                                    const SizedBox(width: 15),
                                    Text(
                                      _selectedEventDate == null ? "profile_select_placeholder".tr() : DateFormat('EEEE dd MMMM yyyy', context.locale.languageCode).format(_selectedEventDate!),
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _eventLocationController,
                              onChanged: (val) {
                                if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
                                _debounceTimer = Timer(const Duration(milliseconds: 500), () => _getSuggestions(val));
                              },
                              decoration: InputDecoration(
                                hintText: "social_hint_location".tr(),
                                prefixIcon: const Icon(Icons.location_on_rounded, color: PetStyle.primary, size: 22),
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                              ),
                            ),
                            if (_addressSuggestions.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                                child: Column(
                                  children: _addressSuggestions.map((item) => ListTile(
                                    title: Text(item['display_name'], style: const TextStyle(fontSize: 12)),
                                    onTap: () {
                                      setState(() {
                                        _eventLocationController.text = item['display_name'];
                                        _addressSuggestions = [];
                                      });
                                    },
                                  )).toList(),
                                ),
                              ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _eventLinkController,
                              decoration: InputDecoration(
                                hintText: "social_hint_link".tr(),
                                prefixIcon: const Icon(Icons.link_rounded, color: PetStyle.primary, size: 22),
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],

                    TextField(
                      controller: _textController,
                      maxLines: null,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5, color: Colors.black87),
                      decoration: InputDecoration(hintText: 'social_post_edit_text_hint'.tr(), border: InputBorder.none),
                    ),

                    const SizedBox(height: 20),

                    if (_currentImageUrl != null || _newImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: _newImage != null 
                              ? Image.file(_newImage!, fit: BoxFit.cover, width: double.infinity)
                              : Image.network(_currentImageUrl!, fit: BoxFit.cover, width: double.infinity),
                          ),
                          Positioned(
                            top: 12, right: 12,
                            child: GestureDetector(
                              onTap: () => setState(() { _currentImageUrl = null; _newImage = null; }),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: PetStyle.primary.withOpacity(0.3), style: BorderStyle.solid, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, size: 40, color: PetStyle.primary.withOpacity(0.5)),
                              const SizedBox(height: 10),
                              Text('social_label_add_img'.tr(), style: TextStyle(color: PetStyle.primary.withOpacity(0.7), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          if (_isSaving)
            Positioned.fill(
              child: Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
            ),
        ],
      ),
    );
  }
}
