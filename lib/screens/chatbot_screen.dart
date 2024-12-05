import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final GenerativeModel _model;
  final String _prompt = "Hi, I am your friend😊. How can I help you today?";

  @override
  void initState() {
    super.initState();

    // API KEY - Jangan akses API key ini di sembarang tempat
    const String apiKey = "AIzaSyDhLHFgaDLP_XgFFERluG1_ePUnLKMwjI0";
    if (apiKey.isEmpty) {
      print('API Key is missing');
      exit(1);
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    _messages.add({"role": "bot", "content": _prompt});
  }

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      _messages.add({"role": "user", "content": userMessage});
      _isLoading = true;
    });

    try {
      final response =
          await _model.generateContent([Content.text(userMessage)]);
      final botReply =
          response.text ?? "I'm sorry, I couldn't process your message.";

      setState(() {
        _messages.add({"role": "bot", "content": botReply});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "bot",
          "content": "Oops! Something went wrong. Please try again later."
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF6b5b95) : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight:
                isUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Moodly Chatbot",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6b5b95),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["role"] == "user";
                return _buildChatBubble(message["content"]!, isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6b5b95),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final userMessage = _messageController.text.trim();
                    if (userMessage.isNotEmpty) {
                      _messageController.clear();
                      _sendMessage(userMessage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6b5b95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Send",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
