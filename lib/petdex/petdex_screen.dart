import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petping/petdex/pet_card_model.dart';
import 'package:petping/petdex/petdex_service.dart';
import 'package:petping/petdex/data/petdex_registry.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:petping/ai/ai_chat_screen.dart';
import 'package:petping/utils/image_optimizer.dart';

class PetDexScreen extends StatefulWidget {
  const PetDexScreen({super.key});

  @override
  State<PetDexScreen> createState() => _PetDexScreenState();
}

class _PetDexScreenState extends State<PetDexScreen> with SingleTickerProviderStateMixin {
  final PetDexService _petDexService = PetDexService();
  final ImagePicker _picker = ImagePicker();
  List<PetCardModel> _allCards = [];
  List<PetCardModel> _filteredCards = [];
  bool _isLoading = true;
  String _selectedCategory = "Tutti";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _petDexService.init();
    final cards = _petDexService.getAllCards();
    final categories = ["Tutti", ...PetDexRegistry.getCategories()];
    
    setState(() {
      _allCards = cards;
      _filteredCards = cards;
      _isLoading = false;
      _tabController = TabController(length: categories.length, vsync: this);
    });
  }

  void _filterCards(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == "Tutti") {
        _filteredCards = _allCards;
      } else {
        _filteredCards = _allCards.where((c) => c.species == category).toList();
      }
    });
  }

  Future<void> _scanNewPet() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 20),
              Text("PET-SCAN IN CORSO...", 
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    // 🔥 Ottimizzazione Immagine: riduce il peso al massimo per velocità istantanea
    File optimizedFile = await ImageOptimizer.optimize(
      file: File(image.path),
      maxWidth: 512, // Formato ultra-veloce per AI
      quality: 75,   // Massima compressione senza perdere dettagli chiave
    );

    Uint8List bytes = await optimizedFile.readAsBytes();
    final result = await _petDexService.scanAndMatch(bytes);

    Navigator.pop(context);

    if (result != null) {
      _showDiscoveryDialog(result);
      _loadData();
    } else {
      // Notifica all'utente che l'AI non è sicura
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("L'AI NON È SICURA. RITENTA LA FOTO 📸",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deletePet(num cardId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ELIMINA CATTURA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Vuoi davvero eliminare questa foto? Se è un animale extra, sparirà dall'album.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ANNULLA", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ELIMINA", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _petDexService.deletePet(cardId);
      _loadData();
    }
  }

  void _showDiscoveryDialog(PetCardModel card) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Discovery",
      pageBuilder: (context, anim1, anim2) => _DiscoveryDialog(
        card: card,
        onDelete: () {
          Navigator.pop(context);
          _deletePet(card.id);
        },
        onRetake: () {
          Navigator.pop(context);
          _scanNewPet();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final categories = ["Tutti", ...PetDexRegistry.getCategories()];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("PETDEX", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3)),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: categories.map((cat) => _buildCategoryChip(cat)).toList(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _PetCardWidget(
                  card: _filteredCards[index],
                  onTap: () {
                    if (_filteredCards[index].isCaptured) {
                      _showDiscoveryDialog(_filteredCards[index]);
                    }
                  },
                ),
                childCount: _filteredCards.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanNewPet,
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
        label: const Text("CATTURA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => _filterCards(category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.amber : Colors.white24),
        ),
        child: Text(
          category.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    int discovered = _allCards.where((c) => c.isCaptured).length;
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statColumn("COLLEZIONE", "$discovered / ${_allCards.length}"),
          Container(width: 1, height: 40, color: Colors.white10),
          _statColumn("RANGO", _getRank(discovered), color: Colors.amber),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, {Color color = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }

  String _getRank(int count) {
    if (count < 5) return "NOVIZIO";
    if (count < 20) return "ESPERTO";
    if (count < 50) return "MAESTRO";
    return "LEGGENDA";
  }
}

class _DiscoveryDialog extends StatefulWidget {
  final PetCardModel card;
  final VoidCallback? onDelete;
  final VoidCallback? onRetake;

  const _DiscoveryDialog({
    required this.card,
    this.onDelete,
    this.onRetake,
  });

  @override
  State<_DiscoveryDialog> createState() => _DiscoveryDialogState();
}

class _DiscoveryDialogState extends State<_DiscoveryDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color rarityColor = _getRarityColor(widget.card.rarity);

    return Material(
      color: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.card.rarity.index >= PetRarity.rare.index ? "RARO TROVATO!" : "NUOVA SCOPERTA!",
                    style: TextStyle(
                      color: rarityColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: rarityColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 5)
                        ],
                      ),
                      child: _PetCardWidget(card: widget.card, isFullView: true),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 220,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                            elevation: 8,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AIChatScreen(
                                  initialMessage: "Parlami di questo animale: ${widget.card.name} (${widget.card.species}). Raccontami qualche curiosità interessante!",
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome, size: 20),
                          label: const Text("CHIEDI ALL'AI", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                        ),
                      ),
                      if (widget.onRetake != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.05),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                              side: const BorderSide(color: Colors.white24, width: 1.5),
                            ),
                            onPressed: widget.onRetake,
                            icon: const Icon(Icons.camera_alt_outlined, size: 20),
                            label: const Text("RIFAI FOTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 25),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CHIUDI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ],
              ),
            ),
          ),
          if (widget.onDelete != null)
            Positioned(
              top: 50,
              right: 25,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 30),
                  tooltip: "Elimina cattura",
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRarityColor(PetRarity rarity) {
    switch (rarity) {
      case PetRarity.common: return Colors.blueGrey;
      case PetRarity.uncommon: return Colors.greenAccent;
      case PetRarity.rare: return Colors.blueAccent;
      case PetRarity.epic: return Colors.purpleAccent;
      case PetRarity.legendary: return Colors.orangeAccent;
      case PetRarity.mythic: return Colors.redAccent;
    }
  }
}

