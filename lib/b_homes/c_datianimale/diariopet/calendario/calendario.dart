import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'evento.dart';
import 'notifiche_calendario.dart';

class CalendarioPage extends StatefulWidget {
  final String animaleId;
  final String? nomeAnimale;

  const CalendarioPage({
    super.key,
    required this.animaleId,
    this.nomeAnimale,
  });

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  late Box box;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late String _currentAnimaleId;
  late String? _currentNomeAnimale;
  bool _petSelected = false;

  Color get _colorTesto => Theme.of(context).brightness == Brightness.light
      ? const Color(0xFF2D3436)
      : Colors.white.withOpacity(0.95);

  Color get _rosaSalmone => Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFFFB7B2)
      : const Color(0xFFFF9E91);

  Color get _colorWeekend => const Color(0xFFFF5252);

  Color _getColorePerCategoria(String categoria) {
    switch (categoria) {
      case 'salute': return const Color(0xFFFFADAD);
      case 'terapie': return const Color(0xFFFFD54F);
      case 'cura': return const Color(0xFFA0C4FF);
      case 'impegni': return const Color(0xFFB9FBC0);
      case 'documenti': return const Color(0xFF8D6E63);
      case 'alimentazione': return const Color(0xFFFFC6FF);
      case 'altro': return const Color(0xFF9575CD);
      default: return const Color(0xFFEEEEEE);
    }
  }

  @override
  void initState() {
    super.initState();
    box = Hive.box('calendar_events');
    _selectedDay = _focusedDay;
    _currentAnimaleId = widget.animaleId;
    _currentNomeAnimale = widget.nomeAnimale;
    _petSelected = false;
    _initNotifiche();
  }

  Future<void> _initNotifiche() async {
    await richiediPermessiNotifica();
    await initNotificheCalendario();
  }

  List<Evento> _getEventiPerGiorno(DateTime day) {
    if (!_petSelected) return [];

    final DateTime soloDataCorrente = DateTime(day.year, day.month, day.day);
    return box.values.map((e) => Evento.fromMap(Map<String, dynamic>.from(e))).where((e) {
      if (e.animalId != _currentAnimaleId) return false;

      final DateTime inizioEvento = DateTime(e.data.year, e.data.month, e.data.day);

      if (e.durataGiorni != null && e.durataGiorni! > 0) {
        final DateTime fineEvento = inizioEvento.add(Duration(days: e.durataGiorni! - 1));
        if (soloDataCorrente.isAfter(fineEvento)) return false;
      }

      switch (e.ripetizione) {
        case 'daily':
          return !soloDataCorrente.isBefore(inizioEvento);
        case 'weekly':
          return !soloDataCorrente.isBefore(inizioEvento) && inizioEvento.weekday == soloDataCorrente.weekday;
        case 'monthly':
          return !soloDataCorrente.isBefore(inizioEvento) && inizioEvento.day == soloDataCorrente.day;
        default:
          return isSameDay(e.data, day);
      }
    }).toList();
  }

  Future<void> _salvaEvento(Evento evento) async {
    await box.put(evento.id, evento.toMap());
    await scheduleEventNotifications(evento);
    if (mounted) setState(() {});
  }

  Future<void> _eliminaEvento(Evento evento) async {
    await cancelNotificationsForEvent(evento);
    await box.delete(evento.id);
    if (mounted) setState(() {});
  }

  Future<void> _eliminaTuttiImpegniGiorno(List<Evento> eventi) async {
    bool? conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        title: Text("cal_confirm_delete_day_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text("cal_confirm_delete_day_msg".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("btn_cancel_upper".tr(), style: const TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("btn_delete_upper".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (conferma == true) {
      for (var e in eventi) {
        await cancelNotificationsForEvent(e);
        await box.delete(e.id);
      }
      if (mounted) setState(() {});
    }
  }

  void _mostraDialogAggiungi(DateTime date) {
    if (!_petSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("snack_select_pet_first".tr())),
      );
      return;
    }

    final titoloController = TextEditingController();
    final noteController = TextEditingController();
    final durataController = TextEditingController();
    String categoria = "salute";
    String ripetizione = "none";
    List<String> opzioniSelezionate = [];
    int intervalloOre = 24;
    List<TimeOfDay> listaOrari = [TimeOfDay.now()];
    int step = 1;

    void rigeneraOrari(Function setModalState) {
      if (intervalloOre == 24) {
        if (listaOrari.isEmpty) listaOrari = [TimeOfDay.now()];
        else listaOrari = [listaOrari[0]];
        return;
      }
      TimeOfDay base = listaOrari.isNotEmpty ? listaOrari[0] : TimeOfDay.now();
      listaOrari.clear();
      if (ripetizione == "none") {
        int h = base.hour;
        while (h < 24) {
          listaOrari.add(TimeOfDay(hour: h, minute: base.minute));
          h += intervalloOre;
        }
      } else {
        int volte = 24 ~/ intervalloOre;
        for (int i = 0; i < volte; i++) {
          listaOrari.add(TimeOfDay(hour: (base.hour + (i * intervalloOre)) % 24, minute: base.minute));
        }
        listaOrari.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),

              if (step == 1) ...[
                Text("cal_dialog_add_title".tr(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _colorTesto, letterSpacing: 1)),
                const SizedBox(height: 25),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: Evento.opzioniPerCategoria.keys.where((c) => c != 'altro').map((cat) {
                      final color = _getColorePerCategoria(cat);
                      return GestureDetector(
                        onTap: () => setModalState(() {
                          categoria = cat;
                          step = 2;
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: color.withOpacity(0.3), width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getIconaPerCategoria(cat), color: color, size: 35),
                              const SizedBox(height: 8),
                              Text(
                                Evento.getLabelCategoria(cat).split(' ').last,
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _colorTesto),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()..add(
                      GestureDetector(
                        onTap: () => setModalState(() {
                          categoria = 'altro';
                          step = 2;
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getColorePerCategoria('altro').withOpacity(0.15),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: _getColorePerCategoria('altro').withOpacity(0.3), width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.more_horiz_rounded, color: _getColorePerCategoria('altro'), size: 35),
                              const SizedBox(height: 8),
                              Text("cal_cat_altro".tr().split(' ').last, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: _colorTesto)),
                            ],
                          ),
                        ),
                      )
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () => setModalState(() => step = 1),
                    ),
                    Text(
                      Evento.getLabelCategoria(categoria).toUpperCase(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _getColorePerCategoria(categoria)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Evento.opzioniPerCategoria[categoria]!.isNotEmpty) ...[
                          _label("cal_label_detail".tr()),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Evento.opzioniPerCategoria[categoria]!.map((opzione) {
                              final isSelected = opzioniSelezionate.contains(opzione);
                              final catColor = _getColorePerCategoria(categoria);
                              return FilterChip(
                                label: Text(opzione),
                                selected: isSelected,
                                onSelected: (s) => setModalState(() => s ? opzioniSelezionate.add(opzione) : opzioniSelezionate.remove(opzione)),
                                backgroundColor: Colors.black.withOpacity(0.05),
                                selectedColor: catColor,
                                labelStyle: TextStyle(color: _colorTesto, fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isSelected ? catColor : Colors.transparent)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        _label("cal_label_custom_title".tr()),
                        TextField(
                          controller: titoloController,
                          style: TextStyle(color: _colorTesto),
                          decoration: _inputStyle("cal_hint_custom_title".tr())
                        ),
                        const SizedBox(height: 15),
                        _label("cal_label_repetition".tr()),
                        DropdownButtonFormField<String>(
                          value: ripetizione,
                          style: TextStyle(color: _colorTesto),
                          dropdownColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF2C2C2C),
                          decoration: _inputStyle(null),
                          items: [
                            DropdownMenuItem(value: "none", child: Text("cal_rep_none".tr())),
                            DropdownMenuItem(value: "daily", child: Text("cal_rep_daily".tr())),
                            DropdownMenuItem(value: "weekly", child: Text("cal_rep_weekly".tr())),
                            DropdownMenuItem(value: "monthly", child: Text("cal_rep_monthly".tr())),
                          ],
                          onChanged: (val) => setModalState(() {
                            ripetizione = val!;
                            rigeneraOrari(setModalState);
                          }),
                        ),
                        if (ripetizione != "none") ...[
                          const SizedBox(height: 15),
                          _label("cal_label_duration".tr()),
                          TextField(
                            controller: durataController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: _colorTesto),
                            decoration: _inputStyle("cal_hint_duration".tr()),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _label("cal_label_times".tr()),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: _getColorePerCategoria(categoria).withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                              child: DropdownButton<int>(
                                value: intervalloOre,
                                underline: const SizedBox(),
                                isDense: true,
                                dropdownColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF2C2C2C),
                                items: [1, 2, 3, 4, 6, 8, 12, 24].map((h) => DropdownMenuItem(value: h, child: Text(h == 24 ? "cal_times_count".tr() : "cal_times_every".tr(args: [h.toString()]), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _colorTesto)))).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() {
                                      intervalloOre = val;
                                      rigeneraOrari(setModalState);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(listaOrari.length, (index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                              leading: Icon(Icons.access_time_filled_rounded, color: _getColorePerCategoria(categoria), size: 22),
                              title: Text("cal_label_time_index".tr(args: [(index + 1).toString()]), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                                ),
                                child: Text(listaOrari[index].format(context), style: TextStyle(fontWeight: FontWeight.w900, color: _colorTesto, fontSize: 15)),
                              ),
                              onTap: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (ctx) => Container(
                                    height: 250,
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF1E1E1E),
                                    child: Column(
                                      children: [
                                        Container(
                                          color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.black26,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CupertinoButton(child: Text("btn_cancel".tr()), onPressed: () => Navigator.pop(ctx)),
                                              CupertinoButton(child: Text("profile_btn_confirm".tr()), onPressed: () => Navigator.pop(ctx)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode.time,
                                            use24hFormat: true,
                                            initialDateTime: DateTime(2024, 1, 1, listaOrari[index].hour, listaOrari[index].minute),
                                            onDateTimeChanged: (DateTime newDate) {
                                              setModalState(() {
                                                listaOrari[index] = TimeOfDay(hour: newDate.hour, minute: newDate.minute);
                                                if (index == 0 && intervalloOre != 24) {
                                                  rigeneraOrari(setModalState);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getColorePerCategoria(categoria),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 8,
                            shadowColor: _getColorePerCategoria(categoria).withOpacity(0.5),
                          ),
                          onPressed: () async {
                            if (categoria == "altro" && titoloController.text.isEmpty) return;

                            String tFinale = titoloController.text.isNotEmpty ? titoloController.text : (opzioniSelezionate.isNotEmpty ? opzioniSelezionate.join(", ") : Evento.getLabelCategoria(categoria));
                            final List<String> oStr = listaOrari.map((t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}").toList();

                            final nuovoEvento = Evento(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              animalId: _currentAnimaleId,
                              nomeAnimale: _currentNomeAnimale,
                              categoria: categoria,
                              titolo: tFinale,
                              descrizione: noteController.text,
                              data: date,
                              durataGiorni: int.tryParse(durataController.text),
                              ripetizione: ripetizione,
                              notifiche: [0],
                              completato: false,
                              creatoIl: DateTime.now(),
                              frequenza: listaOrari.length,
                              orari: oStr,
                            );

                            if (ripetizione != "none" || listaOrari.length > 1) {
                              bool? procedi = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  title: Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded, color: Colors.orange),
                                      const SizedBox(width: 10),
                                      Text("cal_recurring_event_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                  content: Text("cal_recurring_event_msg".tr()),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("cal_btn_edit_upper".tr())),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("cal_btn_got_it_save".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              );
                              if (procedi != true) return;
                            }

                            await _salvaEvento(nuovoEvento);
                            Navigator.pop(context);
                          },
                          child: Text("cal_btn_confirm_save".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 5), child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey)));

  InputDecoration _inputStyle(String? h) => InputDecoration(hintText: h, filled: true, fillColor: Theme.of(context).brightness == Brightness.light ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16));

  @override
  Widget build(BuildContext context) {
    final eventi = _getEventiPerGiorno(_selectedDay!);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uid != null) ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1.0,
                        child: child,
                      ),
                    );
                  },
                  child: !_petSelected
                      ? Padding(
                          key: const ValueKey('prompt'),
                          padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                          child: Text(
                            "cal_pet_selection_prompt".tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.blueGrey,
                              letterSpacing: 1.5,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: const ValueKey('empty')),
                ),
                _buildPetHeader(uid),
              ],
              const SizedBox(height: 10),
              _buildCalendarFixed(),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                child: Row(
                  children: [
                    Text("cal_agenda_today".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _colorTesto.withOpacity(0.8), letterSpacing: 1.2)),
                    const Spacer(),
                    if (eventi.isNotEmpty)
                      IconButton(
                        onPressed: () => _eliminaTuttiImpegniGiorno(eventi),
                        icon: Icon(Icons.delete_sweep_rounded, color: Colors.red.withOpacity(0.5), size: 28),
                        tooltip: "cal_delete_day_tooltip".tr(),
                      ),
                    Icon(Icons.auto_awesome, size: 20, color: Colors.orange.shade300),
                  ],
                ),
              ),
              _buildEventList(eventi),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _rosaSalmone,
        elevation: 6,
        onPressed: () => _mostraDialogAggiungi(_selectedDay!),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
      ),
    );
  }

  Widget _buildPetHeader(String uid) {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animali').where('userId', isEqualTo: uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final animali = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: animali.length,
            itemBuilder: (context, index) {
              final a = animali[index].data() as Map<String, dynamic>;
              final sel = animali[index].id == _currentAnimaleId;
              return GestureDetector(
                onTap: () => setState(() {
                  _currentAnimaleId = animali[index].id;
                  _currentNomeAnimale = a['nome'];
                  _petSelected = true;
                }),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.white12,
                        backgroundImage: (a['fotoUrl'] != null && a['fotoUrl'].isNotEmpty) ? NetworkImage(a['fotoUrl']) : null,
                        child: (a['fotoUrl'] == null || a['fotoUrl'].isEmpty) ? const Icon(Icons.pets, color: Colors.grey, size: 24) : null,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                          color: (sel && _petSelected) ? _rosaSalmone : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a['nome'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: (sel && _petSelected) ? FontWeight.w900 : FontWeight.bold,
                          color: (sel && _petSelected) ? Colors.white : Colors.white.withOpacity(0.7)
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCalendarFixed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (s, f) => setState(() {
          _selectedDay = s;
          _focusedDay = f;
        }),
        eventLoader: _getEventiPerGiorno,
        rowHeight: 45,
        daysOfWeekHeight: 25,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w900, color: _colorTesto, fontSize: 18),
          leftChevronIcon: Icon(Icons.chevron_left_rounded, color: _colorTesto, size: 28),
          rightChevronIcon: Icon(Icons.chevron_right_rounded, color: _colorTesto, size: 28),
          headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox();
            final categorie = events.map((e) => (e as Evento).categoria).toSet().toList();
            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: categorie.take(4).map((cat) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _getColorePerCategoria(cat)),
                  );
                }).toList(),
              ),
            );
          },
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: _colorTesto.withOpacity(0.1), shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: _colorTesto, fontWeight: FontWeight.bold, fontSize: 15),
          selectedDecoration: BoxDecoration(color: _rosaSalmone, shape: BoxShape.circle),
          selectedTextStyle: TextStyle(color: isDark ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: _colorWeekend, fontSize: 14, fontWeight: FontWeight.bold),
          defaultTextStyle: TextStyle(fontSize: 14, color: _colorTesto, fontWeight: FontWeight.w700),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _colorTesto),
          weekendStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _colorWeekend),
        ),
      ),
    );
  }

  Widget _buildEventList(List<Evento> eventi) {
    if (!_petSelected) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text("cal_select_pet_hint".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600)),
        ),
      );
    }

    if (eventi.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Icon(Icons.wb_sunny_rounded, size: 60, color: Colors.orange.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text("cal_no_events_today".tr(), style: TextStyle(color: _colorTesto, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      itemCount: eventi.length,
      itemBuilder: (context, index) {
        final evento = eventi[index];
        final catColor = _getColorePerCategoria(evento.categoria);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 80,
                decoration: BoxDecoration(color: catColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(25))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: catColor.withOpacity(0.2), shape: BoxShape.circle),
                            child: Icon(_getIconaPerCategoria(evento.categoria), color: catColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evento.titolo,
                                  style: TextStyle(fontWeight: FontWeight.w900, color: _colorTesto, fontSize: 16),
                                ),
                                if (evento.durataGiorni != null && evento.durataGiorni! > 0)
                                  Text(
                                    "cal_cycle_duration".tr(args: [evento.durataGiorni.toString()]),
                                    style: TextStyle(fontSize: 11, color: _colorTesto.withOpacity(0.5), fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.withOpacity(0.6), size: 22),
                            onPressed: () => _confermaElimina(evento),
                          ),
                        ],
                      ),
                      if (evento.orari != null && evento.orari!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: evento.orari!.map((ora) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: catColor.withOpacity(0.2)),
                            ),
                            child: Text(
                              ora,
                              style: TextStyle(color: _colorTesto.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconaPerCategoria(String categoria) {
    switch (categoria) {
      case 'salute': return Icons.medical_services_rounded;
      case 'terapie': return Icons.medication_rounded;
      case 'cura': return Icons.content_cut_rounded;
      case 'impegni': return Icons.pets_rounded;
      case 'documenti': return Icons.description_rounded;
      case 'alimentazione': return Icons.restaurant_rounded;
      default: return Icons.event_note_rounded;
    }
  }

  void _confermaElimina(Evento evento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        title: Text("cal_confirm_delete_event_title".tr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Text("cal_confirm_delete_event_msg".tr(), style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("btn_cancel_upper".tr(), style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () { _eliminaEvento(evento); Navigator.pop(context); }, child: Text("btn_delete_upper".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
