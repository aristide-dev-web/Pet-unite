import 'package:flutter/material.dart';

class CartaAnimale extends StatelessWidget {
  final String? animaleId; 
  final String nome;
  final String sesso;
  final String razza;
  final String note;
  final String temaCarta;
  final String? fotoUrl;
  final String? day;
  final String? month;
  final String? year;

  const CartaAnimale({
    super.key,
    this.animaleId,
    required this.nome,
    required this.sesso,
    required this.razza,
    required this.note,
    required this.temaCarta,
    this.fotoUrl,
    this.day,
    this.month,
    this.year,
  });

  // Colore di sfondo dei pannelli (Pastello molto chiaro)
  Color _getPastelColor() {
    switch (temaCarta) {
      case "vortice_verde":
      case "verde":
      case "foresta_incantata":
        return const Color(0xFFE8F5E9); 
      case "vortice_blu":
      case "oceano_cristallino":
      case "aurora_artica":
      case "ghiaccio":
      case "leopardato_azzurro":
        return const Color(0xFFE1F5FE); 
      case "vortice_viola":
      case "galassia":
        return const Color(0xFFF3E5F5); 
      case "nuvola_rosa":
      case "fenicottero":
      case "rosa_shocking":
      case "pink_leopard":
        return const Color(0xFFFCE4EC); 
      case "deserto_seta":
      case "oro":
      case "beije":
        return const Color(0xFFFFFDE7); 
      case "vortice_marrone":
      case "terra_nobile":
      case "marrone":
      case "leopardato":
      case "leopardato2":
      case "tigrato":
        return const Color(0xFFEFEBE9); 
      case "energia_solare":
      case "arancione":
        return const Color(0xFFFFF3E0); 
      case "neon":
      case "verde_acqua":
        return const Color(0xFFE0F7FA); 
      default:
        return Colors.white;
    }
  }

  // Colore dei bordini personalizzato per ogni tema
  Color _getBorderColor() {
    switch (temaCarta) {
      case "vortice_verde":
      case "verde":
      case "foresta_incantata":
        return const Color(0xFF66BB6A); 
      case "vortice_blu":
      case "oceano_cristallino":
      case "aurora_artica":
      case "ghiaccio":
      case "leopardato_azzurro":
        return const Color(0xFF81D4FA); 
      case "vortice_viola":
      case "galassia":
        return const Color(0xFFAB47BC); 
      case "nuvola_rosa":
      case "fenicottero":
      case "rosa_shocking":
      case "pink_leopard":
        return const Color(0xFFF06292); 
      case "deserto_seta":
      case "oro":
      case "beije":
        return const Color(0xFFFFD54F); 
      case "vortice_marrone":
      case "terra_nobile":
      case "marrone":
      case "leopardato":
      case "leopardato2":
      case "tigrato":
        return const Color(0xFF8D6E63); 
      case "energia_solare":
      case "arancione":
        return const Color(0xFFFFA726); 
      case "neon":
      case "verde_acqua":
        return const Color(0xFF26C6DA); 
      default:
        return Colors.white70;
    }
  }

