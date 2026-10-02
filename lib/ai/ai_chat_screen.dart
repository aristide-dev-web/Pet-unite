import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petping/ai/ai_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class AIChatScreen extends StatefulWidget {
  final String? initialMessage;
  const AIChatScreen({super.key, this.initialMessage});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  XFile? _selectedImage;
  
  Map<String, dynamic>? _selectedPet;
  List<Map<String, dynamic>> _myPets = [];
  
  late Box _sessionsBox;
  String? _currentSessionId;
  List<Map<String, dynamic>> _allSessions = [];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      _sessionsBox = await Hive.openBox('ai_sessions_v6');
      _loadPetsFromCache();
      await _loadPetsFromFirestore();
      _loadSessionsList();
    } catch (e) {
      // Errore initChat
    }
  }

  void _loadPetsFromCache() {
    final cachedPets = _sessionsBox.get('cached_pets_list');
    if (cachedPets != null) {
      setState(() {
        _myPets = List<Map<String, dynamic>>.from(
          cachedPets.map((p) => Map<String, dynamic>.from(p))
        );
      });
    }
  }

  Future<void> _loadPetsFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('animali').where('userId', isEqualTo: userId).get();
      final petsList = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      if (mounted) {
        setState(() => _myPets = petsList);
        await _sessionsBox.put('cached_pets_list', petsList);
      }
    } catch (e) { /* Error syncing pets */ }
  }

  void _loadSessionsList() {
    final sessionsData = _sessionsBox.get('sessions_list', defaultValue: []);
    setState(() {
      _allSessions = List<Map<String, dynamic>>.from(sessionsData.map((s) => Map<String, dynamic>.from(s)));
      _allSessions.sort((a, b) => b['lastUpdate'].compareTo(a['lastUpdate']));
    });
    if (_allSessions.isNotEmpty) {
       _loadSession(_allSessions.first['id']);
       // Se abbiamo un messaggio iniziale, lo inviamo come nuova chat o lo aggiungiamo?
       // Di solito se si passa initialMessage si vuole una nuova chat contestuale.
       if (widget.initialMessage != null) {
         _createNewChat(initialText: widget.initialMessage);
       }
    } else {
      _createNewChat(initialText: widget.initialMessage);
    }
  }

  void _createNewChat({String? initialText}) {
    final newId = const Uuid().v4();
    setState(() {
      _currentSessionId = newId;
      _messages = [];
      _selectedPet = null;
      _aiService.resetChat();
      _addBotMessage("ai_welcome_msg".tr(), save: false);
    });
    if (initialText != null) {
      _controller.text = initialText;
      _sendMessage();
    }
  }

  void _loadSession(String sessionId) {
    if (_currentSessionId == sessionId && _messages.isNotEmpty) return;
    final sessionData = _sessionsBox.get('messages_$sessionId', defaultValue: []);
    final messages = List<ChatMessage>.from(sessionData.map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m))));
    setState(() {
      _currentSessionId = sessionId;
      _messages = messages;
      _aiService.resetChat();
    });
    List<Content> aiHistory = [];
    for (var msg in _messages) {
      if (msg.role == 'user') aiHistory.add(Content.text(msg.text));
      else aiHistory.add(Content.model([TextPart(msg.text)]));
    }
    _aiService.startHistoryChat(aiHistory);
    _scrollToBottom();
  }

  Future<void> _saveCurrentSession() async {
    if (_currentSessionId == null) return;
    await _sessionsBox.put('messages_$_currentSessionId', _messages.map((m) => m.toMap()).toList());
    String title = "ai_new_conversation".tr();
    for (var m in _messages) { if (m.role == 'user') { title = m.text.length > 25 ? "${m.text.substring(0, 25)}..." : m.text; break; } }
    final sessionMeta = {'id': _currentSessionId, 'title': title, 'lastUpdate': DateTime.now().toIso8601String(), 'petName': _selectedPet?['nome']};
    final existingIndex = _allSessions.indexWhere((s) => s['id'] == _currentSessionId);
    if (existingIndex != -1) _allSessions[existingIndex] = sessionMeta;
    else _allSessions.insert(0, sessionMeta);
    await _sessionsBox.put('sessions_list', _allSessions);
    if (mounted) setState(() {});
  }

  Future<void> _selectPet(Map<String, dynamic> pet) async {
    setState(() { _selectedPet = pet; _isLoading = true; });
    _aiService.setPetContext("Nome: ${pet['nome']}, Specie: ${pet['tipo']}");
    _addBotMessage("ai_pet_profile_loaded".tr(args: [pet['nome'] ?? 'Pet']));
    setState(() => _isLoading = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _addBotMessage(String text, {bool save = true}) {
    setState(() { _messages.add(ChatMessage(role: 'ai', text: text, time: DateTime.now())); });
    if (save) _saveCurrentSession();
    _scrollToBottom();
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) setState(() => _selectedImage = image);
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    Uint8List? imageBytes;
    String? localImagePath;
    if (_selectedImage != null) {
      imageBytes = await _selectedImage!.readAsBytes();
      localImagePath = _selectedImage!.path;
    }
    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text, imagePath: localImagePath, time: DateTime.now()));
      _isLoading = true;
      _controller.clear();
      _selectedImage = null;
    });
    _saveCurrentSession();
    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(text.isEmpty ? "Analizza questa immagine." : text, imageBytes: imageBytes);
      if (mounted) {
        _addBotMessage(response);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _addBotMessage("ai_error_send".tr(args: [e.toString()]));
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteSession(String id) async {
    await _sessionsBox.delete('messages_$id');
    setState(() { _allSessions.removeWhere((s) => s['id'] == id); });
    await _sessionsBox.put('sessions_list', _allSessions);
    if (_currentSessionId == id) _createNewChat();
  }

  @override
  Widget build(BuildContext context) {
    const Color deepDark = Color(0xFF0F172A);
    const Color messageDark = Color(0xFF1E293B);
    const Color accentBlue = Color(0xFF38BDF8);

    return Scaffold(
      backgroundColor: deepDark,
      drawer: _buildHistoryDrawer(messageDark, accentBlue),
      appBar: AppBar(
        backgroundColor: messageDark,
        elevation: 0,
        centerTitle: true,
        title: Text("ai_title".tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.history_rounded, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer())),
        actions: [
          IconButton(icon: const Icon(Icons.add_comment_rounded, color: Colors.white), onPressed: _createNewChat)
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDarkPetSelector(messageDark, accentBlue),
            Expanded(child: ListView.builder(controller: _scrollController, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), itemCount: _messages.length, itemBuilder: (context, index) => _buildDarkMessage(_messages[index], messageDark, accentBlue))),
            if (_isLoading) _buildDarkLoadingIndicator(accentBlue),
            _buildDarkInputArea(deepDark, messageDark, accentBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer(Color messageDark, Color accentBlue) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: Column(
        children: [
          DrawerHeader(decoration: BoxDecoration(color: messageDark), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.history_rounded, color: Colors.white, size: 40), const SizedBox(height: 10), Text("ai_history_title".tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]))),
          Expanded(child: ListView.builder(padding: const EdgeInsets.all(10), itemCount: _allSessions.length, itemBuilder: (context, index) {
            final session = _allSessions[index];
            final isCurrent = session['id'] == _currentSessionId;
            return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: isCurrent ? accentBlue.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(15), border: Border.all(color: isCurrent ? accentBlue : Colors.white10),), child: ListTile(onTap: () { _loadSession(session['id']); Navigator.pop(context); }, title: Text(session['title'] ?? 'Chat', style: TextStyle(color: isCurrent ? accentBlue : Colors.white, fontSize: 13, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)), subtitle: Text(DateFormat('dd/MM HH:mm').format(DateTime.parse(session['lastUpdate'])), style: const TextStyle(color: Colors.white24, fontSize: 10)), trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18), onPressed: () => _deleteSession(session['id']))));
          })),
          Padding(padding: const EdgeInsets.all(20), child: ElevatedButton.icon(onPressed: () { _createNewChat(); Navigator.pop(context); }, icon: const Icon(Icons.add), label: Text("ai_new_chat".tr()), style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), minimumSize: const Size(double.infinity, 50)))),
        ],
      ),
    );
  }

  Widget _buildDarkPetSelector(Color messageDark, Color accentBlue) {
    if (_myPets.isEmpty) return const SizedBox.shrink();
    return Container(height: 125, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: messageDark, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))), child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: _myPets.length, itemBuilder: (context, index) {
      final pet = _myPets[index];
      final isSelected = _selectedPet?['id'] == pet['id'];
      return GestureDetector(onTap: () => _selectPet(pet), child: Container(margin: const EdgeInsets.only(right: 20), child: Column(children: [
        Container(
          padding: const EdgeInsets.all(2.5), 
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            border: Border.all(color: isSelected ? accentBlue : Colors.white.withOpacity(0.05), width: 2)
          ), 
          child: ClipOval(
            child: CircleAvatar(
              radius: 28, 
              backgroundColor: const Color(0xFF334155), 
              backgroundImage: (pet['fotoUrl'] != null && pet['fotoUrl'] != '') ? NetworkImage(pet['fotoUrl']) : null, 
              child: (pet['fotoUrl'] == null || pet['fotoUrl'] == '') ? const Icon(Icons.pets_rounded, size: 24, color: Colors.white24) : null
            ),
          )
        ), 
        const SizedBox(height: 6), 
        Text(pet['nome'] ?? '', style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? accentBlue : Colors.white.withOpacity(0.6)))
      ])));
    }));
  }

  Widget _buildDarkMessage(ChatMessage msg, Color messageDark, Color accentBlue) {
    final isUser = msg.role == 'user';
    final timeStr = DateFormat('HH:mm').format(msg.time);
    return Padding(padding: const EdgeInsets.only(bottom: 24), child: Row(mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!isUser) ...[
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: ClipOval(
            child: Image.asset('assets/images/pet.png', fit: BoxFit.contain, filterQuality: FilterQuality.high),
          ),
        ),
        const SizedBox(width: 12)
      ],
      Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), decoration: BoxDecoration(gradient: isUser ? const LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF1D4ED8)]) : null, color: isUser ? null : messageDark, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        if (msg.imagePath != null) Padding(padding: const EdgeInsets.only(bottom: 8.0), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(msg.imagePath!), width: 240, height: 240, fit: BoxFit.cover))),
        Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
        const SizedBox(height: 8),
        Text(timeStr, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
      ]))),
      if (isUser) const SizedBox(width: 12),
    ]));
  }

  Widget _buildDarkLoadingIndicator(Color accentBlue) => Padding(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), child: Row(children: [Text("ai_analyzing".tr(), style: const TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic)), const SizedBox(width: 10), _PremiumDots(color: accentBlue)]));

  Widget _buildDarkInputArea(Color deepDark, Color messageDark, Color accentBlue) {
    return Container(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), decoration: BoxDecoration(color: messageDark, borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))), child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (_selectedImage != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Stack(clipBehavior: Clip.none, children: [Container(height: 90, width: 90, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: FileImage(File(_selectedImage!.path)), fit: BoxFit.cover))), Positioned(top: -10, right: -10, child: GestureDetector(onTap: () => setState(() => _selectedImage = null), child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 16, color: Colors.white))))])),
      Row(children: [IconButton(icon: const Icon(Icons.image_outlined, color: Colors.white70, size: 26), onPressed: _pickImage), const SizedBox(width: 12), Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(30)), child: TextField(controller: _controller, maxLines: null, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "ai_input_hint".tr(), hintStyle: const TextStyle(color: Colors.white30), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14))))), const SizedBox(width: 12), GestureDetector(onTap: _sendMessage, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [accentBlue, const Color(0xFF0284C7)]), shape: BoxShape.circle), child: const Icon(Icons.send_rounded, color: Colors.white, size: 22)))]),
    ]));
  }
}

class _PremiumDots extends StatefulWidget {
  final Color color;
  const _PremiumDots({this.color = Colors.lightBlue, super.key});
  @override
  _PremiumDotsState createState() => _PremiumDotsState();
}

class _PremiumDotsState extends State<_PremiumDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(3, (index) {
        return AnimatedBuilder(animation: _controller, builder: (context, child) {
            final delay = index * 0.2;
            final value = Curves.easeInOut.transform(((_controller.value - delay) % 1.0));
            return Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 6, height: 6, decoration: BoxDecoration(color: widget.color.withOpacity(0.3 + (value * 0.7)), shape: BoxShape.circle));
          });
      }));
  }
}

class ChatMessage {
  final String role;
  final String text;
  final String? imagePath;
  final DateTime time;
  ChatMessage({required this.role, required this.text, this.imagePath, required this.time});
  Map<String, dynamic> toMap() => {'role': role, 'text': text, 'imagePath': imagePath, 'time': time.toIso8601String()};
  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(role: map['role'], text: map['text'], imagePath: map['imagePath'], time: DateTime.parse(map['time']));
}
