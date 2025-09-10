import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- NEW: Import Cloud Firestore
import 'package:ui_satnetcom_customer_services/models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  // These in-memory maps are good for quick local updates
  // However, for persistent status, your UI displaying the status
  // might eventually want to stream it directly from Firestore.
  // For this specific request, we'll keep them and update them after Firestore.
  final Map<String, List<ChatMessage>> _messagesPerTicket = {
    '123': [
      ChatMessage(message: 'Halo, ada yang bisa dibantu?', isUser: false),
      ChatMessage(message: 'Ya, saya ada kendala.', isUser: true),
    ],
  };

  final Map<String, String> _statusPerTicket = {'123': 'Unresolved'};

  // Ambil semua pesan berdasarkan ticket
  List<ChatMessage> getMessages(String userId) {
    return _messagesPerTicket[userId] ?? [];
  }

  // Ambil status ticket
  String getStatus(String userId) {
    return _statusPerTicket[userId] ?? 'Unresolved';
  }

  // Kirim pesan dari user (This is likely from the customer's app, not the admin panel's _sendMessage)
  void sendMessage(String userId, String message) {
    final newMessage = ChatMessage(message: message, isUser: true);
    _messagesPerTicket.putIfAbsent(userId, () => []);
    _messagesPerTicket[userId]!.add(newMessage);
    notifyListeners();
  }

  // Toggle status (Unresolved <-> Solved) - This specific toggle isn't used by your ChatScreen buttons,
  // but keeping it if other parts of your app use it.
  void toggleStatus(String userId) {
    final currentStatus = _statusPerTicket[userId] ?? 'Unresolved';
    _statusPerTicket[userId] = currentStatus == 'Solved'
        ? 'Unresolved'
        : 'Solved';
    notifyListeners();
  }

  // ✅ Set status manual dari luar (misalnya dari ChatScreen)
  // THIS IS THE METHOD WE ARE UPDATING TO INTERACT WITH FIRESTORE!
  Future<void> updateStatus(String userId, String newStatus) async {
    // <--- Made this method async
    try {
      // Update the status field in the corresponding complaint document in Firestore
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(userId)
          .update({'status': newStatus});

      // After successful Firestore update, update the in-memory state
      // and notify listeners for immediate UI feedback.
      _statusPerTicket[userId] = newStatus;
      notifyListeners();
      print(
        'DEBUG (ChatProvider): Status for ticket $userId updated to $newStatus in Firestore.',
      );
    } catch (e) {
      print(
        'ERROR (ChatProvider): Failed to update status for ticket $userId in Firestore: $e',
      );
      // You might want to add more robust error handling here,
      // such as showing a user-friendly error message (e.g., via a SnackBar)
      // or re-throwing the error if you want the calling code to handle it.
    }
  }
}
