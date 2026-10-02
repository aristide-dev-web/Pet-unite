import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JournalStorage {
  static const _key = 'preferiti';

  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    return lista.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> save(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final json = jsonEncode(item);
    if (!lista.contains(json)) {
      lista.add(json);
      await prefs.setStringList(_key, lista);
    }
  }

  static Future<void> remove(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final json = jsonEncode(item);
    lista.remove(json);
    await prefs.setStringList(_key, lista);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> isSaved(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    final json = jsonEncode(item);
    return lista.contains(json);
  }
}