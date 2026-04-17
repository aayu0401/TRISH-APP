
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

class WingmanMessage {
  final String content;
  final bool isUser;
  final List<String>? suggestions;

  WingmanMessage({required this.content, required this.isUser, this.suggestions});
}

class WingmanScreen extends StatefulWidget {
  const WingmanScreen({super.key});

  @override
  State<WingmanScreen> createState() => _WingmanScreenState();
}

class _WingmanScreenState extends State<WingmanScreen> {
  final _aiService = AIService();
  final _messageController = TextEditingController();
  final List<WingmanMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial welcome message
    _messages.add(WingmanMessage(
      content: "Hey there! I'm Trish, your personal dating wingman. 🧞‍♀️\n\nI can help you craft the perfect opener, analyze your profile, or just give you a pep talk before a date. What's on your mind?",
      isUser: false,
      suggestions: ["Help me with an opener", "Analyze my profile", "I'm feeling nervous"],
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(WingmanMessage(content: text, isUser: true));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.chatWithWingman(
        message: text,
        context: "User is asking for dating advice",
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          if (response != null) {
            List<String>? suggestions;
            if (response['suggested_actions'] != null) {
              suggestions = List<String>.from(response['suggested_actions']);
            }
            
            _messages.add(WingmanMessage(
              content: response['response'] ?? "I'm listening...",
              isUser: false,
              suggestions: suggestions,
            ));
          } else {
             _messages.add(WingmanMessage(
              content: "I'm having a bit of trouble connecting to my brain right now. Try again?",
              isUser: false,
            ));
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(WingmanMessage(
            content: "Oops, something went wrong. Connectivity issue?",
            isUser: false,
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Mystical Purple-Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const CircleAvatar(
                radius: 16,
                 // Placeholder for AI Avatar or Icon
                backgroundColor: Color(0xFF6A11CB),
                child: Icon(Icons.auto_awesome, size: 20, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trish AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Your Dating Wingman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F5), Color(0xFFF3E5F5)], // Soft Pink to Soft Purple (Light)
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Chat List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                     return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, right: 80),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const SizedBox(
                          width: 40,
                          height: 20,
                          child: Center(
                            child: Text("...", style: TextStyle(color: AppTheme.primaryPink, fontSize: 24, height: 0.5)),
                          ),
                        ),
                      ),
                    );
                  }

                  final msg = _messages[index];
                  final isMe = msg.isUser;

                  return Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            gradient: isMe 
                              ? AppTheme.primaryGradient 
                              : null,
                            color: isMe ? null : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                            ),
                            boxShadow: isMe ? [
                              BoxShadow(
                                color: AppTheme.primaryPink.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : AppTheme.textPrimary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      
                      // Suggestions Chips
                      if (!isMe && msg.suggestions != null && msg.suggestions!.isNotEmpty && index == _messages.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, left: 4),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: msg.suggestions!.map((s) => ActionChip(
                              label: Text(s),
                              backgroundColor: Colors.white,
                              labelStyle: const TextStyle(color: AppTheme.primaryPink, fontSize: 12, fontWeight: FontWeight.w600),
                              avatar: const Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryPink),
                              shape: const StadiumBorder(side: BorderSide(color: AppTheme.primaryPink)),
                              elevation: 2,
                              onPressed: () => _sendMessage(s),
                            )).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic, color: AppTheme.primaryPink),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Voice Mode coming soon! 🎙️')),
                         );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ask Trish anything...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceColor.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
