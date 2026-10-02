import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/screens/search/sitter_detail_screen.dart';
import 'package:petping/petsitting/screens/search/components/filter_chips_bar.dart';
import 'package:petping/petsitting/services/sitter_favorites_service.dart';
import 'package:petping/utils/geo_service.dart';
import 'package:petping/utils/verification_badges.dart';

class SitterSearchScreen extends StatefulWidget {
  const SitterSearchScreen({super.key});

  @override
  State<SitterSearchScreen> createState() => _SitterSearchScreenState();
}

class _SitterSearchScreenState extends State<SitterSearchScreen> {
  final Color primaryIndigo = const Color(0xFF6366F1);
  final Color secondaryIndigo = const Color(0xFF818CF8);
  final Color bgLight = const Color(0xFFF8FAFC);
  
  String _selectedService = ""; 
  String _searchQuery = "";
  Position? _userPosition;
  bool _isLoadingLocation = true;
  bool _isSyncing = false;
  final TextEditingController _searchController = TextEditingController();

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  static const int _pageSize = 6; 
  final List<SitterProfile> _loadedSitters = []; 

  @override
  void initState() {
    super.initState();
    _initSearch();
  }

  Future<void> _initSearch() async {
    _loadFromHive();
    _getUserLocation().then((_) => _sortLoadedSitters());
    _loadMoreSitters(reset: true);
  }

