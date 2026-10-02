import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';
import 'package:petping/b_homes/c_datianimale/a/pet_card.dart';
import 'package:petping/petsitting/screens/search/components/sections/sitter_ui_helpers.dart';
import 'package:petping/petsitting/screens/registration/sections/serzioni/specie_selector_widget.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:petping/b_homes/c_datianimale/addati/aggiungi_animale.dart';

class StepPetSelection extends StatefulWidget {
  final List<String> selectedPetIds;
  final Function(Animale) onPetToggle;
  
  final Map<String, int> manualPets;
  final Map<String, List<String>> manualBreeds;
  final String manualSize;
  final Function(Map<String, int> pets, Map<String, List<String>> breeds, String size) onManualChanged;

  const StepPetSelection({
    super.key,
    required this.selectedPetIds,
    required this.onPetToggle,
    required this.manualPets,
    required this.manualBreeds,
    required this.manualSize,
    required this.onManualChanged,
  });

  @override
  State<StepPetSelection> createState() => _StepPetSelectionState();
}

class _StepPetSelectionState extends State<StepPetSelection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Toggle per mostrare/nascondere l'inserimento manuale in futuro
  final bool _showManualPets = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder(
      valueListenable: Hive.box<Animale>(animaliBoxName).listenable(),
      builder: (context, Box<Animale> box, _) {
        final animali = box.values.toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (animali.isNotEmpty) ...[
              _buildHeaderSection("ps_booking_pets_header".tr(), "ps_booking_pets_sub".tr()),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: animali.length,
                itemBuilder: (context, index) {
                  final pet = animali[index];
                  final isSelected = widget.selectedPetIds.contains(pet.id);

                  return GestureDetector(
                    onTap: () => widget.onPetToggle(pet),
                    child: Stack(
                      children: [
                        CartaAnimale(
                          animaleId: pet.id,
                          nome: pet.nome,
                          sesso: pet.sesso,
                          razza: pet.razza,
                          note: pet.noteGenerali,
                          temaCarta: pet.coloreDominante.isNotEmpty ? pet.coloreDominante : "nuvola_rosa",
                          fotoUrl: pet.fotoUrl,
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: isSelected ? SitterUIHelpers.primaryIndigo.withOpacity(0.2) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? SitterUIHelpers.primaryIndigo : Colors.transparent,
                              width: 4,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 10,
                            right: 10,
                            child: CircleAvatar(
                              backgroundColor: SitterUIHelpers.primaryIndigo,
                              radius: 12,
                              child: Icon(Icons.check, size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              if (_showManualPets) const Divider(),
              if (_showManualPets) const SizedBox(height: 40),
            ] else ...[
              _buildEmptyState(context),
            ],

            if (_showManualPets) ...[
              _buildHeaderSection("ps_booking_manual_header".tr(), "ps_booking_manual_sub".tr()),
              const SizedBox(height: 25),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFE0F2FE), width: 4),
                  boxShadow: [BoxShadow(color: SitterUIHelpers.primaryIndigo.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SpecieSelectorWidget(
                        title: "ps_reg_add_pet_type".tr(),
                        currentSelected: widget.manualPets.keys.toList(),
                        onSpecieChanged: (s, isSelected) {
                          final newMap = Map<String, int>.from(widget.manualPets);
                          final newBreeds = Map<String, List<String>>.from(widget.manualBreeds);
                          if (isSelected) {
                            newMap[s] = 1;
                            newBreeds[s] = [""];
                          } else {
                            newMap.remove(s);
                            newBreeds.remove(s);
                          }
                          widget.onManualChanged(newMap, newBreeds, widget.manualSize);
                        },
                      ),
                      
                      if (widget.manualPets.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        _buildSubSection("ps_booking_manual_qty_breed".tr(), Column(
                          children: widget.manualPets.entries.map((entry) => _buildSpecieSection(context, entry.key, entry.value)).toList(),
                        )),

                        const SizedBox(height: 10),

                        _buildSubSection("ps_booking_manual_size".tr(), _buildSizeSelector()),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Icon(Icons.pets_rounded, size: 80, color: SitterUIHelpers.primaryIndigo.withOpacity(0.2)),
        const SizedBox(height: 25),
        Text(
          "booking_empty_pets_title".tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: SitterUIHelpers.textColor),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "booking_empty_pets_sub".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: SitterUIHelpers.secondaryTextColor, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ),
        const SizedBox(height: 35),
        _buildAddPetButton(context),
      ],
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AggiungiAnimale())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF64B5B4), Color(0xFF4DB6AC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64B5B4).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline_rounded, size: 22, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'booking_empty_pets_btn'.tr().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 24, decoration: BoxDecoration(color: SitterUIHelpers.primaryIndigo, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: SitterUIHelpers.textColor)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(color: SitterUIHelpers.secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)
        ),
      ],
    );
  }

  Widget _buildSubSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildSpecieSection(BuildContext context, String specie, int quantity) {
    final breeds = widget.manualBreeds[specie] ?? List.filled(quantity, "");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuantityRow(specie, quantity),
        const SizedBox(height: 10),
        ...List.generate(quantity, (index) => Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: _buildRazzaAutocomplete(context, specie, index, breeds.length > index ? breeds[index] : ""),
        )),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildQuantityRow(String specie, int quantity) {
    final opzione = SpecieSelectorWidget.opzioniSpecie.firstWhere((o) => o['label'] == specie, orElse: () => {'emoji': '🐾'});
    final String labelKey;
    switch(specie) {
      case 'Cani': labelKey = 'ps_specie_dogs'; break;
      case 'Gatti': labelKey = 'ps_specie_cats'; break;
      case 'Volatili': labelKey = 'ps_specie_birds'; break;
      case 'Pesci': labelKey = 'ps_specie_fish'; break;
      case 'Tartarughe': labelKey = 'ps_specie_turtles'; break;
      case 'Rettili': labelKey = 'ps_specie_reptiles'; break;
      case 'Insetti': labelKey = 'ps_specie_insects'; break;
      case 'Esotici': labelKey = 'ps_specie_exotic'; break;
      case 'Conigli': labelKey = 'ps_specie_rabbits'; break;
      case 'Criceti': labelKey = 'ps_specie_hamsters'; break;
      default: labelKey = 'ps_specie_other';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Text(opzione['emoji'] as String, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(labelKey.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SitterUIHelpers.textColor)),
          ),
          Row(
            children: [
              _buildQtyBtn(Icons.remove, () {
                if (quantity > 1) {
                  final newMap = Map<String, int>.from(widget.manualPets);
                  final newBreeds = Map<String, List<String>>.from(widget.manualBreeds);
                  newMap[specie] = quantity - 1;
                  if (newBreeds[specie] != null && newBreeds[specie]!.isNotEmpty) {
                    newBreeds[specie]!.removeLast();
                  }
                  widget.onManualChanged(newMap, newBreeds, widget.manualSize);
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text("$quantity", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: SitterUIHelpers.primaryIndigo)),
              ),
              _buildQtyBtn(Icons.add, () {
                final newMap = Map<String, int>.from(widget.manualPets);
                final newBreeds = Map<String, List<String>>.from(widget.manualBreeds);
                newMap[specie] = quantity + 1;
                newBreeds[specie] = List<String>.from(newBreeds[specie] ?? [])..add("");
                widget.onManualChanged(newMap, newBreeds, widget.manualSize);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: SitterUIHelpers.primaryIndigo.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: SitterUIHelpers.primaryIndigo),
      ),
    );
  }

  Widget _buildRazzaAutocomplete(BuildContext context, String specie, int index, String currentVal) {
    final String mappingSpecie;
    switch(specie) {
      case 'Cani': mappingSpecie = 'Cane'; break;
      case 'Gatti': mappingSpecie = 'Gatto'; break;
      case 'Volatili': mappingSpecie = 'Uccello'; break;
      case 'Pesci': mappingSpecie = 'Pesce'; break;
      case 'Tartarughe': mappingSpecie = 'Tartaruga'; break;
      case 'Rettili': mappingSpecie = 'Serpente'; break;
      case 'Insetti': mappingSpecie = 'Ragno'; break;
      case 'Esotici': mappingSpecie = 'Riccio'; break;
      case 'Conigli': mappingSpecie = 'Coniglio'; break;
      case 'Criceti': mappingSpecie = 'Criceto'; break;
      default: mappingSpecie = specie;
    }

    final List<String> options = razzePerSpecie[mappingSpecie] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${"ps_reg_rev_excluded_breeds".tr().toUpperCase()} ${specie.toUpperCase()} #${index + 1}", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 5),
        Autocomplete<String>(
          key: ValueKey('auto_${specie}_$index'),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') return options;
            return options.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            final newBreeds = Map<String, List<String>>.from(widget.manualBreeds);
            final list = List<String>.from(newBreeds[specie] ?? []);
            if (list.length > index) list[index] = selection;
            newBreeds[specie] = list;
            widget.onManualChanged(widget.manualPets, newBreeds, widget.manualSize);
            FocusScope.of(context).unfocus();
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            if (textEditingController.text != currentVal && !focusNode.hasFocus) {
              textEditingController.text = currentVal;
            }
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (val) {
                final newBreeds = Map<String, List<String>>.from(widget.manualBreeds);
                final list = List<String>.from(newBreeds[specie] ?? []);
                if (list.length > index) list[index] = val;
                newBreeds[specie] = list;
                widget.onManualChanged(widget.manualPets, newBreeds, widget.manualSize);
              },
              decoration: InputDecoration(
                hintText: "ps_reg_rest_breeds_hint".tr(),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                suffixIcon: const Icon(Icons.search, size: 16, color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(option, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SitterUIHelpers.textColor)),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
    final Map<String, Map<String, dynamic>> taglieInfo = {
      'XS': {'weight': '0-5kg', 'icon': 'assets/images/xs.png', 'imgSize': 20.0},
      'S': {'weight': '5-10kg', 'icon': 'assets/images/s.png', 'imgSize': 28.0},
      'M': {'weight': '10-25kg', 'icon': 'assets/images/media.png', 'imgSize': 38.0},
      'L': {'weight': '25-45kg', 'icon': 'assets/images/grande.png', 'imgSize': 48.0},
      'XL': {'weight': '45kg+', 'icon': 'assets/images/xl.png', 'imgSize': 46.0},
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: sizes.map((key) {
        final info = taglieInfo[key]!;
        final isSel = widget.manualSize == key;
        const Color color = SitterUIHelpers.primaryIndigo;

        return GestureDetector(
          onTap: () {
            final newSize = isSel ? "" : key;
            widget.onManualChanged(widget.manualPets, widget.manualBreeds, newSize);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? color.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSel ? color : Colors.grey.shade200, width: 1.5),
            ),
            child: Column(
              children: [
                Image.asset(info['icon'], height: (info['imgSize'] as double) * 0.8, fit: BoxFit.contain),
                const SizedBox(height: 4),
                Text(key, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isSel ? color : SitterUIHelpers.textColor)),
                Text(info['weight'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSel ? color : Colors.grey)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
