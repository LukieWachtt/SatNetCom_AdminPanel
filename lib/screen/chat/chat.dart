import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ui_satnetcom_customer_services/provider/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String ticketNo;

  const ChatScreen({required this.ticketNo, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _showStatusMenu = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('=== CHAT SCREEN DEBUG ===');
    print('Document ID: "${widget.ticketNo}"');
    print('Document path: complaints/${widget.ticketNo}/messages');
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      print('Sending message to document: ${widget.ticketNo}');

      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.ticketNo) // Use document ID directly
          .collection('messages')
          .add({
            'message': text,
            'sender': 'admin',
            'timestamp': FieldValue.serverTimestamp(),
          });

      print('Message sent successfully!');
      _controller.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Ticket No. ${widget.ticketNo}"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                _showStatusMenu = !_showStatusMenu;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('complaints')
                        .doc(widget.ticketNo) // Use document ID directly
                        .collection('messages')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print('Stream error: ${snapshot.error}');
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      print('Found ${docs.length} messages for ticket ${widget.ticketNo}');

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text('No messages yet. Start the conversation!'),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final message = docs[index];
                          final data = message.data() as Map<String, dynamic>;
                          final String senderType =
                              data['sender'] as String? ?? 'admin';
                          final bool isMessageFromCustomer =
                              (senderType == 'admin');

                          return Align(
                            alignment: isMessageFromCustomer
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isMessageFromCustomer
                                    ? Colors.blue
                                    : Colors.grey[300],
                                borderRadius: isMessageFromCustomer
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      )
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                data['message'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isMessageFromCustomer
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Input field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_showStatusMenu)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Change status", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          chatProvider.updateStatus(
                            widget.ticketNo,
                            'Unresolved',
                          );
                          setState(() => _showStatusMenu = false);
                        },
                        child: const Text(
                          "Unresolved",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          chatProvider.updateStatus(widget.ticketNo, 'Solved');
                          setState(() => _showStatusMenu = false);
                        },
                        child: const Text(
                          "Solved",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}