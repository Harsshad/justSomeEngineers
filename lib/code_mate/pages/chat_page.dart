import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/code_mate/services/gemini_service.dart';
import 'package:codefusion/config.dart';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotChatScreen extends StatefulWidget {
  @override
  _BotChatScreenState createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> with SingleTickerProviderStateMixin {
  final BotGeminiService geminiService = BotGeminiService(Config.geminiApi);
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _sendButtonScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
    _loadMessages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        setState(() {
          _showScrollToBottomButton = true;
        });
      } else {
        setState(() {
          _showScrollToBottomButton = false;
        });
      }
    } else {
      setState(() {
        _showScrollToBottomButton = true;
      });
    }
  }

Future<void> _loadMessages() async {
  final user = _auth.currentUser;
  if (user == null) return;

  // Check if user is a mentor by looking in the mentors collection
  final mentorDoc = await _firestore.collection('mentors').doc(user.uid).get();
  final isMentor = mentorDoc.exists; // If document exists in mentors, user is a mentor

  // Choose the correct collection path
  final collectionPath = isMentor ? 'mentors' : 'users';

  final messagesSnapshot = await _firestore
      .collection(collectionPath)
      .doc(user.uid)
      .collection('bot_chat_messages')
      .orderBy('timestamp', descending: false)
      .get();

  setState(() {
    _messages.addAll(messagesSnapshot.docs.map((doc) => doc.data()));
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollToBottom();
  });
}



Future<void> _saveMessage(String text, bool isUser) async {
  final user = _auth.currentUser;
  if (user == null) return;

  // Check if user is a mentor by looking in the mentors collection
  final mentorDoc = await _firestore.collection('mentors').doc(user.uid).get();
  final isMentor = mentorDoc.exists; // If document exists in mentors, user is a mentor

  // Choose the correct Firestore path
  final collectionPath = isMentor ? 'mentors' : 'users';

  final message = {
    'text': text,
    'isUser': isUser,
    'timestamp': FieldValue.serverTimestamp(),
  };

  await _firestore
      .collection(collectionPath)
      .doc(user.uid)
      .collection('bot_chat_messages')
      .add(message);
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

    await _saveMessage(message, true);

    try {
      final response = await geminiService.getResponse(message);
      setState(() {
        _messages.add({'text': response, 'isUser': false});
      });
      await _saveMessage(response, false);
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Error: Failed to get response', 'isUser': false});
      });
      await _saveMessage('Error: Failed to get response', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ChatSearchDelegate(_messages));
            },
          ),
        ],
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
          if (_showScrollToBottomButton)
            Positioned(
              bottom: 70,
              right: 220,
              child: FloatingActionButton(
                backgroundColor: Colors.blueGrey,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward),
              ),
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

class ChatSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> messages;

  ChatSearchDelegate(this.messages);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = messages.where((message) => message['text'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final message = results[index];
        return ListTile(
          title: _highlightText(message['text'], query),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = messages.where((message) => message['text'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final message = suggestions[index];
        return ListTile(
          title: _highlightText(message['text'], query),
        );
      },
    );
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final matches = text.toLowerCase().allMatches(query.toLowerCase());
    if (matches.isEmpty) {
      return Text(text);
    }

    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(backgroundColor: Colors.yellow),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(text: TextSpan(style: const TextStyle(color: Colors.black), children: spans));
  }
}