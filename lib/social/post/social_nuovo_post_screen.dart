import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/social/social_memoria_firebase.dart';

class SocialNuovoPostScreen extends StatefulWidget {
  final String categoriaIniziale;
  const SocialNuovoPostScreen({super.key, this.categoriaIniziale = 'generale'});

  @override
  State<SocialNuovoPostScreen> createState() => _SocialNuovoPostScreenState();
}

class _SocialNuovoPostScreenState extends State<SocialNuovoPostScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _immagine;
  final _picker = ImagePicker();
  final _socialService = SocialMemoriaFirebase();
  bool _isLoading = false;
  late String _categoriaSelezionata;
  Map<String, dynamic>? _userData;

  final Color petPingColor = const Color(0xFF64B5B4);
  final Color petPingBg = const Color(0xFFF2F5F8);

  @override
  void initState() {
    super.initState();
    _categoriaSelezionata = widget.categoriaIniziale;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('utenti').doc(user.uid).get();
      setState(() => _userData = doc.data());
    }
  }

  Future<void> _scegliImmagine() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _immagine = File(picked.path));
    }
  }

  Future<void> _pubblicaPost() async {
    final testo = _textController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || (testo.isEmpty && _immagine == null)) return;

    setState(() => _isLoading = true);

    await _socialService.creaPost(
      uid: user.uid,
      autore: _userData?['username'] ?? 'Anonimo',
      fotoProfilo: _userData?['fotoUrl'],
      testo: testo,
      categoria: _categoriaSelezionata,
      ruoloAutore: _userData?['socialRole'] ?? 'proprietario',
      immagineFile: _immagine,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CREA POST',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _pubblicaPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: petPingColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('PUBBLICA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // USER INFO & CATEGORY BADGE
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: _userData?['fotoUrl'] != null ? NetworkImage(_userData!['fotoUrl']) : null,
                      backgroundColor: petPingBg,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userData?['username'] ?? 'Caricamento...', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _showCategoryPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: petPingBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: petPingColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.public_rounded, size: 12, color: petPingColor),
                                const SizedBox(width: 6),
                                Text(_categoriaSelezionata.toUpperCase(), style: TextStyle(fontSize: 9, color: petPingColor, fontWeight: FontWeight.w900)),
                                const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // TEXT INPUT
                TextField(
                  controller: _textController,
                  maxLines: null,
                  autofocus: true,
                  style: const TextStyle(fontSize: 22, height: 1.4, fontWeight: FontWeight.w400, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Cosa vuoi raccontare oggi?",
                    hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 22),
                    border: InputBorder.none,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // IMAGE PREVIEW
                if (_immagine != null)
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_immagine!, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: GestureDetector(
                          onTap: () => setState(() => _immagine = null),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // BOTTOM TOOLBAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5))],
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const Text("Aggiungi al tuo post", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black54, fontSize: 13)),
                  const Spacer(),
                  _toolIcon(Icons.photo_library_rounded, Colors.green, _scegliImmagine),
                  _toolIcon(Icons.camera_alt_rounded, Colors.blue, () {}),
                  _toolIcon(Icons.pets_rounded, Colors.orange, () {}),
                  _toolIcon(Icons.location_on_rounded, Colors.redAccent, () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 28),
      splashRadius: 25,
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Scegli dove pubblicare", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 25),
            _catTile('generale', "Generale", Icons.pets, Colors.teal),
            _catTile('avvistamenti', "Avvistamenti", Icons.location_on, Colors.orange),
            _catTile('cultura', "Cultura", Icons.menu_book, Colors.indigo),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _catTile(String id, String label, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        setState(() => _categoriaSelezionata = id);
        Navigator.pop(context);
      },
      trailing: _categoriaSelezionata == id ? Icon(Icons.check_circle, color: petPingColor) : null,
    );
  }
}
