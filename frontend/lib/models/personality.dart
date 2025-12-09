class PersonalityProfile {
  final String userId;
  final Map<String, int> traits;
  final List<String> interests;
  final List<String> values;
  final String loveLanguage;
  final String communicationStyle;
  final String attachmentStyle;
  final Map<String, dynamic> mbtiProfile;
  final Map<String, dynamic> enneagramProfile;
  final int compatibilityScore;
  final List<PersonalityInsight> insights;
  final DateTime lastUpdated;

  PersonalityProfile({
    required this.userId,
    required this.traits,
    required this.interests,
    required this.values,
    required this.loveLanguage,
    required this.communicationStyle,
    required this.attachmentStyle,
    required this.mbtiProfile,
    required this.enneagramProfile,
    this.compatibilityScore = 0,
    required this.insights,
    required this.lastUpdated,
  });

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) {
    return PersonalityProfile(
      userId: json['userId'] ?? '',
      traits: Map<String, int>.from(json['traits'] ?? {}),
      interests: List<String>.from(json['interests'] ?? []),
      values: List<String>.from(json['values'] ?? []),
      loveLanguage: json['loveLanguage'] ?? '',
      communicationStyle: json['communicationStyle'] ?? '',
      attachmentStyle: json['attachmentStyle'] ?? '',
      mbtiProfile: json['mbtiProfile'] ?? {},
      enneagramProfile: json['enneagramProfile'] ?? {},
      compatibilityScore: json['compatibilityScore'] ?? 0,
      insights: (json['insights'] as List?)
              ?.map((i) => PersonalityInsight.fromJson(i))
              .toList() ??
          [],
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'traits': traits,
      'interests': interests,
      'values': values,
      'loveLanguage': loveLanguage,
      'communicationStyle': communicationStyle,
      'attachmentStyle': attachmentStyle,
      'mbtiProfile': mbtiProfile,
      'enneagramProfile': enneagramProfile,
      'compatibilityScore': compatibilityScore,
      'insights': insights.map((i) => i.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class PersonalityInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final int importance;
  final String? iconUrl;

  PersonalityInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.importance = 5,
    this.iconUrl,
  });

  factory PersonalityInsight.fromJson(Map<String, dynamic> json) {
    return PersonalityInsight(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: InsightType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => InsightType.general,
      ),
      importance: json['importance'] ?? 5,
      iconUrl: json['iconUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'importance': importance,
      'iconUrl': iconUrl,
    };
  }
}

class CompatibilityAnalysis {
  final String userId1;
  final String userId2;
  final int overallScore;
  final Map<String, int> categoryScores;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> recommendations;
  final String summary;
  final DateTime analyzedAt;

  CompatibilityAnalysis({
    required this.userId1,
    required this.userId2,
    required this.overallScore,
    required this.categoryScores,
    required this.strengths,
    required this.challenges,
    required this.recommendations,
    required this.summary,
    required this.analyzedAt,
  });

  factory CompatibilityAnalysis.fromJson(Map<String, dynamic> json) {
    return CompatibilityAnalysis(
      userId1: json['userId1'] ?? '',
      userId2: json['userId2'] ?? '',
      overallScore: json['overallScore'] ?? 0,
      categoryScores: Map<String, int>.from(json['categoryScores'] ?? {}),
      strengths: List<String>.from(json['strengths'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      summary: json['summary'] ?? '',
      analyzedAt: DateTime.parse(json['analyzedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId1': userId1,
      'userId2': userId2,
      'overallScore': overallScore,
      'categoryScores': categoryScores,
      'strengths': strengths,
      'challenges': challenges,
      'recommendations': recommendations,
      'summary': summary,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}

enum InsightType {
  strength,
  weakness,
  opportunity,
  compatibility,
  warning,
  general,
}