  void _loadFromHive() {
    final box = Hive.box<SitterProfile>('sitters_box');
    if (box.isNotEmpty) {
      setState(() {
        _loadedSitters.addAll(box.values.toList());
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final pos = await GeoService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userPosition = pos;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _sortLoadedSitters() {
    if (_userPosition == null || _loadedSitters.isEmpty) return;
    setState(() {
      _loadedSitters.sort((a, b) {
        if (a.lat == null || a.lng == null) return 1;
        if (b.lat == null || b.lng == null) return -1;
        double distA = GeoService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, a.lat!, a.lng!);
        double distB = GeoService.calculateDistance(_userPosition!.latitude, _userPosition!.longitude, b.lat!, b.lng!);
        return distA.compareTo(distB);
      });
    });
  }

  Future<void> _loadMoreSitters({bool reset = false}) async {
    if (_isSyncing || (!_hasMore && !reset)) return;
    setState(() => _isSyncing = true);
    if (reset) {
      _lastDocument = null;
      _hasMore = true;
      _loadedSitters.clear(); 
    }

    try {
      Query query = FirebaseFirestore.instance.collection('sitters').orderBy('username').limit(_pageSize);
      if (_lastDocument != null) query = query.startAfterDocument(_lastDocument!);
      final snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        final box = Hive.box<SitterProfile>('sitters_box');
        List<SitterProfile> newBatch = [];
        for (var doc in snapshot.docs) {
          final sitter = SitterProfile.fromFirestore(doc);
          await box.put(sitter.uid, sitter);
          int existingIdx = _loadedSitters.indexWhere((s) => s.uid == sitter.uid);
          if (existingIdx != -1) {
            _loadedSitters[existingIdx] = sitter;
          } else {
            newBatch.add(sitter);
          }
        }
        setState(() {
          _loadedSitters.addAll(newBatch);
          _sortLoadedSitters();
          _lastDocument = snapshot.docs.last;
          if (snapshot.docs.length < _pageSize) _hasMore = false;
        });
      } else {
        setState(() => _hasMore = false);
      }
    } catch (e) {
      debugPrint("Errore sync sitters: $e");
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 25, left: 10, right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryIndigo, secondaryIndigo],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              boxShadow: [
                BoxShadow(color: primaryIndigo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        Text(
                          "ps_search_title".tr(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                        ),
                        Text(
                          "ps_search_subtitle".tr(),
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                    _isLoadingLocation 
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                      : IconButton(
                          icon: const Icon(Icons.my_location_rounded, color: Colors.white),
                          onPressed: () => _loadMoreSitters(reset: true),
                        ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "ps_search_hint".tr(),
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: primaryIndigo),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.clear_rounded, size: 20), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ""); })
                          : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FilterChipsBar(
              selectedService: _selectedService,
              onServiceSelected: (service) => setState(() => _selectedService = service),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: SitterFavoritesService().getFavoritesStream(),
              builder: (context, favSnapshot) {
                final favoriteIds = favSnapshot.data ?? [];
                final filteredSitters = _loadedSitters.where((sitter) {
                  bool mS = _selectedService.isEmpty || sitter.serviziPrezzi.keys.any((k) => k.toLowerCase().contains(_selectedService.toLowerCase()));
                  bool mQ = _searchQuery.isEmpty || sitter.username.toLowerCase().contains(_searchQuery) || sitter.citta.toLowerCase().contains(_searchQuery);
                  return mS && mQ;
                }).toList();
                
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      _loadMoreSitters();
                    }
                    return false;
                  },
                  child: filteredSitters.isEmpty && _isSyncing 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: filteredSitters.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredSitters.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final sitter = filteredSitters[index];
                          return _SitterSearchCard(
                            sitter: sitter,
                            isSaved: favoriteIds.contains(sitter.uid),
                            userPosition: _userPosition,
                            primaryIndigo: primaryIndigo,
                          );
                        },
                      ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

class _SitterSearchCard extends StatefulWidget {
  final SitterProfile sitter;
  final bool isSaved;
  final Position? userPosition;
  final Color primaryIndigo;

  const _SitterSearchCard({
    required this.sitter,
    required this.isSaved,
    this.userPosition,
    required this.primaryIndigo,
  });

  @override
  State<_SitterSearchCard> createState() => _SitterSearchCardState();
}

class _SitterSearchCardState extends State<_SitterSearchCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> gallery = [
      ...widget.sitter.fotoChiSei.where((s) => s.isNotEmpty),
      ...widget.sitter.fotoCasa.where((s) => s.isNotEmpty),
    ].toSet().toList();

    if (gallery.isEmpty && widget.sitter.fotoUrl.isNotEmpty) {
      gallery.add(widget.sitter.fotoUrl);
    }

    String dist = "";
    if (widget.userPosition != null && widget.sitter.lat != null && widget.sitter.lng != null) {
      double d = GeoService.calculateDistance(widget.userPosition!.latitude, widget.userPosition!.longitude, widget.sitter.lat!, widget.sitter.lng!);
      dist = d < 1 ? "${(d * 1000).toInt()} m" : "${d.toStringAsFixed(1)} km";
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SitterDetailScreen(sitter: widget.sitter))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: widget.primaryIndigo.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(color: widget.primaryIndigo.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 15))
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(33)),
                  child: SizedBox(
                    height: 230,
                    child: gallery.isNotEmpty
                      ? PageView.builder(
                          onPageChanged: (i) => setState(() => _currentImageIndex = i),
                          itemCount: gallery.length,
                          itemBuilder: (context, index) => Image.network(
                            gallery[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _buildDefaultBigPhoto(),
                          ),
                        )
                      : _buildDefaultBigPhoto(),
                  ),
                ),
                if (gallery.length > 1)
                  Positioned(
                    bottom: 15, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: gallery.asMap().entries.map((entry) => Container(
                        width: _currentImageIndex == entry.key ? 22 : 6, height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withOpacity(_currentImageIndex == entry.key ? 1.0 : 0.6)),
                      )).toList(),
                    ),
                  ),
                Positioned(top: 15, right: 15, child: GestureDetector(
                  onTap: () => SitterFavoritesService().toggleFavorite(widget.sitter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: widget.isSaved ? widget.primaryIndigo : Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: Icon(widget.isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: widget.isSaved ? Colors.white : widget.primaryIndigo, size: 22),
                  ),
                )),
                if (dist.isNotEmpty)
                  Positioned(
                    top: 15, left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white24)), 
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Color(0xFF6366F1), size: 14), 
                          const SizedBox(width: 6), 
                          Text(dist, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900))
                        ]
                      )
                    )
                  ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.primaryIndigo.withOpacity(0.02),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(33)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          gradient: LinearGradient(colors: [const Color(0xFFF59E0B), const Color(0xFF6366F1)]),
                        ),
                        child: CircleAvatar(
                          radius: 34, 
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 31, 
                            backgroundImage: widget.sitter.fotoUrl.isNotEmpty ? NetworkImage(widget.sitter.fotoUrl) : null, 
                            backgroundColor: Colors.grey[100], 
                            child: widget.sitter.fotoUrl.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(widget.sitter.username.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, letterSpacing: 0.5, color: Color(0xFF1E293B)))),
                                const SizedBox(width: 6), 
                                if (widget.sitter.verificato) const Icon(Icons.verified_rounded, size: 20, color: Color(0xFF6366F1))
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEDD5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFDBA74), width: 1),
                                  ),
                                  child: const Icon(Icons.pin_drop_rounded, size: 14, color: Color(0xFFD97706)),
                                ),
                                const SizedBox(width: 10),
                                Flexible(child: Text("${widget.sitter.quartiere}, ${widget.sitter.citta}".toUpperCase(), style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildRatingBadge(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // RIGA BADGE IDENTIFICATIVI (Pro, Identità, Email, Telefono)
                  _buildBadgesRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (widget.sitter.esperienzaProfessionale) ...[
            VerificationBadges.premium(label: "ps_badge_pro".tr(), size: 18),
            const SizedBox(width: 8),
          ],
          VerificationBadges.identity(verified: widget.sitter.verificato, size: 18),
          const SizedBox(width: 8),
          if (widget.sitter.email.isNotEmpty) ...[
            VerificationBadges.email(verified: true, size: 18),
            const SizedBox(width: 8),
          ],
          if (widget.sitter.telefono.isNotEmpty) ...[
            VerificationBadges.phone(verified: true, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
          const SizedBox(width: 4),
          Text(widget.sitter.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildDefaultBigPhoto() => Container(height: 230, width: double.infinity, color: const Color(0xFFF1F5F9), child: Center(child: Icon(Icons.pets_rounded, size: 60, color: widget.primaryIndigo.withOpacity(0.2))));
}
