import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _addBotMessage("Hello! I'm your AI assistant. How can I help you today?");
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();

    // Add user message
    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    userMessage.animationController.forward();
    _scrollToBottom();

    // Simulate bot typing
    setState(() {
      _isTyping = true;
    });

    // Simulate bot response delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isTyping = false;
      });
      _addBotMessage(_generateBotResponse(text));
    });
  }

  void _addBotMessage(String text) {
    ChatMessage botMessage = ChatMessage(
      text: text,
      isUser: false,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    setState(() {
      _messages.insert(0, botMessage);
    });

    botMessage.animationController.forward();
    _scrollToBottom();
  }

  String _generateBotResponse(String userMessage) {
    // Simple bot responses for demonstration
    String message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi')) {
      return "Hello there! Nice to meet you. What would you like to talk about?";
    } else if (message.contains('how are you')) {
      return "I'm doing great, thank you for asking! I'm here and ready to help you with anything you need.";
    } else if (message.contains('weather')) {
      return "I don't have access to real-time weather data, but I'd recommend checking your local weather app for the most accurate forecast!";
    } else if (message.contains('help')) {
      return "I'm here to help! You can ask me questions, have a conversation, or just chat about anything that's on your mind.";
    } else if (message.contains('bye') || message.contains('goodbye')) {
      return "Goodbye! It was great chatting with you. Feel free to come back anytime!";
    } else {
      return "That's interesting! Tell me more about that, or feel free to ask me anything else.";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.yellow),
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _handleSubmitted(_textController.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.yellow,
            radius: 16,
            child: Icon(Icons.smart_toy, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      )..repeat(),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0,
              -4 *
                  (0.5 -
                          (DateTime.now().millisecondsSinceEpoch / 600 +
                                  index * 0.2) %
                              1)
                      .abs()),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.yellow,
              radius: 18,
              child: Icon(Icons.smart_toy, color: Colors.black),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Assistant', style: TextStyle(fontSize: 18)),
                Text('Online',
                    style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return _buildTypingIndicator();
                }
                int messageIndex = _isTyping ? index - 1 : index;
                return _messages[messageIndex];
              },
            ),
          ),
          Divider(height: 1.0, color: Colors.yellow.withOpacity(0.2)),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF1F1F1F)),
            child: _buildTextComposer(),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final AnimationController animationController;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              const CircleAvatar(
                backgroundColor: Colors.yellow,
                radius: 16,
                child: Text("AI"),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isUser ? Colors.yellow : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isUser ? Colors.black : Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey[700],
                radius: 16,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
