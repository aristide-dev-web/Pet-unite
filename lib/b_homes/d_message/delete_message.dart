import 'package:hive_flutter/hive_flutter.dart';
import 'package:petping/b_homes/d_message/chat_preview.dart';
import 'package:petping/b_homes/d_message/message_model.dart';

class DeleteMessageService {
  /// Cancella la chat e tutti i relativi messaggi dalla lista locale (Hive)
  Future<void> deleteLocalChat(String chatId) async {
    try {
      // 1. Rimuovi l'anteprima della chat
      final chatBox = Hive.box<ChatPreview>('chatPreviews');
      await chatBox.delete(chatId);

      // 2. Chiudi e cancella la box dei messaggi specifica per questa chat
      final String messagesBoxName = 'messages_$chatId';
      
      // Controlliamo se la box è aperta, se sì la chiudiamo prima di cancellarla
      if (Hive.isBoxOpen(messagesBoxName)) {
        await Hive.box<Message>(messagesBoxName).close();
      }
      
      // Cancella definitivamente i dati dal disco
      await Hive.deleteBoxFromDisk(messagesBoxName);

      print("Chat e messaggi rimossi localmente con successo: $chatId");
    } catch (e) {
      print("Errore cancellazione locale chat e messaggi: $e");
    }
  }
}
