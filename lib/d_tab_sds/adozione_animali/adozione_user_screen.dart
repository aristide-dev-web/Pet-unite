import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petping/utils/navigator_helpers.dart';
import 'package:easy_localization/easy_localization.dart';

class AdozioneUserScreen extends StatefulWidget {
  const AdozioneUserScreen({super.key});

  @override
  State<AdozioneUserScreen> createState() => _AdozioneUserScreenState();
}

class _AdozioneUserScreenState extends State<AdozioneUserScreen> {
  List<DocumentSnapshot> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('animali_adozione')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      _results = snapshot.docs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('adozione_user_screen_title'.tr())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? Center(child: Text('adozione_user_screen_empty'.tr()))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final animal = _results[index].data() as Map<String, dynamic>;
          final nome = animal['nome'] ?? 'label_none'.tr();
          final specie = animal['specie'] ?? '';
          final razza = animal['razza'] ?? '';
          final eta = animal['età'] ?? '';
          final zona = animal['zona'] ?? '';
          final imageUrl = animal['immagine'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.pets, size: 32),
                  title: Text('$nome - $specie'),
                  subtitle: Text('adozione_user_screen_details'.tr(args: [razza, eta, zona])),
                  isThreeLine: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: Text('adozione_user_screen_owner_btn'.tr()),
                    onPressed: () => apriProfiloPubblico(context, animal['userId']),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}