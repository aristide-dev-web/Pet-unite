import 'dart:io';
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:petping/ai/ai_service.dart';

class OCRService {
  final AIService _aiService = AIService();

  Future<Map<String, String>?> scanDocument(File image) async {
    print("AI: --- AVVIO SCANNER IBRIDO (OCR + GEMINI BACKEND) ---");
    
    try {
      // 1. Lettura immagine
      final bytes = await image.readAsBytes();

      // 2. Chiamata a Gemini tramite AIService
      final aiResponse = await _aiService.sendMessage(
        "Analizza questa immagine di un documento d'identità italiano ed estrai Nome, Cognome e Data di Nascita. "
        "Rispondi ESCLUSIVAMENTE con un oggetto JSON così formato: "
        '{"nome": "...", "cognome": "...", "dataNascita": "DD/MM/YYYY"}. '
        "Se un campo non è leggibile o non presente, scrivi una stringa vuota.",
        imageBytes: bytes,
      );

      print("AI Backend Response: $aiResponse");

      Map<String, String> extractedData = {
        'nome': '',
        'cognome': '',
        'dataNascita': '',
      };

      try {
        // Pulizia risposta AI avanzata per estrarre solo il JSON (rimuove markdown o testo extra)
        String cleanJson = aiResponse.trim();
        if (cleanJson.contains("{")) {
          int start = cleanJson.indexOf("{");
          int end = cleanJson.lastIndexOf("}") + 1;
          cleanJson = cleanJson.substring(start, end);
          
          final Map<String, dynamic> decoded = json.decode(cleanJson);
          extractedData['nome'] = decoded['nome']?.toString().toUpperCase() ?? "";
          extractedData['cognome'] = decoded['cognome']?.toString().toUpperCase() ?? "";
          extractedData['dataNascita'] = decoded['dataNascita']?.toString() ?? "";
        }
      } catch (e) {
        print("Errore parsing AI JSON: $e");
      }

      // 3. OCR Locale di Backup (se la data è mancante)
      if (extractedData['dataNascita']!.isEmpty) {
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final inputImage = InputImage.fromFile(image);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        String fullText = "";
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            fullText += "${line.text} ";
          }
        }
        
        RegExp dateRegExp = RegExp(r'(\d{2})[\/\-\.\s](\d{2})[\/\-\.\s](\d{4})');
        final match = dateRegExp.firstMatch(fullText);
        if (match != null) {
          extractedData['dataNascita'] = match.group(0)!.replaceAll(RegExp(r'[\-\.\s]'), '/');
        }
        await textRecognizer.close();
      }

      // Validazione minima: se non abbiamo nemmeno la data, lo scanner è fallito
      if (extractedData['dataNascita']!.isNotEmpty) {
        return extractedData;
      }
      return null;
    } catch (e) {
      print("Scanner Error: $e");
      return null;
    }
  }

  static bool isAdult(String birthDateStr) {
    try {
      DateTime birthDate = DateFormat('dd/MM/yyyy').parse(birthDateStr);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) age--;
      return age >= 18;
    } catch (e) { return false; }
  }
}
