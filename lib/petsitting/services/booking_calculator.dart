import '../models/sitter_model.dart';

class BookingCalculator {
  /// Calcola il preventivo totale per una prenotazione.
  /// Ora gestisce la tariffa notturna slot per slot (ogni 30 min).
  static double calculateTotal({
    required SitterProfile sitter,
    required String serviceName,
    required int numberOfPets, 
    required int quantity, // Numero di slot da 30 minuti o numero di giorni
    double? kmTravelled, 
    double? minutesTravelled,
    String? duration, // Es. "30", "45", "60"
    bool isWeekend = false,
    bool isNight = false,
  }) {
    double basePrice = 0.0;
    double total = 0.0;

    // 1. CASO TAXI PET
    if (serviceName == 'Taxi Pet') {
      double fareBase = sitter.taxiBaseFare;
      double fareKm = sitter.taxiPricePerKm * (kmTravelled ?? 0);
      double fareMin = sitter.taxiPricePerMin * (minutesTravelled ?? 0);
      
      basePrice = fareBase + fareKm + fareMin;
      total = basePrice * quantity;

      if (isNight && sitter.taxiNightSurcharge > 0) {
        total += (total * (sitter.taxiNightSurcharge / 100));
      }
      
      return total;
    }

    // 2. DETERMINAZIONE PREZZO BASE (per 30 minuti o per giorno)
    // Se c'è una durata specifica (es. "Bagnetto-S") usiamo quella, altrimenti il nome servizio
    if (duration != null && duration != "30") {
      String key = '$serviceName-$duration';
      basePrice = sitter.serviziPrezzi[key] ?? sitter.serviziPrezzi[serviceName] ?? 0.0;
    } else {
      basePrice = sitter.serviziPrezzi[serviceName] ?? 0.0;
    }

    // 3. DETERMINAZIONE PREZZO NOTTURNO
    // Il sitter imposta un "Extra Notturno" per il servizio. 
    // Se non impostato, usiamo il prezzo base come default per la notte.
    double nightPrice = sitter.serviziNotturnoExtra[serviceName] ?? basePrice;
    if (nightPrice == 0) nightPrice = basePrice;

    // 4. CALCOLO FINALE
    // Se è notte, usiamo la tariffa notturna per ogni unità di quantità (ogni slot da 30 min)
    if (isNight) {
      total = nightPrice * quantity;
    } else {
      total = basePrice * quantity;
    }

    return total;
  }
}
