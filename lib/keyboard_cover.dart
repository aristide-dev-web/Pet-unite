import 'package:flutter/material.dart';

class SafeFormPage extends StatelessWidget {
  final Widget child;

  const SafeFormPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Rimuoviamo il Scaffold interno per evitare conflitti con la pagina principale
    return SingleChildScrollView(
      // Impedisce al contenuto di essere coperto aggiungendo spazio in fondo pari all'altezza della tastiera
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
      ),
      child: child,
    );
  }
}
