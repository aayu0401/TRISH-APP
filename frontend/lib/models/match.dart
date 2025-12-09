import 'user.dart';

class Match {
  final int id;
  final User user1;
  final User user2;
  final double? compatibilityScore;
  final DateTime matchedAt;
  final bool isActive;

  Match({
    required this.id,
    required this.user1,
    required this.user2,
    this.compatibilityScore,
    required this.matchedAt,
    this.isActive = true,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      compatibilityScore: json['compatibilityScore']?.toDouble(),
      matchedAt: DateTime.parse(json['matchedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  User getOtherUser(int currentUserId) {
    return user1.id == currentUserId ? user2 : user1;
  }
}
