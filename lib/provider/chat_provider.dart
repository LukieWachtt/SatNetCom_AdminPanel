import 'package:flutter/material.dart';
import 'package:ui_satnetcom_customer_services/models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<ChatMessage>> _messagesPerTicket = {
    '123': [
      ChatMessage(message: 'Halo, ada yang bisa dibantu?', isUser: false),
      ChatMessage(message: 'Ya, saya ada kendala.', isUser: true),
    ],
  };

  final Map<String, String> _statusPerTicket = {
    '123': 'Unresolved',
  };

  // Ambil semua pesan berdasarkan ticket
  List<ChatMessage> getMessages(String ticketNo) {
    return _messagesPerTicket[ticketNo] ?? [];
  }

  // Ambil status ticket
  String getStatus(String ticketNo) {
    return _statusPerTicket[ticketNo] ?? 'Unresolved';
  }

  // Kirim pesan dari user
  void sendMessage(String ticketNo, String message) {
    final newMessage = ChatMessage(message: message, isUser: true);
    _messagesPerTicket.putIfAbsent(ticketNo, () => []);
    _messagesPerTicket[ticketNo]!.add(newMessage);
    notifyListeners();
  }

  // Toggle status (Unresolved <-> Solved)
  void toggleStatus(String ticketNo) {
    final currentStatus = _statusPerTicket[ticketNo] ?? 'Unresolved';
    _statusPerTicket[ticketNo] =
        currentStatus == 'Solved' ? 'Unresolved' : 'Solved';
    notifyListeners();
  }

  // ✅ Set status manual dari luar (misalnya dari ChatScreen)
  void updateStatus(String ticketNo, String newStatus) {
    _statusPerTicket[ticketNo] = newStatus;
    notifyListeners();
  }
}
