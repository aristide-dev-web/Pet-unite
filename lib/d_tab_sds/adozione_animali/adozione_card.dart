import 'package:flutter/material.dart';
import 'package:petping/d_tab_sds/d_smarriti/DettaglioAnimaleScreen.dart';
import 'package:petping/d_tab_sds/d_smarriti/ownerprofilebutton.dart';

class AdozioneCard extends StatefulWidget {
  final Map<String, dynamic> animalData;
  final String currentUserId;
  final String? docId;
  final bool isCompact;

  const AdozioneCard({
    super.key,
    required this.animalData,
    required this.currentUserId,
    this.docId,
    this.isCompact = false,
  });

  @override
  State<AdozioneCard> createState() => _AdozioneCardState();
}

class _AdozioneCardState extends State<AdozioneCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    const Color greenHope = Color(0xFF27AE60);
    const Color deepText = Color(0xFF2C3E50);

    final bool isCompact = widget.isCompact;
    final List<dynamic> images = widget.animalData['immagini'] is List
        ? widget.animalData['immagini']
        : (widget.animalData['immagine'] != null ? [widget.animalData['immagine']] : []);

    final bool isMine = widget.currentUserId == widget.animalData['uid_utente'];

    return Container(
      margin: isCompact ? EdgeInsets.zero : const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 20 : 28),
        boxShadow: isCompact ? null : [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DettaglioAnimaleScreen(data: widget.animalData, currentUserId: widget.currentUserId, docId: widget.docId)));
            },
            child: Stack(
              children: [
                SizedBox(
                  height: isCompact ? 220 : 280,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(isCompact ? 20 : 28)),
                    child: images.isNotEmpty
                        ? PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (index) => setState(() => _currentImageIndex = index),
                            itemBuilder: (context, index) {
                              return Image.network(images[index], fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(color: Colors.grey.shade100, child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 50)));
                            },
                          )
                        : Container(color: Colors.green.shade50, child: const Icon(Icons.pets_rounded, color: greenHope, size: 80)),
                  ),
                ),

                if (images.length > 1)
                  Positioned(
                    bottom: 15, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        bool isCurrent = _currentImageIndex == index;
                        return AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), height: 7, width: isCurrent ? 22 : 7,
                          decoration: BoxDecoration(color: isCurrent ? greenHope : Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10)));
                      }),
                    ),
                  ),

                // ✅ BADGE ADOZIONE SINGOLO
                Positioned(
                  top: 15, right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), 
                    decoration: BoxDecoration(
                      color: greenHope, 
                      borderRadius: BorderRadius.circular(14), 
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Text(
                      "ADOZIONE", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(isCompact ? 16 : 20, 16, isCompact ? 16 : 20, isCompact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(widget.animalData['nome']?.toUpperCase() ?? 'CUCCIOLO', style: TextStyle(fontSize: isCompact ? 22 : 24, fontWeight: FontWeight.w900, color: deepText), overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 8),
                              Icon(widget.animalData['sesso'] == 'Maschio' ? Icons.male_rounded : Icons.female_rounded, size: 20, color: widget.animalData['sesso'] == 'Maschio' ? Colors.blue : Colors.pink),
                            ],
                          ),
                          Text("${widget.animalData['razza'] ?? widget.animalData['tipo'] ?? 'Razza mista'} • ${widget.animalData['eta'] ?? 'Età N/D'}", style: TextStyle(color: deepText.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (!isMine) OwnerProfileButton(userId: widget.animalData['uid_utente'] ?? '', currentUserId: widget.currentUserId),
                  ],
                ),

                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFF0F0F0))),

                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: greenHope),
                    const SizedBox(width: 8),
                    Expanded(child: Text("${widget.animalData['via'] ?? ''}, ${widget.animalData['citta'] ?? 'Zona ignota'}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: deepText, fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DettaglioAnimaleScreen(data: widget.animalData, currentUserId: widget.currentUserId, docId: widget.docId))),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: greenHope.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: greenHope.withOpacity(0.2)),
                    ),
                    child: const Center(
                      child: Text("SCOPRI LA SUA STORIA", style: TextStyle(color: greenHope, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
