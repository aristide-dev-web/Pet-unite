import 'package:flutter/material.dart';
import 'package:petping/tipologie/selector/colore.dart';
import 'package:petping/tipologie/selector/occhi.dart';
import 'package:petping/tipologie/selector/coda_orecchie.dart';
import 'package:petping/tipologie/tipologia.dart';
import 'package:petping/tipologie/selector/pelo.dart';
import 'package:petping/d_tab_sds/d_smarriti/a_home/category_selector.dart';

class FiltraAnimali extends StatefulWidget {
  final TextEditingController nomeController;
  final TextEditingController razzaController;
  final TextEditingController coloreDominanteController;
  final TextEditingController coloreSecondarioController;
  final TextEditingController occhiColoreController;
  final TextEditingController orecchieGrandezzaController;
  final TextEditingController codaGrandezzaController;
  final TextEditingController microchipController;
  
  final String? selectedSesso;
  final bool? selectedCicatrici;
  final String? selectedTipo;
  
  final Function(String?) onSessoChanged;
  final Function(bool?) onCicatriciChanged;
  final Function(String?) onTipoChanged;
  
  final VoidCallback onFiltra;

  const FiltraAnimali({
    super.key,
    required this.nomeController,
    required this.razzaController,
    required this.coloreDominanteController,
    required this.coloreSecondarioController,
    required this.occhiColoreController,
    required this.orecchieGrandezzaController,
    required this.codaGrandezzaController,
    required this.microchipController,
    required this.onSessoChanged,
    required this.onCicatriciChanged,
    required this.onTipoChanged,
    required this.onFiltra,
    this.selectedSesso,
    this.selectedCicatrici,
    this.selectedTipo,
  });

  @override
  State<FiltraAnimali> createState() => _FiltraAnimaliState();
}