class _PetCardWidget extends StatefulWidget {
  final PetCardModel card;
  final bool isFullView;
  final VoidCallback? onTap;

  const _PetCardWidget({required this.card, this.isFullView = false, this.onTap});

  @override
  State<_PetCardWidget> createState() => _PetCardWidgetState();
}

class _PetCardWidgetState extends State<_PetCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color rarityColor = _getRarityColor(widget.card.rarity);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.card.isCaptured ? rarityColor : Colors.white12,
            width: widget.isFullView ? 4 : 2,
          ),
          boxShadow: widget.card.isCaptured ? [
            BoxShadow(color: rarityColor.withOpacity(0.2), blurRadius: 15, spreadRadius: 5)
          ] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.card.isCaptured && widget.card.capturedImagePath != null)
                Image.file(File(widget.card.capturedImagePath!), fit: BoxFit.cover)
              else
                Container(
                  color: const Color(0xFF151515),
                  child: Icon(Icons.pets, size: widget.isFullView ? 100 : 40, color: Colors.white.withOpacity(0.05)),
                ),
              
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#${widget.card.id.toString().padLeft(4, '0')}",
                      style: TextStyle(
                        color: rarityColor.withOpacity(0.8), 
                        fontSize: widget.isFullView ? 18 : 10,
                        fontWeight: FontWeight.w900
                      ),
                    ),
                    Text(
                      widget.card.isCaptured ? widget.card.name.toUpperCase() : "SCONOSCIUTO",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: widget.isFullView ? 26 : 12, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: widget.isFullView ? 1 : 0,
                      ),
                    ),
                    if (widget.isFullView) ...[
                      const SizedBox(height: 15),
                      _infoBadge(widget.card.species, Colors.white12),
                      const SizedBox(height: 8),
                      _infoBadge(widget.card.rarity.name.toUpperCase(), rarityColor.withOpacity(0.2), textColor: rarityColor),
                      const SizedBox(height: 20),
                      Text(
                        widget.card.description ?? "",
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rarityColor.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AIChatScreen(
                                  initialMessage: "Parlami dell'animale '${widget.card.name}' (${widget.card.species}). Quali sono le sue caratteristiche principali e dove vive?",
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text("INFO DALL'AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              
              // Effetto "Olografico Shimmer" per le carte rare o superiori
              if (widget.card.isCaptured && widget.card.rarity.index >= PetRarity.rare.index)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-2.0 + _shimmerController.value * 4, -1.0),
                            end: Alignment(-1.0 + _shimmerController.value * 4, 1.0),
                            colors: [
                              Colors.transparent,
                              rarityColor.withOpacity(0.1),
                              Colors.white.withOpacity(0.2),
                              rarityColor.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(String text, Color bg, {Color textColor = Colors.white70}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Color _getRarityColor(PetRarity rarity) {
    switch (rarity) {
      case PetRarity.common: return Colors.blueGrey;
      case PetRarity.uncommon: return Colors.greenAccent;
      case PetRarity.rare: return Colors.blueAccent;
      case PetRarity.epic: return Colors.purpleAccent;
      case PetRarity.legendary: return Colors.orangeAccent;
      case PetRarity.mythic: return Colors.redAccent;
    }
  }
}
