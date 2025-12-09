import 'user.dart';

class Message {
  final int id;
  final int matchId;
  final User sender;
  final User receiver;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.matchId,
    required this.sender,
    required this.receiver,
    required this.content,
    this.isRead = false,
    this.readAt,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      matchId: json['match']['id'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}