class _FiltraAnimaliState extends State<FiltraAnimali> {
  static const Color darkBrown = Color(0xFF4E342E);
  static const Color vintageGold = Color(0xFFC5A059);
  static const Color orangeRescue = Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.auto_awesome_motion_rounded, color: darkBrown, size: 18),
              SizedBox(width: 8),
              Text("RICERCA INTELLIGENTE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: darkBrown, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 15),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMicrochipHighlight(),
                  
                  _buildTextDivider("OPPURE CERCA PER CARATTERISTICHE"),

                  _filterLabel("CATEGORIA", Icons.pets_rounded),
                  
                  CategorySelector(
                    selectedSpecies: widget.selectedTipo,
                    onSelected: (tipo) {
                      widget.onTipoChanged(tipo);
                      widget.razzaController.clear();
                    },
                    showAll: true,
                    activeColor: orangeRescue,
                    isSOS: true, // Attivato filtro SOS
                  ),
                  
                  const SizedBox(height: 10),
                  _filterLabel("GENERE", Icons.wc_rounded),
                  Row(
                    children: [
                      _sessoBtn('MASCHIO', Icons.male_rounded, widget.selectedSesso == 'Maschio', Colors.blue.shade400, () => widget.onSessoChanged(widget.selectedSesso == 'Maschio' ? null : 'Maschio')),
                      const SizedBox(width: 12),
                      _sessoBtn('FEMMINA', Icons.female_rounded, widget.selectedSesso == 'Femmina', Colors.pink.shade300, () => widget.onSessoChanged(widget.selectedSesso == 'Femmina' ? null : 'Femmina')),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  _filterLabel("IDENTITÀ", Icons.assignment_ind_rounded),
                  _miniLabel("NOME DEL SOGGETTO"),
                  _buildModernInput("Es: Rex, Fido...", widget.nomeController, Icons.badge_rounded),
                  const SizedBox(height: 5),
                  _miniLabel("RAZZA PROBABILE"),
                  _buildSelectorWrapper(
                    _buildRazzaSelector(),
                  ),

                  const SizedBox(height: 10),
                  _filterLabel("ESTETICA E SEGNI FISSI", Icons.auto_fix_high_rounded),
                  _miniLabel("PRESENZA CICATRICI?"),
                  Row(
                    children: [
                      _cicatriciBtn("SÌ", widget.selectedCicatrici == true, () => widget.onCicatriciChanged(widget.selectedCicatrici == true ? null : true)),
                      const SizedBox(width: 12),
                      _cicatriciBtn("NO", widget.selectedCicatrici == false, () => widget.onCicatriciChanged(widget.selectedCicatrici == false ? null : false)),
                    ],
                  ),
                  
                  _miniLabel("COLORE OCCHI"),
                  _buildSelectorWrapper(
                    OcchiColoreSelector(controller: widget.occhiColoreController, label: "Scegli colore", isDark: false),
                  ),
                  
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("COLORE DOM."),
                            _buildSelectorWrapper(
                              ColoreSelector(controller: widget.coloreDominanteController, label: "Dominante", isDark: false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("COLORE SEC."),
                            _buildSelectorWrapper(
                              ColoreSelector(controller: widget.coloreSecondarioController, label: "Secondario", isDark: false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  _filterLabel("CARATTERISTICHE FISICHE", Icons.fitness_center_rounded),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("ORECCHIE"),
                            _buildSelectorWrapper(
                              OrecchieGrandezzaSelector(controller: widget.orecchieGrandezzaController, isDark: false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _miniLabel("CODA"),
                            _buildSelectorWrapper(
                              CodaGrandezzaSelector(controller: widget.codaGrandezzaController, isDark: false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  // --- HELPERS UI ---

  Widget _buildRazzaSelector() {
    final List<String> options = razzePerSpecie[widget.selectedTipo] ?? [];
    if (widget.selectedTipo == null) return const Center(child: Text("Scegli prima la categoria", style: TextStyle(color: Colors.grey, fontSize: 13)));
    if (options.isEmpty) return const Center(child: Text("Nessuna razza in elenco", style: TextStyle(color: Colors.grey, fontSize: 13)));

    return CustomModernSelector(
      controller: widget.razzaController,
      options: options,
      hint: "Scegli la razza",
      isDark: false,
    );
  }

  Widget _buildMicrochipHighlight() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: orangeRescue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: orangeRescue.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fingerprint_rounded, color: orangeRescue, size: 20),
              const SizedBox(width: 8),
              const Text("IDENTIFICAZIONE UNIVOCA (100%)", 
                style: TextStyle(color: orangeRescue, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.microchipController,
            keyboardType: TextInputType.number,
            maxLength: 15,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBrown, letterSpacing: 2),
            decoration: InputDecoration(
              hintText: "Inserisci Microchip (15 cifre)",
              hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 0, fontSize: 13, fontWeight: FontWeight.normal),
              counterText: "",
              prefixIcon: const Icon(Icons.qr_code_scanner_rounded, color: orangeRescue),
              filled: true, 
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: orangeRescue.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: orangeRescue, width: 2)),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Dato certo: se inserito, ignorerà gli altri filtri per darti il match esatto.", 
            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTextDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        ],
      ),
    );
  }

  Widget _filterLabel(String text, [IconData? icon]) => Container(
    margin: const EdgeInsets.only(bottom: 12, top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: vintageGold.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: vintageGold.withOpacity(0.2), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: vintageGold),
          const SizedBox(width: 8),
        ],
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: vintageGold, letterSpacing: 1.5)),
      ],
    ),
  );

  Widget _miniLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10), 
    child: Text(text, style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5))
  );

  Widget _buildSelectorWrapper(Widget selector) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
            titleMedium: const TextStyle(color: darkBrown, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        child: DropdownButtonHideUnderline(child: selector),
      ),
    );
  }

  Widget _sessoBtn(String label, IconData icon, bool isSelected, Color activeColor, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withOpacity(0.15) : Colors.grey[50], 
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: isSelected ? activeColor : Colors.grey[200]!, width: 2)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Icon(icon, size: 18, color: isSelected ? activeColor : darkBrown.withOpacity(0.4)), 
                const SizedBox(width: 8), 
                Text(label, style: TextStyle(color: isSelected ? activeColor : darkBrown.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12))
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _cicatriciBtn(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? vintageGold.withOpacity(0.2) : Colors.grey[50], 
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: isSelected ? vintageGold : Colors.grey[200]!, width: 2)
            ),
            child: Center(child: Text(label, style: TextStyle(color: isSelected ? darkBrown : darkBrown.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 13))),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput(String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkBrown),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: vintageGold, size: 18),
        filled: true, fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: vintageGold, width: 1.5)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              widget.nomeController.clear(); 
              widget.razzaController.clear(); 
              widget.coloreDominanteController.clear(); 
              widget.coloreSecondarioController.clear();
              widget.occhiColoreController.clear(); 
              widget.orecchieGrandezzaController.clear(); 
              widget.codaGrandezzaController.clear(); 
              widget.microchipController.clear();
              widget.onSessoChanged(null); 
              widget.onCicatriciChanged(null); 
              widget.onTipoChanged(null);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
              side: const BorderSide(color: Colors.grey)
            ),
            child: const Text("PULISCI", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.onFiltra,
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeRescue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("FILTRA ORA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }
}
