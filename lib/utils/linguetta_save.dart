import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinguettaSave extends StatefulWidget {
  final Map<String, dynamic> contenuto;

  const LinguettaSave({super.key, required this.contenuto});

  @override
  State<LinguettaSave> createState() => _LinguettaSaveState();
}

class _LinguettaSaveState extends State<LinguettaSave> {
  static const _key = 'preferiti';
  bool _salvato = false;

  @override
  void initState() {
    super.initState();
    _controllaSalvataggio();
  }

  Future<void> _controllaSalvataggio() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final json = jsonEncode(widget.contenuto);
    setState(() {
      _salvato = lista.contains(json);
    });
  }

  Future<void> _toggleSalvataggio() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final json = jsonEncode(widget.contenuto);

    setState(() {
      if (_salvato) {
        lista.remove(json);
        _salvato = false;
      } else {
        lista.add(json);
        _salvato = true;
      }
      prefs.setStringList(_key, lista);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _salvato ? Icons.bookmark : Icons.bookmark_border,
        color: _salvato ? Colors.amber : Colors.grey,
      ),
      onPressed: _toggleSalvataggio,
    );
  }
}
