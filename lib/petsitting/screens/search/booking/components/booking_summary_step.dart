import 'package:flutter/material.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../b_homes/c_datianimale/diariopet/back_diario.dart';
import '../../../../../b_homes/c_datianimale/a/pet_card.dart';
import '../../components/sections/sitter_ui_helpers.dart';

class BookingSummaryStep extends StatefulWidget {
  final SitterProfile sitter;
  final DateTime? startDate;
  final DateTime? endDate;
  final String service;
  final int petCount;
  final TimeOfDay checkIn;
  final TimeOfDay checkOut;
  final String note;
  final double totalPrice;
  final List<Animale> selectedPets;
  final Map<String, dynamic>? manualPetData; 
  final String userNotes;
  final String userLocation; 
  final Function(String) onUserNotesChanged;
  final Function(String) onUserLocationChanged; 

  const BookingSummaryStep({
    super.key,
    required this.sitter,
    this.startDate,
    this.endDate,
    required this.service,
    required this.petCount,
    required this.checkIn,
    required this.checkOut,
    this.note = '',
    required this.totalPrice,
    this.selectedPets = const [],
    this.manualPetData,
    required this.userNotes,
    required this.userLocation, 
    required this.onUserNotesChanged,
    required this.onUserLocationChanged, 
  });

  @override
  State<BookingSummaryStep> createState() => _BookingSummaryStepState();
}

class _BookingSummaryStepState extends State<BookingSummaryStep> {
  late TextEditingController _notesController;
  late TextEditingController _locationController;

  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color secondaryTextColor = const Color(0xFF64748B);
  final Color primaryIndigo = const Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.userNotes);
    _locationController = TextEditingController(text: widget.userLocation);
  }

  @override
  void didUpdateWidget(BookingSummaryStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userNotes != _notesController.text) {
      _notesController.text = widget.userNotes;
    }
    if (widget.userLocation != _locationController.text) {
      _locationController.text = widget.userLocation;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showPetDetails(BuildContext context, Animale pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("booking_summary_pet_details_title".tr(args: [pet.nome.toUpperCase()]), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDetailItem("pet_label_species_breed".tr(), "${pet.tipo} - ${pet.razza}"),
                  _buildDetailItem("pet_label_gender".tr(), pet.sesso),
                  _buildDetailItem("pet_label_size".tr(), pet.taglia),
                  _buildDetailItem("pet_label_microchip".tr(), pet.microchipNumero.isNotEmpty ? pet.microchipNumero : "label_not_entered".tr()),
                  _buildDetailItem("pet_label_vaccinated".tr(), pet.vaccinato),
                  _buildDetailItem("pet_label_notes_character".tr(), pet.noteGenerali),
                  _buildDetailItem("pet_label_allergies".tr(), pet.allergico == "Sì" ? pet.allergie : "label_none".tr()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          _buildHeaderSection(
            title: "booking_summary_title".tr(),
            subtitle: "booking_summary_sub".tr(args: [widget.sitter.username]),
          ),
          
          const SizedBox(height: 35),
          
          // 1. PET SELEZIONATI
          _buildPokeCard(
            title: "booking_summary_pets_title".tr(),
            subtitle: "booking_summary_pets_sub".tr(),
            icon: Icons.pets_rounded,
            color: const Color(0xFFFCE7F3), // Pink Light
            accentColor: const Color(0xFFDB2777),
            child: SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  ...widget.selectedPets.map((pet) => Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () => _showPetDetails(context, pet), 
                      child: SizedBox(
                        width: 150,
                        child: CartaAnimale(
                          animaleId: pet.id,
                          nome: pet.nome,
                          sesso: pet.sesso,
                          razza: pet.razza,
                          note: pet.noteGenerali,
                          temaCarta: pet.coloreDominante.isNotEmpty ? pet.coloreDominante : "nuvola_rosa",
                          fotoUrl: pet.fotoUrl,
                        ),
                      ),
                    ),
                  )),
                  if (widget.manualPetData != null && widget.manualPetData!['pets'] != null)
                    ...(widget.manualPetData!['pets'] as Map<String, int>).entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SizedBox(
                        width: 150,
                        child: CartaAnimale(
                          nome: "${entry.value}x ${entry.key}",
                          sesso: "label_manual".tr(),
                          razza: widget.manualPetData!['breeds']?[entry.key]?.first ?? entry.key,
                          note: "label_size_with_value".tr(args: [widget.manualPetData!['size'] ?? ""]),
                          temaCarta: "vortice_verde",
                        ),
                      ),
                    )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),
          
          // 2. DETTAGLI SERVIZIO
          _buildPokeCard(
            title: "booking_summary_service_title".tr(),
            subtitle: "booking_summary_service_sub".tr(),
            icon: Icons.calendar_month_rounded,
            color: const Color(0xFFE0F2FE), // Blue Light
            accentColor: const Color(0xFF0284C7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(Icons.auto_awesome_rounded, "booking_summary_selected_services".tr(), widget.service, const Color(0xFF0284C7)),
                const SizedBox(height: 20),
                _buildSummaryRow(Icons.event_available_rounded, "booking_summary_period".tr(), 
                  widget.endDate != null && widget.startDate != null && widget.startDate != widget.endDate
                  ? "booking_summary_period_range".tr(args: [DateFormat('dd MMM').format(widget.startDate!), DateFormat('dd MMM yyyy').format(widget.endDate!)])
                  : DateFormat('dd MMMM yyyy').format(widget.startDate ?? DateTime.now()), 
                  const Color(0xFF0284C7)
                ),
                const SizedBox(height: 20),
                _buildSummaryRow(Icons.alarm_rounded, "booking_summary_hours".tr(), widget.note.split('|').last.trim().replaceAll("Orari: ", ""), const Color(0xFF0284C7)),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 3. DOVE E NOTE
          _buildPokeCard(
            title: "booking_summary_extra_title".tr(),
            subtitle: "booking_summary_extra_sub".tr(),
            icon: Icons.map_rounded,
            color: const Color(0xFFFFF1E6), // Orange Light
            accentColor: const Color(0xFFD97706),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernField(
                  label: "booking_summary_location_label".tr(), 
                  controller: _locationController, 
                  hint: "booking_summary_location_hint".tr(),
                  icon: Icons.location_on_rounded,
                  onChanged: widget.onUserLocationChanged,
                  labelColor: const Color(0xFFD97706)
                ),
                const SizedBox(height: 10),
                _buildModernField(
                  label: "booking_summary_notes_label".tr(), 
                  controller: _notesController, 
                  hint: "booking_summary_notes_hint".tr(),
                  icon: Icons.sticky_note_2_rounded,
                  onChanged: widget.onUserNotesChanged,
                  maxLines: 3,
                  labelColor: const Color(0xFFD97706)
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildHeaderSection({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 5, height: 30, decoration: BoxDecoration(color: primaryIndigo, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor)),
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPokeCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color, 
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color, width: 4),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, letterSpacing: 1.2)),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: secondaryTextColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 8),
            Text(label.toUpperCase(), style: TextStyle(color: accent.withOpacity(0.6), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            value, 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.4, color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildModernField({
    required String label, 
    required TextEditingController controller, 
    required String hint, 
    required IconData icon,
    required Function(String) onChanged,
    int maxLines = 1,
    Color? labelColor
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor ?? secondaryTextColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: secondaryTextColor.withOpacity(0.4)),
            prefixIcon: Icon(icon, size: 18, color: labelColor?.withOpacity(0.5) ?? secondaryTextColor.withOpacity(0.5)),
            filled: true,
            fillColor: bgLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
      ],
    );
  }
}
