import 'package:flutter/material.dart';

class PremiumDialogs {
  /// Mostra un popup premium per informare che la pubblicazione eventi è premium
  static Future<bool?> mostraRichiestaEventoPremium(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _BasePremiumDialog(
        title: 'Organizza il tuo Evento! 🎫',
        message: 'La funzione di pubblicazione eventi è dedicata ai nostri utenti Premium. Fatti notare dalla community!',
        icon: Icons.confirmation_number_rounded,
        accentColor: Color(0xFF64B5B4),
        buttonText: 'DIVENTA PREMIUM',
      ),
    );
  }

  /// Mostra un popup specifico per il secondo pet smarrito (SOS)
  static Future<bool?> mostraRichiestaSecondoPet(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _BasePremiumDialog(
        title: 'Nuova Segnalazione SOS 🐾',
        message: 'Il primo annuncio è gratuito per tutti. Per attivare una seconda ricerca simultanea, è richiesto un piccolo contributo per sostenere i costi della piattaforma.',
        icon: Icons.campaign_rounded,
        accentColor: Color(0xFFE67E22), // Orange Rescue
        buttonText: 'CONTRIBUISCI (€4.99)',
      ),
    );
  }

  /// Mostra un popup premium per richiedere i permessi delle notifiche
  static Future<bool?> mostraRichiestaNotifiche(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BasePremiumDialog(
        title: 'Resta in Contatto! ✨',
        message: 'Abilita le notifiche per non perdere i promemoria del Diario, gli avvisi SOS e i consigli della tua AI.',
        icon: Icons.notifications_active_rounded,
        accentColor: Colors.lightBlue[400]!,
        buttonText: 'ABILITA ORA',
      ),
    );
  }

  /// Mostra un popup premium per richiedere i permessi della posizione
  static Future<bool?> mostraRichiestaPosizione(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BasePremiumDialog(
        title: 'Attiva la Bussola! 📍',
        message: 'Per trovare i posti migliori per il tuo pet, ho bisogno di sapere dove vi trovate.',
        icon: Icons.location_on_rounded,
        accentColor: Colors.orange[400]!,
        buttonText: 'PERMETTI',
      ),
    );
  }
}

class _BasePremiumDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final String buttonText;

  const _BasePremiumDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: const Color(0xFF0F172A), // Dark Premium
      elevation: 20,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona con bagliore
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withOpacity(0.2), width: 2),
              ),
              child: Icon(icon, color: accentColor, size: 50),
            ),
            const SizedBox(height: 25),
            // Titolo
            Text(
              title,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 22, 
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            // Messaggio
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6), 
                fontSize: 14, 
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            // Bottone Principale
            GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.black, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Bottone Secondario
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'NON ORA', 
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2), 
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
