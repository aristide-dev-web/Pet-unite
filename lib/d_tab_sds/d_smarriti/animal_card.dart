import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/d_tab_sds/d_smarriti/DettaglioAnimaleScreen.dart';
import 'package:petping/d_tab_sds/d_smarriti/ownerprofilebutton.dart';

class AnimalCard extends StatefulWidget {
  final Map<String, dynamic> animalData;
  final String currentUserId;
  final String? docId;
  final bool isCompact;

  const AnimalCard({
    super.key,
    required this.animalData,
    required this.currentUserId,
    this.docId,
    this.isCompact = false,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    const Color orangeRescue = Color(0xFFE67E22);
    const Color deepText = Color(0xFF2C3E50);

    final bool isCompact = widget.isCompact;

    final List<dynamic> images = widget.animalData['immagini'] is List
        ? widget.animalData['immagini']
        : (widget.animalData['immagine'] != null ? [widget.animalData['immagine']] : []);

    final dynamic rewardValue = widget.animalData['ricompensa'];
    final bool hasReward = rewardValue != null && rewardValue.toString().trim().isNotEmpty;

    final bool hasCicatrici = widget.animalData['haCicatrici'] ?? widget.animalData['ha_cicatrici'] ?? false;

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
                        : Container(color: Colors.orange.shade50, child: const Icon(Icons.pets_rounded, color: orangeRescue, size: 80)),
                  ),
                ),

                if (images.length > 1)
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        bool isCurrent = _currentImageIndex == index;
                        return AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), height: 7, width: isCurrent ? 22 : 7,
                          decoration: BoxDecoration(color: isCurrent ? const Color(0xFFC5A059) : Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5)));
                      }),
                    ),
                  ),

                // ✅ BOLLINO SOS SINGOLO E PULITO
                Positioned(
                  top: 15, right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), 
                    decoration: BoxDecoration(
                      color: orangeRescue, 
                      borderRadius: BorderRadius.circular(14), 
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Text(
                      "sos_badge_label".tr().toUpperCase(), 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                    ),
                  ),
                ),
                
                if (hasCicatrici)
                  Positioned(
                    top: 15, left: 15,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                      child: Row(children: [const Icon(Icons.healing_rounded, color: Colors.redAccent, size: 12), const SizedBox(width: 5), Text("sos_detail_has_scars".tr().toUpperCase(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 9))])),
                  ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(isCompact ? 16 : 20, 0, isCompact ? 16 : 20, isCompact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasReward)
                  Center(
                    child: Transform.translate(offset: const Offset(0, -12),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Text("${"sos_add_label_reward".tr().toUpperCase()}: ${rewardValue.toString().toUpperCase()}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: isCompact ? 11 : 12)))),
                  )
                else const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(widget.animalData['nome']?.toUpperCase() ?? "sos_detail_unknown_name".tr(), style: TextStyle(fontSize: isCompact ? 22 : 24, fontWeight: FontWeight.w900, color: deepText, letterSpacing: -0.5), overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 8),
                              Icon(widget.animalData['sesso'] == 'Maschio' ? Icons.male_rounded : Icons.female_rounded, size: 22, color: widget.animalData['sesso'] == 'Maschio' ? Colors.blue.shade400 : Colors.pink.shade300),
                            ],
                          ),
                          Text("${widget.animalData['razza'] ?? widget.animalData['tipo'] ?? widget.animalData['specie'] ?? "sos_detail_breed_default".tr()}", style: TextStyle(color: deepText.withOpacity(0.5), fontSize: isCompact ? 12 : 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (!isMine) OwnerProfileButton(userId: widget.animalData['uid_utente'] ?? '', currentUserId: widget.currentUserId),
                  ],
                ),

                Padding(padding: EdgeInsets.symmetric(vertical: isCompact ? 12 : 16), child: const Divider(height: 1, color: Color(0xFFF0F0F0))),

                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: isCompact ? 16 : 18, color: orangeRescue),
                    const SizedBox(width: 8),
                    Expanded(child: Text("${widget.animalData['via'] ?? ''}, ${widget.animalData['citta'] ?? "sos_detail_address_nd".tr()}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isCompact ? 13 : 14, color: deepText, fontWeight: FontWeight.w600))),
                  ],
                ),
                SizedBox(height: isCompact ? 10 : 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("sos_label_lost_on".tr(args: [widget.animalData['dataSmarrimento'] ?? widget.animalData['data_smarrimento'] ?? 'N/D']), style: TextStyle(color: Colors.grey.shade600, fontSize: isCompact ? 11 : 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DettaglioAnimaleScreen(data: widget.animalData, currentUserId: widget.currentUserId, docId: widget.docId))),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(border: Border.all(color: orangeRescue.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
                        child: Text("sos_btn_discover_more".tr(), style: TextStyle(color: orangeRescue, fontWeight: FontWeight.w900, fontSize: isCompact ? 10 : 11, letterSpacing: 0.5))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
