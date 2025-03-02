import 'package:codefusion/code_mate/services/gemini_service.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotChatScreen extends StatefulWidget {
  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> with SingleTickerProviderStateMixin {
  final BotGeminiService geminiService = BotGeminiService('AIzaSyDzNOkzb-qUdtXEAWXIYKRtVWi438Lwh54');
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _sendButtonScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'text': message, 'isUser': true});
      _isLoading = true;
    });

    _controller.clear();
    _sendButtonController.forward().then((_) => _sendButtonController.reverse());

    try {
      final response = await geminiService.getResponse(message);
      setState(() {
        _messages.add({'text': response, 'isUser': false});
      });
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Error: Failed to get response', 'isUser': false});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Material(
          color: isUser ? Colors.blueAccent : Colors.grey[900],
          elevation: 5,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Material(
          color: Colors.grey[900],
          elevation: 5,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("CodeMate is typing", style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  height: 6,
                  child: Row(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 6,
                          width: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == 0) {
          return _buildTypingIndicator();
        }

        final message = _messages[_messages.length - 1 - (_isLoading ? index - 1 : index)];
        return _buildChatBubble(message['text'], message['isUser']);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          'CodeMate Chat',
          style: GoogleFonts.sourceCodePro(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 5,
        shadowColor: Colors.blueAccent.withOpacity(0.5),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(Constants.bannerDefault, fit: BoxFit.cover),
            ),
          ),
          Column(
            children: [
              Expanded(child: _buildChatList()),
              _buildChatInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.blueAccent,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ScaleTransition(
            scale: _sendButtonScale,
            child: GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
