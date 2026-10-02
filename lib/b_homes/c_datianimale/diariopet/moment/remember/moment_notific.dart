import 'package:flutter/material.dart';
// Importa qui il tuo servizio notifiche esistente per usare i suoi metodi
//import 'package:petping/notification_service.dart';

class MomentNotificationManager {

  /// Funzione principale: calcola quando finisce la stagione attuale
  /// e programma la notifica per quel giorno.
  static void scheduleSeasonReview(String categoria) {
    DateTime oggi = DateTime.now();
    DateTime dataNotifica;
    String messaggio;

    // 1. CALCOLO CRONOMETRO STAGIONALE
    switch (categoria) {
      case 'Primavera':
        dataNotifica = DateTime(oggi.year, 6, 21, 10, 0); // 21 Giugno ore 10:00
        messaggio = "I petali sono caduti... 🌸 La tua Primavera con il tuo pet è qui!";
        break;
      case 'Estate':
      case 'Spiaggia':
        dataNotifica = DateTime(oggi.year, 9, 23, 10, 0); // 23 Settembre
        messaggio = "L'ultima onda dell'estate! 🌊 Guarda i vostri momenti al sole.";
        break;
      case 'Autunno':
        dataNotifica = DateTime(oggi.year, 12, 21, 10, 0); // 21 Dicembre
        messaggio = "Le foglie hanno smesso di cadere... 🍂 Rivivi il vostro Autunno.";
        break;
      case 'Inverno':
        dataNotifica = DateTime(oggi.year + (oggi.month > 2 ? 1 : 0), 3, 21, 10, 0); // 21 Marzo
        messaggio = "Il ghiaccio si scioglie! ❄️ Guarda la vostra collezione invernale.";
        break;
      default:
        return;
    }

    // 2. CONTROLLO DATA
    // Se la data calcolata è già passata oggi, non programmiamo nulla per ora
    if (dataNotifica.isBefore(oggi)) return;

    // 3. INVIO AL TUO SERVIZIO NOTIFICHE ESISTENTE
    // Qui devi chiamare il metodo che hai già nel tuo file notifiche generale.
    // Esempio ipotetico:
    /*
    NotificationService.programmaNotificaLocale(
      id: categoria.hashCode,
      title: "Collezione Stagionale 🐾",
      body: messaggio,
      scheduledDate: dataNotifica,
      payload: categoria, // Fondamentale per aprire la pagina giusta al click
    );
    */

    print("Notifica $categoria programmata per il: $dataNotifica");
  }

  /// Metodo utile per capire in che stagione siamo oggi automaticamente
  static String getStagioneAttuale() {
    int mese = DateTime.now().month;
    if (mese >= 3 && mese <= 5) return 'Primavera';
    if (mese >= 6 && mese <= 8) return 'Spiaggia';
    if (mese >= 9 && mese <= 11) return 'Autunno';
    return 'Inverno';
  }
}