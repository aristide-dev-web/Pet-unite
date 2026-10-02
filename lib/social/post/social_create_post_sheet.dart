import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/style/pet_style.dart';
import 'package:petping/social/social_memoria_firebase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petping/utils/image_optimizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialCreatePostSheet extends StatefulWidget {
  final String currentUserId;
  final String categoria;
  final Map<String, dynamic> userData;
  final Position? currentPosition;

  const SocialCreatePostSheet({
    super.key,
    required this.currentUserId,
    required this.categoria,
    required this.userData,
    this.currentPosition,
  });

  @override
  State<SocialCreatePostSheet> createState() => _SocialCreatePostSheetState();
}

class _SocialCreatePostSheetState extends State<SocialCreatePostSheet> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _eventLinkController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _postLocationController = TextEditingController();

  DateTime? _selectedEventDate;
  DateTime? _selectedEventEndDate;
  File? _selectedImage;
  List<dynamic> _addressSuggestions = [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _showLocationInput = false;
  final _socialService = SocialMemoriaFirebase();

  // MENTIONS & SUGGESTIONS
  List<Map<String, dynamic>> _userSuggestions = [];
  bool _showMentionsList = false;
  String _currentMentionQuery = "";
  int _mentionStartIndex = -1;
  String _activeTrigger = "@"; // Può essere @ o _

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _eventLinkController.dispose();
    _eventLocationController.dispose();
    _postLocationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    final selection = _textController.selection;
    
    if (selection.baseOffset <= 0) {
      _hideMentions();
      return;
    }

    final textBeforeCursor = text.substring(0, selection.baseOffset);
    
    // Cerca l'ultimo trigger (@ o _) prima del cursore
    final lastAt = textBeforeCursor.lastIndexOf('@');
    final lastUnderscore = textBeforeCursor.lastIndexOf('_');
    
    int lastTriggerIndex = -1;
    if (lastAt != -1 || lastUnderscore != -1) {
      lastTriggerIndex = (lastAt > lastUnderscore) ? lastAt : lastUnderscore;
      _activeTrigger = (lastAt > lastUnderscore) ? "@" : "_";
    }

    if (lastTriggerIndex != -1) {
      // Verifica che il trigger sia all'inizio o preceduto da spazio/invio (come FB/IG)
      bool isAtStart = lastTriggerIndex == 0;
      bool isAfterSpace = !isAtStart && (textBeforeCursor[lastTriggerIndex - 1] == ' ' || textBeforeCursor[lastTriggerIndex - 1] == '\n');
      
      if (isAtStart || isAfterSpace) {
        final query = textBeforeCursor.substring(lastTriggerIndex + 1);
        // Se c'è uno spazio dopo il trigger, smetti di suggerire
        if (!query.contains(' ') && !query.contains('\n')) {
          _mentionStartIndex = lastTriggerIndex;
          _currentMentionQuery = query;
          _searchUsers(query);
          return;
        }
      }
    }
    _hideMentions();
  }

  Future<void> _searchUsers(String query) async {
    // Se la query è vuota (solo @ o _) mostriamo suggerimenti generici o nulla
    Query queryRef = FirebaseFirestore.instance.collection('utenti');
    
    if (query.isNotEmpty) {
      queryRef = queryRef
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff');
    }

    try {
      final snapshot = await queryRef.limit(5).get();
      if (mounted) {
        setState(() {
          _userSuggestions = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          _showMentionsList = _userSuggestions.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint("Errore ricerca utenti: $e");
    }
  }

  void _hideMentions() {
    if (_showMentionsList) {
      setState(() {
        _showMentionsList = false;
        _userSuggestions = [];
      });
    }
  }

  void _addMention(String username) {
    final text = _textController.text;
    final selection = _textController.selection;
    final before = text.substring(0, _mentionStartIndex);
    final after = text.substring(selection.baseOffset);
    
    // Inseriamo il tag con lo stesso trigger usato (@ o _)
    final newText = "$before$_activeTrigger$username $after";
    _textController.text = newText;
    
    // Posiziona il cursore dopo lo spazio aggiunto
    _textController.selection = TextSelection.collapsed(offset: before.length + username.length + 2);
    _hideMentions();
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

  @override
  Widget build(BuildContext context) {
    bool isEvento = widget.categoria == 'eventi';
    bool isAvvistamento = widget.categoria == 'avvistamenti';

    Color accentColor = PetStyle.primary;
    if (isEvento) accentColor = const Color(0xFFFF7043);
    if (isAvvistamento) accentColor = const Color(0xFFEF5350);

    bool canPost = _textController.text.trim().isNotEmpty || _selectedImage != null;
    if (isEvento) {
      canPost = _textController.text.trim().isNotEmpty && _selectedImage != null && _selectedEventDate != null && (_eventLocationController.text.isNotEmpty);
    }

    String title = 'social_create_post_title'.tr();
    String subtitle = 'social_create_post_sub'.tr();
    if (isEvento) {
      title = 'social_create_event_title'.tr();
      subtitle = 'social_create_event_sub'.tr();
    } else if (isAvvistamento) {
      title = 'social_create_sighting_title'.tr();
      subtitle = 'social_create_sighting_sub'.tr();
    }

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
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.close_rounded, color: Colors.black87, size: 20)
                        )
                    ),
                    Expanded(
                        child: Column(
                          children: [
                            Text(title,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: accentColor,
                                    letterSpacing: 1.2
                                )
                            ),
                            const SizedBox(height: 2),
                            Text(
                                subtitle,
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)
                            ),
                          ],
                        )
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: TextButton(
                        onPressed: (!canPost || _isLoading) ? null : () async {
                          setState(() => _isLoading = true);
                          try {
                            File? finalImage = _selectedImage;
                            if (finalImage != null) {
                              finalImage = await ImageOptimizer.optimize(
                                file: finalImage,
                                quality: 70,
                                maxWidth: 1080,
                              );
                            }

                            await _socialService.creaPost(
                              uid: widget.currentUserId,
                              autore: widget.userData['username'] ?? 'User',
                              fotoProfilo: widget.userData['fotoUrl'],
                              testo: _textController.text,
                              categoria: widget.categoria,
                              ruoloAutore: widget.userData['socialRole'] ?? 'proprietario',
                              immagineFile: finalImage,
                              eventDate: _selectedEventDate,
                              eventLocation: isEvento ? _eventLocationController.text : _postLocationController.text,
                              eventLink: _eventLinkController.text,
                              lat: widget.currentPosition?.latitude,
                              lng: widget.currentPosition?.longitude,
                              eventEndDate: _selectedEventEndDate,
                            );
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('snack_error_msg'.tr(args: [e.toString()])))
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: canPost ? accentColor : Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: canPost ? 4 : 0,
                            shadowColor: accentColor.withOpacity(0.4)
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('social_btn_publish'.tr(), style: TextStyle(color: canPost ? Colors.white : Colors.grey.shade400, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5),

              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      children: [
                        // AUTORE
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.3)])
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage: widget.userData['fotoUrl'] != null ? NetworkImage(widget.userData['fotoUrl']) : null,
                                backgroundColor: Colors.white,
                                child: widget.userData['fotoUrl'] == null ? Icon(Icons.person, color: accentColor, size: 20) : null,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.userData['username'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: accentColor.withOpacity(0.15))
                                    ),
                                    child: Text(widget.categoria.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        if (isEvento) ...[
                          // ELEMENTI DI SCRITTURA EVENTO
                          Text('social_label_when'.tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5)),
                          const SizedBox(height: 12),
                          _buildGlassGlowPanel(
                            padding: EdgeInsets.zero,
                            accentColor: accentColor,
                            child: _buildDateTimeTile(
                                label: 'social_label_start_date'.tr(),
                                dt: _selectedEventDate,
                                icon: Icons.calendar_today_rounded,
                                color: accentColor,
                                onTap: () => _pickDateTime(isStart: true, accentColor: accentColor)
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildGlassGlowPanel(
                            padding: EdgeInsets.zero,
                            accentColor: accentColor,
                            child: _buildDateTimeTile(
                                label: 'social_label_end_date'.tr(),
                                dt: _selectedEventEndDate,
                                icon: Icons.event_available_rounded,
                                color: accentColor,
                                isOptional: true,
                                onClear: () => setState(() => _selectedEventEndDate = null),
                                onTap: () => _pickDateTime(isStart: false, accentColor: accentColor)
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text('social_label_where_contacts'.tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5)),
                          const SizedBox(height: 12),
                          _buildGlassGlowPanel(
                            padding: EdgeInsets.zero,
                            accentColor: accentColor,
                            child: _buildModernField(
                              controller: _eventLocationController,
                              hint: 'social_hint_location'.tr(),
                              icon: Icons.location_on_rounded,
                              accentColor: accentColor,
                              isLocation: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildGlassGlowPanel(
                            padding: EdgeInsets.zero,
                            accentColor: accentColor,
                            child: _buildModernField(
                              controller: _eventLinkController,
                              hint: 'social_hint_link'.tr(),
                              icon: Icons.link_rounded,
                              accentColor: accentColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],

                        if (_showLocationInput && !isEvento) ...[
                          _buildGlassGlowPanel(
                            padding: EdgeInsets.zero,
                            accentColor: accentColor,
                            child: _buildModernField(
                                controller: _postLocationController,
                                hint: 'social_tool_location_hint'.tr(),
                                icon: Icons.location_on_rounded,
                                accentColor: accentColor,
                                isLocation: true
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],

                        // DESCRIZIONE
                        Text(isEvento ? 'social_label_description'.tr() : 'social_label_what_to_say'.tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        _buildGlassGlowPanel(
                          accentColor: accentColor,
                          padding: const EdgeInsets.all(18),
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, height: 1.5, color: Color(0xFF334155)),
                            decoration: InputDecoration(
                              hintText: isEvento ? 'social_hint_desc_event'.tr() : (isAvvistamento ? 'social_hint_desc_sighting'.tr() : 'social_hint_desc_default'.tr()),
                              hintStyle: TextStyle(fontSize: 17, color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        // IMMAGINE
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))]
                                  ),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity)),
                                ),
                                Positioned(top: 15, right: 15, child: GestureDetector(onTap: () => setState(() => _selectedImage = null), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 20)))),
                              ],
                            ),
                          )
                        else 
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: GestureDetector(
                              onTap: () async {
                                final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                                if (img != null) setState(() => _selectedImage = File(img.path));
                              },
                              child: _buildGlassGlowPanel(
                                accentColor: accentColor,
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
                                        child: Icon(Icons.add_photo_alternate_outlined, size: 45, color: accentColor)
                                    ),
                                    const SizedBox(height: 20),
                                    Text(isEvento ? 'social_label_upload_img'.tr() : 'social_label_add_img'.tr(), style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(height: 5),
                                    Text(isEvento ? 'social_sub_img_event'.tr() : 'social_sub_img_default'.tr(), style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 120),
                      ],
                    ),
                    
                    // SUGGESTIONS OVERLAY (FB/IG STYLE)
                    if (_showMentionsList)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -5))
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                                child: Text(
                                  _activeTrigger == "@" ? 'social_tool_mention'.tr() : 'social_tool_suggestions'.tr(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.5),
                                ),
                              ),
                              Flexible(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  itemCount: _userSuggestions.length,
                                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade50, indent: 70),
                                  itemBuilder: (context, index) {
                                    final user = _userSuggestions[index];
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                      leading: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accentColor.withOpacity(0.2))),
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: user['fotoUrl'] != null ? NetworkImage(user['fotoUrl']) : null,
                                          child: user['fotoUrl'] == null ? Icon(Icons.person, size: 18, color: accentColor) : null,
                                        ),
                                      ),
                                      title: Text(
                                        user['username'] ?? 'User', 
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))
                                      ),
                                      subtitle: Text(
                                        user['socialRole'] ?? 'Membro della community',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)
                                      ),
                                      onTap: () => _addMention(user['username']),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // TOOLBAR BOTTOM
              _buildBottomToolbar(isEvento, accentColor),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.white.withOpacity(0.3),
                    child: Center(child: CircularProgressIndicator(color: accentColor, strokeWidth: 3)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- GLASS GLOW PANEL ---

  Widget _buildGlassGlowPanel({required Widget child, required Color accentColor, EdgeInsetsGeometry padding = const EdgeInsets.all(22)}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // --- TOOLBAR CON STRUMENTI ---

  Widget _buildBottomToolbar(bool isEvento, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: Row(
        children: [
          Text('social_tools_title'.tr(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.grey.shade600)),
          const Spacer(),
          // LUMACHINA (@)
          _toolWidgetGlass(
            PetStyle.petTagIcon(size: 45), 
            const Color(0xFF6366F1), 
            () {
              _insertTrigger("@");
            },
            isSpecial: true,
          ),
          // POSIZIONE
          _toolIconGlass(Icons.location_on_rounded, const Color(0xFFEF5350), () {
            setState(() {
              _showLocationInput = !_showLocationInput;
            });
          }),
          // CAMERA
          _toolIconGlass(Icons.camera_alt_rounded, const Color(0xFFFFB300), () async {
             final img = await ImagePicker().pickImage(source: ImageSource.camera);
             if (img != null) setState(() => _selectedImage = File(img.path));
          }),
        ],
      ),
    );
  }

  void _insertTrigger(String trigger) {
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = text.replaceRange(selection.start, selection.end, trigger);
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(offset: selection.start + 1);
    _onTextChanged();
  }

  Widget _toolIconGlass(IconData icon, Color color, VoidCallback onTap) {
     return _toolWidgetGlass(Icon(icon, color: color, size: 24), color, onTap);
  }

  Widget _toolWidgetGlass(Widget child, Color color, VoidCallback onTap, {bool isSpecial = false}) {
    double boxSize = isSpecial ? 40 : 32;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, spreadRadius: -2, offset: const Offset(0, 4))
            ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.all(isSpecial ? 4 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: SizedBox(width: boxSize, height: boxSize, child: Center(child: child)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeTile({required String label, required DateTime? dt, required IconData icon, required Color color, bool isOptional = false, VoidCallback? onClear, required VoidCallback onTap}) {
    String mainText = "Seleziona data e ora"; // TODO: tr
    String dayLabel = "";
    if (dt != null) {
      mainText = DateFormat('dd MMMM yyyy - HH:mm', context.locale.languageCode).format(dt);
      dayLabel = DateFormat('EEEE', context.locale.languageCode).format(dt).toUpperCase();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: dt == null ? color.withOpacity(0.04) : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dt == null ? color.withOpacity(0.1) : color.withOpacity(0.2))
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 5)]),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  if (dt != null)
                    Text(dayLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
                  Text(mainText, style: TextStyle(fontSize: 15, fontWeight: dt == null ? FontWeight.w600 : FontWeight.w900, color: dt == null ? Colors.grey.shade600 : Colors.black87)),
                ],
              ),
            ),
            if (isOptional && dt != null)
              GestureDetector(onTap: onClear, child: Icon(Icons.cancel_rounded, color: Colors.grey.shade400, size: 20))
            else if (dt == null)
              Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField({required TextEditingController controller, required String hint, required IconData icon, required Color accentColor, bool isLocation = false}) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: isLocation ? (val) {
            if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 500), () => _getSuggestions(val));
          } : null,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 5)]),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: accentColor, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w600)
          ),
        ),
        if (isLocation && _addressSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]
            ),
            child: Column(
              children: _addressSuggestions.map((item) => ListTile(
                leading: Icon(Icons.location_on_outlined, color: accentColor, size: 20),
                title: Text(item['display_name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                onTap: () {
                  setState(() {
                    controller.text = item['display_name'];
                    _addressSuggestions = [];
                  });
                },
              )).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _pickDateTime({required bool isStart, required Color accentColor}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (_selectedEventDate ?? DateTime.now()),
      firstDate: isStart ? DateTime.now() : (_selectedEventDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: accentColor)),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: accentColor)),
          child: child!,
        ),
      );
      if (time != null) {
        setState(() {
          final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          if (isStart) _selectedEventDate = dt; else _selectedEventEndDate = dt;
        });
      }
    }
  }
}
