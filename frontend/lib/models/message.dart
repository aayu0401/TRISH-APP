import 'user.dart';

enum MessageType { text, gift, system }

extension MessageTypeX on MessageType {
  static MessageType fromApi(dynamic raw) {
    final value = raw?.toString().toUpperCase();
    switch (value) {
      case 'GIFT':
        return MessageType.gift;
      case 'SYSTEM':
        return MessageType.system;
      case 'TEXT':
      default:
        return MessageType.text;
    }
  }
}

class Message {
  final int id;
  final int matchId;
  final User sender;
  final User receiver;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime sentAt;
  final MessageType messageType;
  final int? referenceId;

  Message({
    required this.id,
    required this.matchId,
    required this.sender,
    required this.receiver,
    required this.content,
    this.isRead = false,
    this.readAt,
    required this.sentAt,
    this.messageType = MessageType.text,
    this.referenceId,
  });

  DateTime get timestamp => sentAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    final rawMatch = json['match'];
    final matchId = rawMatch is Map ? rawMatch['id'] : json['matchId'];
    final parsedMatchId = matchId is int ? matchId : int.tryParse(matchId?.toString() ?? '') ?? 0;

    return Message(
      id: json['id'],
      matchId: parsedMatchId,
      sender: User.fromJson(Map<String, dynamic>.from(json['sender'] as Map)),
      receiver: User.fromJson(Map<String, dynamic>.from(json['receiver'] as Map)),
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sentAt: DateTime.parse(json['sentAt']),
      messageType: MessageTypeX.fromApi(json['messageType']),
      referenceId: json['referenceId'] is int
          ? json['referenceId']
          : int.tryParse(json['referenceId']?.toString() ?? ''),
    );
  }
}
