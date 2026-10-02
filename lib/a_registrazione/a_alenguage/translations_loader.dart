import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class MultiFileAssetLoader extends AssetLoader {
  const MultiFileAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final String langCode = locale.languageCode;
    Map<String, dynamic> combinedTranslations = {};

    try {
      // 1. Carica il file Master (es. assets/langs/it.json)
      final String masterJsonContent = await rootBundle.loadString('assets/langs/$langCode.json');
      final Map<String, dynamic> masterData = json.decode(masterJsonContent);
      
      // Aggiunge eventuali chiavi globali presenti nel master
      combinedTranslations.addAll(masterData);

      // 2. Legge la lista degli "imports" dal file master
      if (masterData.containsKey('imports') && masterData['imports'] is List) {
        List<dynamic> modules = masterData['imports'];
        
        for (dynamic module in modules) {
          if (module is String) {
            try {
              // Carica ogni modulo dalla cartella specifica (es. assets/langs/it/common.json)
              final String moduleContent = await rootBundle.loadString('assets/langs/$langCode/$module.json');
              final Map<String, dynamic> moduleData = json.decode(moduleContent);
              
              combinedTranslations.addAll(moduleData);
            } catch (e) {
              debugPrint("⚠️ Errore caricamento modulo '$module' per $langCode: $e");
            }
          }
        }
      }
    } catch (e) {
      debugPrint("🚨 Errore critico caricamento file master per $langCode: $e");
    }

    return combinedTranslations;
  }
}
