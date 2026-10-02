import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IdVerificationService {
  // Configurazione IDAnalyzer (da mettere in un file vault o .env in produzione)
  final String _apiKey = "";
  final String _apiRegion = "https://api.idanalyzer.com"; // O us.api.idanalyzer.com

  /// Logica "Esperta": Prima prova l'OCR locale (Placeholder per ora)
  /// Se l'OCR locale conferma che è un documento, allora chiama IDAnalyzer.
  Future<Map<String, dynamic>> verifyIdentity({
    required File documentFront,
    required File selfie,
  }) async {
    try {
      // 1. Placeholder per OCR Locale (Gratis)
      // Qui implementeremo ML Kit per estrarre nome/cognome senza costi.
      print("Esecuzione OCR locale gratis...");

      // 2. Chiamata a IDAnalyzer (Costo: 0,05€)
      // Inviamo i dati solo se il controllo locale è superato.
      var request = http.MultipartRequest('POST', Uri.parse(_apiRegion));
      request.fields['apikey'] = _apiKey;
      request.fields['verify_face'] = '1'; // Confronta documento con selfie
      
      request.files.add(await http.MultipartFile.fromPath('document', documentFront.path));
      request.files.add(await http.MultipartFile.fromPath('face', selfie.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonDecoded = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecoded,
          'isReal': jsonDecoded['face']['is_identical'] ?? false,
        };
      } else {
        return {'success': false, 'error': 'Errore API Analyzer'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
