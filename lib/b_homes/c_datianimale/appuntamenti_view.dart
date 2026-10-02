import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:petping/b_homes/c_datianimale/notifiche_util.dart';

class AppuntamentiView extends StatefulWidget {
  final String animaleId;

  const AppuntamentiView({super.key, required this.animaleId});

  @override
  _AppuntamentiViewState createState() => _AppuntamentiViewState();
}

class _AppuntamentiViewState extends State<AppuntamentiView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _eventi = {};

  List<String> _getEventiPerGiorno(DateTime giorno) {
    return _eventi[DateTime(giorno.year, giorno.month, giorno.day)] ?? [];
  }

  void _aggiungiEvento(String evento) {
    final giorno = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    setState(() {
      _eventi.putIfAbsent(giorno, () => []).add(evento);
    });

    pianificaNotifiche(giorno, 'Appuntamento', evento);
  }

  void _mostraDialogoAggiunta() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('cal_opt_appointment'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'label_description_upper'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('btn_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _aggiungiEvento(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text('btn_save'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
          eventLoader: _getEventiPerGiorno,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _selectedDay == null ? null : _mostraDialogoAggiunta,
          icon: const Icon(Icons.add),
          label: Text('cal_opt_appointment'.tr()),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: _getEventiPerGiorno(
              _selectedDay ?? _focusedDay,
            ).map((e) => ListTile(title: Text(e))).toList(),
          ),
        ),
      ],
    );
  }
}
