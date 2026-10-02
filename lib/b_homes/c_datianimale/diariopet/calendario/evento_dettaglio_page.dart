import 'package:flutter/material.dart';
import '../calendario/evento.dart';
import 'package:easy_localization/easy_localization.dart';

class EventoDettaglioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final evento = ModalRoute.of(context)!.settings.arguments as Evento;

    return Scaffold(
      appBar: AppBar(
        title: Text(evento.titolo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('cal_detail_category'.tr(args: [evento.categoria])),
            Text('cal_detail_description'.tr(args: [evento.descrizione])),
            Text('cal_detail_date'.tr(args: [evento.data.toString()])),
            Text('cal_detail_repetition'.tr(args: [evento.ripetizione])),
            Text('cal_detail_notifications'.tr(args: [evento.notifiche.join(", ")])),
            if (evento.veterinario != null) Text('cal_detail_veterinary'.tr(args: [evento.veterinario!])),
            if (evento.farmaco != null) Text('cal_detail_medicine'.tr(args: [evento.farmaco!])),
            if (evento.documento != null) Text('cal_detail_document'.tr(args: [evento.documento!])),
            if (evento.noteExtra != null) Text('cal_detail_notes'.tr(args: [evento.noteExtra!])),
          ],
        ),
      ),
    );
  }
}