  TextStyle _getTextStyle({double fontSize = 16}) {
    return TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: fontSize,
      color: const Color(0xFF1A1A1A), 
      letterSpacing: 1.3,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.12),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  Decoration _getBackground() {
    final Color borderCol = _getBorderColor().withOpacity(0.4);
    final List<BoxShadow> softShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.14),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];

    BoxDecoration base(Gradient grad) => BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: grad,
      border: Border.all(color: borderCol, width: 2.5),
      boxShadow: softShadow,
    );

    switch (temaCarta) {
      case "ghiaccio":
        return base(const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC), Color(0xFF81D4FA)]
        ));
      case "vortice_verde":
        return base(const RadialGradient(center: Alignment(-0.5, -0.6), radius: 1.5, colors: [Color(0xFFCCFF90), Color(0xFF76FF03), Color(0xFF64DD17)]));
      case "vortice_marrone":
        return base(const RadialGradient(center: Alignment(0.4, -0.3), radius: 1.6, colors: [Color(0xFF8D6E63), Color(0xFF5D4037), Color(0xFF3E2723)]));
      case "vortice_blu":
        return base(const RadialGradient(center: Alignment(-0.2, 0.5), radius: 1.4, colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)]));
      case "vortice_viola":
        return base(const RadialGradient(center: Alignment(0.6, 0.6), radius: 1.5, colors: [Color(0xFFE1BEE7), Color(0xFFBA68C8), Color(0xFF7B1FA2)]));
      case "nuvola_rosa":
        return base(const LinearGradient(colors: [Color(0xFFFFE0E9), Color(0xFFFFB2C5)]));
      case "fenicottero":
        return base(const LinearGradient(colors: [Color(0xFFFF80AB), Color(0xFFF06292)]));
      case "rosa_shocking":
        return base(const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFC2185B)]));
      case "aurora_artica":
        return base(const LinearGradient(colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)]));
      case "foresta_incantata":
        return base(const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]));
      case "oceano_cristallino":
        return base(const LinearGradient(colors: [Color(0xFF006064), Color(0xFF00ACC1)]));
      case "deserto_seta":
        return base(const LinearGradient(colors: [Color(0xFFF5F5DC), Color(0xFFFFF9C4)]));
      case "terra_nobile":
        return base(const LinearGradient(colors: [Color(0xFF3E2723), Color(0xFF5D4037)]));
      case "energia_solare":
        return base(const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFFAB40)]));
      case "galassia":
        return base(const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF4A148C), Color(0xFF880E4F)]));
      case "oro":
        return base(const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFFFD700)]));
      case "neon":
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF0A0A0A),
          border: Border.all(color: _getBorderColor(), width: 2.5),
          boxShadow: softShadow,
        );
      default:
        // Gestione estensioni diverse per i nuovi file
        String ext = "png";
        if (temaCarta == "tigrato" || temaCarta == "leopardato2" || temaCarta == "leopardato_azzurro") ext = "jpeg";
        if (temaCarta == "leopardato" || temaCarta == "pink_leopard") ext = "jpg";
        
        // Mappatura nomi file corretta per quelli con spazi o nomi diversi
        String fileName = temaCarta;
        if (temaCarta == "leopardato_azzurro") fileName = "leopardato azzurro";
        if (temaCarta == "pink_leopard") fileName = "pink-leopard-print-q7955099k8tt6psh";

        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage("assets/petcard/$fileName.$ext"), 
            fit: BoxFit.cover,
            onError: (e, s) => {}, 
          ),
          color: const Color(0xFFE0E0E0),
          border: Border.all(color: borderCol, width: 2.5),
          boxShadow: softShadow,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMaschio = sesso.toLowerCase() == 'maschio';
    final iconaSesso = isMaschio ? Icons.male : Icons.female;
    final textStyle = _getTextStyle();

    final Color panelColor = _getPastelColor().withOpacity(0.9);
    final Color customBorderColor = _getBorderColor();

    return Container(
      decoration: _getBackground(),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Foto CIRCOLARE (SOPRA)
          Expanded(
            child: Hero(
              tag: 'pet_image_${animaleId ?? nome}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: customBorderColor.withOpacity(0.9), width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  image: (fotoUrl != null && fotoUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(fotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (fotoUrl == null || fotoUrl!.isEmpty)
                    ? const Center(child: Icon(Icons.pets, size: 45, color: Colors.white))
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Label: Nome con stile "Premium" e Sesso a destra
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: panelColor,
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: customBorderColor.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                const Opacity(
                  opacity: 0,
                  child: Icon(Icons.male, size: 18),
                ),
                Expanded(
                  child: Text(
                    nome.toUpperCase(),
                    style: textStyle.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Icon(
                  iconaSesso, 
                  size: 20, 
                  color: isMaschio ? Colors.blue.shade800 : Colors.pink.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
