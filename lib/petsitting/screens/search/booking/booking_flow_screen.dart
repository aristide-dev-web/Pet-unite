import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petping/petsitting/models/sitter_model.dart';
import 'package:petping/petsitting/services/booking_calculator.dart'; 
import 'booking_flow_view.dart';
import 'package:petping/b_homes/c_datianimale/diariopet/back_diario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/b_homes/d_message/message_model.dart';
import 'package:petping/b_homes/d_message/message_service.dart';
import 'package:intl/intl.dart';
import '../components/sections/sitter_ui_helpers.dart';
import 'package:petping/petsitting/screens/registration/sections/serzioni/specie_selector_widget.dart';
import 'package:petping/strip/stripe_service.dart';
import 'package:petping/petsitting/services/availability_service.dart';
import 'package:petping/petsitting/models/booking_model.dart';
import 'package:petping/petsitting/services/booking_service.dart';
import 'package:petping/models/user_profile_model.dart'; 
import 'dart:developer' as dev;

class BookingFlowScreen extends StatefulWidget {
  final SitterProfile sitter;
  const BookingFlowScreen({super.key, required this.sitter});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  List<Animale> _selectedPets = [];
  List<String> _selectedPetIds = [];
  Map<String, int> _manualPets = {};
  Map<String, List<String>> _manualBreeds = {};
  String _manualSize = '';

  List<String> _selectedServices = [];
  Map<String, int> _selectedDurations = {};
  Map<String, List<String>> _selectedSizes = {};

  List<DateTime> _selectedDays = [];
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  List<TimeOfDay> _selectedTimes = [];
  int _timesPerDay = 1;
  double _totalPrice = 0.0;

  String _userNotes = '';
  String _userLocation = '';

  DateTime? _activeDay;
  List<DateTime> _allDays = [];
  
  List<PetBooking> _existingBookings = [];

  @override
  void initState() {
    super.initState();
    // ✅ Nulla di preselezionato all'avvio
    _selectedServices = [];

    _loadSavedPreferences();
    _loadSitterBookings();
  }

  Future<void> _loadSitterBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('sitterId', isEqualTo: widget.sitter.uid)
          .where('status', whereIn: ['accepted', 'completed'])
          .get();

