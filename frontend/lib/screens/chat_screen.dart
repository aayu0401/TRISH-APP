import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/match.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';
import '../services/gift_service.dart';
import '../widgets/chat_bubble.dart';
import '../utils/app_snackbar.dart';
import 'gifts_screen.dart';
import 'video_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final Match match;

  const ChatScreen({super.key, required this.match});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageService = MessageService();
  final _authService = AuthService();
  final _giftService = GiftService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  int? _currentUserId;
  Timer? _pollTimer;
  bool _isSending = false;
  final Set<int> _acceptingGiftTransactions = <int>{};

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _loadMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent && mounted) setState(() => _isLoading = true);
    try {
      _currentUserId ??= await _authService.getUserId();
      final messages = await _messageService.getConversation(widget.match.id);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (!silent) AppSnackBar.error(context, 'Failed to load messages');
      }
    }
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);
    try {
      final message = await _messageService.sendMessage(
        matchId: widget.match.id,
        content: content,
      );
      if (mounted) {
        setState(() {
          _messages.add(message);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        AppSnackBar.error(context, 'Failed to send message');
        _messageController.text = content;
      }
    }
  }

  Future<void> _acceptGift(int transactionId) async {
    if (_acceptingGiftTransactions.contains(transactionId)) return;

    setState(() => _acceptingGiftTransactions.add(transactionId));
    try {
      final success = await _giftService.acceptGift(transactionId);
      if (!mounted) return;

      if (success) {
        AppSnackBar.success(context, 'Gift accepted! 🎁');
        await _loadMessages(silent: true);
      } else {
        AppSnackBar.error(context, 'Unable to accept gift');
      }
    } catch (_e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Failed to accept gift');
    } finally {
      if (!mounted) return;
      setState(() => _acceptingGiftTransactions.remove(transactionId));
    }
  }

  void _onVideoCallPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(match: widget.match, isInitiator: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.match.getOtherUser(_currentUserId ?? 0);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: () {
            // TODO: Navigate to profile
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.surfaceColor,
                    backgroundImage: otherUser.photos.isNotEmpty
                        ? NetworkImage(otherUser.photos.first.url)
                        : null,
                    child: otherUser.photos.isEmpty
                        ? const Icon(Icons.person_rounded, color: AppTheme.textSecondary)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      otherUser.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: _onVideoCallPressed,
            color: AppTheme.primaryPink,
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard_rounded),
            onPressed: () {
              final receiverId = otherUser.id;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GiftsScreen(
                    receiverId: receiverId,
                    receiverName: otherUser.name,
                  ),
                ),
              );
            },
            color: AppTheme.primaryPink,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
            color: AppTheme.textSecondary,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBackground, AppTheme.cardBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primaryPink,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading conversation...',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPink.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 64,
                                  color: AppTheme.primaryPink.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Say hello!',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start the conversation with ${otherUser.name}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMessages,
                          color: AppTheme.primaryPink,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isMe = message.sender.id == _currentUserId;
                              final avatarUrl = isMe
                                  ? null
                                  : (otherUser.photos.isNotEmpty ? otherUser.photos.first.url : null);

                              if (message.messageType == MessageType.system) {
                                return _buildSystemMessage(message);
                              }

                              if (message.messageType == MessageType.gift) {
                                return _buildGiftMessage(message, isMe, avatarUrl);
                              }

                              return ChatBubble(
                                message: message,
                                isMe: isMe,
                                showAvatar: true,
                                avatarUrl: avatarUrl,
                              );
                            },
                          ),
                        ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            message.content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGiftMessage(Message message, bool isMe, String? avatarUrl) {
    final referenceId = message.referenceId;
    final canAccept = !isMe && referenceId != null;
    final isAccepting = canAccept && _acceptingGiftTransactions.contains(referenceId);

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ChatBubble(
          message: message,
          isMe: isMe,
          showAvatar: true,
          avatarUrl: avatarUrl,
        ),
        if (canAccept)
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 16 : 64,
              right: isMe ? 64 : 16,
              bottom: 8,
            ),
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: isAccepting ? null : () => _acceptGift(referenceId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isAccepting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Accept Gift',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.surfaceColor.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                onPressed: _isSending ? null : _sendMessage,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
