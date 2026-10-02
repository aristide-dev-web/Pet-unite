import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/services/sitter_favorites_service.dart';
import 'package:petping/petsitting/services/sitter_service.dart';
import 'package:petping/petsitting/screens/search/sitter_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SitterFavoritesScreen extends StatelessWidget {
  const SitterFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFF43F5E); // Rose/Red
    final Color secondaryColor = const Color(0xFFFB7185);
    final Color bgLight = const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          // HEADER COLORATO
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 30, left: 10, right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, secondaryColor],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              boxShadow: [
                BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "ps_favorites_title".tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                      ),
                      Text(
                        "ps_favorites_subtitle".tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // Bilanciamento per l'icona back
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: SitterFavoritesService().getFavoritesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final favoriteIds = snapshot.data ?? [];

                if (favoriteIds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_outline_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 15),
                        Text(
                          "ps_favorites_empty".tr(),
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return ValueListenableBuilder(
                  valueListenable: Hive.box<SitterProfile>('sitters_box').listenable(),
                  builder: (context, Box<SitterProfile> box, _) {
                    return FutureBuilder<List<SitterProfile>>(
                      future: _loadMancanti(favoriteIds, box),
                      builder: (context, res) {
                        final savedSitters = res.data ?? [];
                        if (savedSitters.isEmpty && res.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: savedSitters.length,
                          itemBuilder: (context, index) {
                            return _buildSitterFavoriteCard(context, savedSitters[index], primaryColor);
                          },
                        );
                      }
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<SitterProfile>> _loadMancanti(List<String> ids, Box<SitterProfile> box) async {
    List<SitterProfile> results = [];
    for (String id in ids) {
      if (box.containsKey(id)) {
        results.add(box.get(id)!);
      } else {
        final p = await SitterService().getSitterProfile(id);
        if (p != null) results.add(p);
      }
    }
    return results;
  }

  Widget _buildSitterFavoriteCard(BuildContext context, SitterProfile sitter, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SitterDetailScreen(sitter: sitter))
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[100],
                backgroundImage: (sitter.fotoUrl.isNotEmpty) ? NetworkImage(sitter.fotoUrl) : null,
                child: sitter.fotoUrl.isEmpty ? Icon(Icons.person, color: color.withOpacity(0.5)) : null,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sitter.username.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
                  const SizedBox(height: 2),
                  Text("${sitter.quartiere}, ${sitter.citta}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(sitter.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.favorite_rounded, color: color),
              onPressed: () => SitterFavoritesService().toggleFavorite(sitter),
            ),
          ],
        ),
      ),
    );
  }
}