      setState(() {
        _existingBookings = snapshot.docs.map((doc) => PetBooking.fromFirestore(doc)).toList();
      });
    } catch (e) {
      dev.log("DEBUG_BOOKING: Errore caricamento prenotazioni: $e");
    }
  }

  bool _isDayOccupied(DateTime day) {
    final checkDay = DateTime(day.year, day.month, day.day);
    
    for (var b in _existingBookings) {
      bool isFullDayService = b.serviceType.contains('Pensione') || b.serviceType.toLowerCase().contains('boarding');
      if (!isFullDayService) continue;

      final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      
      if ((checkDay.isAtSameMomentAs(start) || checkDay.isAfter(start)) &&
          (checkDay.isAtSameMomentAs(end) || checkDay.isBefore(end))) {
        return true;
      }
    }
    return false;
  }

  Future<void> _loadSavedPreferences() async {
    try {
      if (!Hive.isBoxOpen('booking_preferences')) {
        await Hive.openBox('booking_preferences');
      }
      final box = Hive.box('booking_preferences');

      setState(() {
        _selectedPetIds = List<String>.from(box.get('selectedPetIds', defaultValue: <String>[]));

        final animaliBox = Hive.box<Animale>(animaliBoxName);
        _selectedPets = _selectedPetIds
            .map((id) => animaliBox.get(id))
            .where((pet) => pet != null)
            .cast<Animale>()
            .toList();

        _manualPets = Map<String, int>.from(box.get('manualPets', defaultValue: {}));

        final savedBreeds = box.get('manualBreeds', defaultValue: {});
        _manualBreeds = {};
        savedBreeds.forEach((key, value) {
          if (value is List) {
            _manualBreeds[key.toString()] = List<String>.from(value);
          }
        });

        _manualSize = box.get('manualSize', defaultValue: '');
        _userLocation = box.get('userLocation', defaultValue: '');

        _updateAllDays();
      });

      _calculatePrice();
    } catch (e) {
      dev.log("DEBUG_BOOKING: Errore caricamento preferenze Hive: $e");
    }
  }

  void _updateAllDays() {
    if (_rangeStart != null && _rangeEnd != null) {
      _allDays = [];
      for (int i = 0; i <= _rangeEnd!.difference(_rangeStart!).inDays; i++) {
        _allDays.add(_rangeStart!.add(Duration(days: i)));
      }
    } else if (_selectedDays.isNotEmpty) {
      _allDays = List.from(_selectedDays)..sort();
    } else {
      _allDays = [];
    }

    if (_allDays.isNotEmpty && (_activeDay == null || !_allDays.contains(_activeDay))) {
      _activeDay = _allDays.first;
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    try {
      if (!Hive.isBoxOpen('booking_preferences')) {
        await Hive.openBox('booking_preferences');
      }
      await Hive.box('booking_preferences').put(key, value);
    } catch (e) {
      dev.log("DEBUG_BOOKING: Errore salvataggio preferenza Hive: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    double total = 0;
    if (_selectedServices.isEmpty) {
      setState(() => _totalPrice = 0);
      return;
    }

    int numPets = _selectedPetIds.length;
    _manualPets.values.forEach((q) => numPets += q);

    for (var service in _selectedServices) {
      if (_selectedTimes.isNotEmpty) {
        for (var time in _selectedTimes) {
          bool isNight = AvailabilityService.isNightSlot(time);
          total += BookingCalculator.calculateTotal(
            sitter: widget.sitter,
            serviceName: service,
            numberOfPets: numPets,
            quantity: 1,
            duration: "30",
            isNight: isNight,
          );
        }
      } else {
        int quantity = _allDays.length;
        total += BookingCalculator.calculateTotal(
          sitter: widget.sitter,
          serviceName: service,
          numberOfPets: numPets,
          quantity: quantity > 0 ? quantity : 1,
          duration: _selectedDurations[service]?.toString() ?? "30",
        );
      }
    }

    setState(() {
      _totalPrice = total;
    });
  }

  void _onPetToggle(Animale pet) {
    setState(() {
      if (_selectedPetIds.contains(pet.id)) {
        _selectedPetIds.remove(pet.id);
        _selectedPets.removeWhere((p) => p.id == pet.id);
      } else {
        _selectedPetIds.add(pet.id);
        _selectedPets.add(pet);
      }
    });
    _savePreference('selectedPetIds', _selectedPetIds);
    _calculatePrice();
  }

  void _onManualPetChanged(Map<String, int> pets, Map<String, List<String>> breeds, String size) {
    setState(() {
      _manualPets = pets;
      _manualBreeds = breeds;
      _manualSize = size;
    });
    _savePreference('manualPets', _manualPets);
    _savePreference('manualBreeds', _manualBreeds);
    _savePreference('manualSize', _manualSize);
    _calculatePrice();
  }

  void _onServiceToggle(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
    _calculatePrice();
  }

  void _onSizeSelected(String service, String size) {
    setState(() {
      if (!_selectedSizes.containsKey(service)) {
        _selectedSizes[service] = [];
      }
      if (_selectedSizes[service]!.contains(size)) {
        _selectedSizes[service]!.remove(size);
      } else {
        _selectedSizes[service]!.add(size);
      }
    });
    _calculatePrice();
  }

  void _onDurationSelected(String service, int duration) {
    setState(() {
      _selectedDurations[service] = duration;
    });
    _calculatePrice();
  }

  void _onSelectionChanged({List<DateTime>? days, DateTime? start, DateTime? end, required DateTime focusedDay}) {
    setState(() {
      if (days != null) _selectedDays = days;
      _rangeStart = start;
      _rangeEnd = end;
      _updateAllDays();
    });
    _calculatePrice();
  }

  void _onConfirm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final bookingId = "book_${DateTime.now().millisecondsSinceEpoch}";
      
      final start = _rangeStart ?? (_selectedDays.isNotEmpty ? _selectedDays.first : DateTime.now());
      final end = _rangeEnd ?? (_selectedDays.isNotEmpty ? _selectedDays.last : start);

      int totalPetsCount = _selectedPetIds.length;
      _manualPets.values.forEach((q) => totalPetsCount += q);

      List<String> timesStrings = [];
      String cIn = "10:00";
      String cOut = "18:00";
      if (_selectedTimes.isNotEmpty) {
        _selectedTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
        timesStrings = _selectedTimes.map((t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}").toList();
        cIn = timesStrings.first;
        cOut = timesStrings.last;
      }

      List<Map<String, dynamic>> petsInfo = _selectedPets.map((p) => {
        'id': p.id,
        'nome': p.nome,
        'fotoUrl': p.fotoUrl,
        'tipo': p.tipo,
        'razza': p.razza,
        'coloreDominante': p.coloreDominante,
      }).toList();

      _manualPets.forEach((tipo, quantita) {
        if (quantita > 0) {
          petsInfo.add({
            'id': 'manual_${tipo}',
            'nome': '${quantita}x $tipo',
            'tipo': tipo,
            'isManual': true,
          });
        }
      });

      final profileBox = Hive.box<UserProfile>('user_profile_box');
      final myProfile = profileBox.get(user.uid);

      final newBooking = PetBooking(
        id: bookingId,
        sitterId: widget.sitter.uid,
        ownerId: user.uid,
        petId: _selectedPetIds.isNotEmpty ? _selectedPetIds.join(',') : 'MANUAL',
        startDate: start,
        endDate: end,
        serviceType: _selectedServices.join(', '),
        totalPrice: _totalPrice,
        status: BookingStatus.pending,
        note: _userNotes,
        petCount: totalPetsCount,
        checkInTime: cIn,
        checkOutTime: cOut,
        selectedTimes: timesStrings,
        location: _userLocation,
        petsInfo: petsInfo,
        ownerName: myProfile?.username ?? 'Utente',
        ownerPhotoUrl: myProfile?.fotoUrl,
      );

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set(newBooking.toMap());

      final List<String> ids = [user.uid, widget.sitter.uid]..sort();
      final String chatId = ids.join('_');

      final String dateRange = "${DateFormat('dd/MM').format(start)}${start != end ? ' - ${DateFormat('dd/MM').format(end)}' : ''}";
      final String petsNames = _selectedPets.map((p) => p.nome).join(', ');

      // ✅ Messaggio arricchito con emoji e stile migliorato
      final String text = "🐾 *${"ps_booking_msg_header".tr()}*\n\n"
          "🐕 *${"ps_booking_msg_pet".tr()}*: ${petsNames.isNotEmpty ? petsNames : "ps_booking_msg_notes_spec".tr()}\n"
          "🛠 *${"ps_reg_services_header".tr()}*: ${_selectedServices.join(', ')}\n"
          "📅 *${"vet_label_date".tr()}*: $dateRange\n"
          "⏰ *${"cal_label_times".tr()}*: ${timesStrings.isNotEmpty ? timesStrings.join(', ') : "ps_booking_msg_to_arrange".tr()}\n"
          "📍 *${"ps_reg_section_address".tr()}*: ${_userLocation.isNotEmpty ? _userLocation : "ps_reg_rev_not_specified".tr()}\n"
          "💰 *${"ps_booking_msg_total".tr()}*: €${_totalPrice.toInt()}\n"
          "📝 *${"vet_label_description".tr()}*: ${_userNotes.isNotEmpty ? _userNotes : "ps_reg_rev_none".tr()}\n\n"
          "✨ ${"ps_booking_msg_footer".tr()}";

      final message = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: user.uid,
        receiverId: widget.sitter.uid,
        text: text,
        timestamp: DateTime.now(),
        type: 'booking_request',
        bookingData: newBooking.toMap(),
      );

      await MessageService().sendMessage(
        chatId, 
        message, 
        isBooking: true,
        senderName: myProfile?.username ?? 'Utente',
        senderPhotoUrl: myProfile?.fotoUrl,
        receiverName: widget.sitter.username,
        receiverPhotoUrl: widget.sitter.fotoUrl,
      );

      if (Hive.isBoxOpen('booking_preferences')) {
        await Hive.box('booking_preferences').clear();
      }

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ps_booking_success_msg".tr()), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      dev.log("DEBUG_BOOKING: ERRORE: $e");
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("snack_error_msg".tr(args: [e.toString()]))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingFlowView(
      sitter: widget.sitter,
      currentStep: _currentStep,
      pageController: _pageController,
      selectedPets: _selectedPets,
      selectedPetIds: _selectedPetIds,
      onPetToggleWithObject: _onPetToggle,
      manualPets: _manualPets,
      manualBreeds: _manualBreeds,
      manualSize: _manualSize,
      onManualPetChanged: _onManualPetChanged,
      selectedServices: _selectedServices,
      selectedDurations: _selectedDurations,
      selectedSizes: _selectedSizes,
      selectedDays: _selectedDays,
      rangeStart: _rangeStart,
      rangeEnd: _rangeEnd,
      selectedTimes: _selectedTimes,
      timesPerDay: _timesPerDay,
      totalPrice: _totalPrice,
      userNotes: _userNotes,
      onUserNotesChanged: (val) => setState(() => _userNotes = val),
      userLocation: _userLocation,
      onLocationChanged: (val) {
        setState(() => _userLocation = val);
        _savePreference('userLocation', val);
      },
      allDays: _allDays,
      activeDay: _activeDay,
      onServiceToggle: _onServiceToggle,
      onSizeSelected: _onSizeSelected,
      onDurationSelected: _onDurationSelected,
      onSelectionChanged: _onSelectionChanged,
      isDayOccupied: _isDayOccupied,
      onTimeToggle: (t) {
        setState(() {
          if (_selectedTimes.contains(t)) {
            _selectedTimes.remove(t);
          } else {
            _selectedTimes.add(t);
          }
        });
        _calculatePrice();
      },
      onTimesPerDayChanged: (val) => setState(() => _timesPerDay = val),
      onActiveDayChanged: (d) => setState(() => _activeDay = d),
      onApplyToAllDays: () {},
      onNext: () {
        if (_currentStep < 5) {
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          setState(() => _currentStep++);
        }
      },
      onBack: () {
        if (_currentStep > 0) {
          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          setState(() => _currentStep--);
        } else {
          Navigator.pop(context);
        }
      },
      onConfirm: _onConfirm,
    );
  }
}
