class AIAssistant {
  final String id;
  final String name;
  final String avatarUrl;
  final AIAssistantType type;
  final List<String> capabilities;
  final bool isActive;

  AIAssistant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.type,
    required this.capabilities,
    this.isActive = true,
  });

  factory AIAssistant.fromJson(Map<String, dynamic> json) {
    return AIAssistant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      type: AIAssistantType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AIAssistantType.general,
      ),
      capabilities: List<String>.from(json['capabilities'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'type': type.toString().split('.').last,
      'capabilities': capabilities,
      'isActive': isActive,
    };
  }
}

class AIMessage {
  final String id;
  final String conversationId;
  final String content;
  final AIMessageType type;
  final Map<String, dynamic>? metadata;
  final List<AISuggestion>? suggestions;
  final DateTime timestamp;
  final bool isFromUser;

  AIMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.type,
    this.metadata,
    this.suggestions,
    required this.timestamp,
    required this.isFromUser,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      content: json['content'] ?? '',
      type: AIMessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AIMessageType.text,
      ),
      metadata: json['metadata'],
      suggestions: (json['suggestions'] as List?)
          ?.map((s) => AISuggestion.fromJson(s))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isFromUser: json['isFromUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'type': type.toString().split('.').last,
      'metadata': metadata,
      'suggestions': suggestions?.map((s) => s.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
    };
  }
}

class AISuggestion {
  final String id;
  final String text;
  final SuggestionType type;
  final double confidence;
  final Map<String, dynamic>? metadata;

  AISuggestion({
    required this.id,
    required this.text,
    required this.type,
    this.confidence = 0.0,
    this.metadata,
  });

  factory AISuggestion.fromJson(Map<String, dynamic> json) {
    return AISuggestion(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      type: SuggestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SuggestionType.general,
      ),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'confidence': confidence,
      'metadata': metadata,
    };
  }
}

class Icebreaker {
  final String id;
  final String question;
  final String category;
  final List<String>? suggestedAnswers;
  final int popularity;

  Icebreaker({
    required this.id,
    required this.question,
    required this.category,
    this.suggestedAnswers,
    this.popularity = 0,
  });

  factory Icebreaker.fromJson(Map<String, dynamic> json) {
    return Icebreaker(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      category: json['category'] ?? '',
      suggestedAnswers: json['suggestedAnswers'] != null
          ? List<String>.from(json['suggestedAnswers'])
          : null,
      popularity: json['popularity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'suggestedAnswers': suggestedAnswers,
      'popularity': popularity,
    };
  }
}

class ConversationAnalysis {
  final String conversationId;
  final int messageCount;
  final double sentimentScore;
  final double engagementScore;
  final List<String> topics;
  final List<String> recommendations;
  final Map<String, dynamic> insights;
  final DateTime analyzedAt;

  ConversationAnalysis({
    required this.conversationId,
    required this.messageCount,
    required this.sentimentScore,
    required this.engagementScore,
    required this.topics,
    required this.recommendations,
    required this.insights,
    required this.analyzedAt,
  });

  factory ConversationAnalysis.fromJson(Map<String, dynamic> json) {
    return ConversationAnalysis(
      conversationId: json['conversationId'] ?? '',
      messageCount: json['messageCount'] ?? 0,
      sentimentScore: (json['sentimentScore'] ?? 0.0).toDouble(),
      engagementScore: (json['engagementScore'] ?? 0.0).toDouble(),
      topics: List<String>.from(json['topics'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      insights: json['insights'] ?? {},
      analyzedAt: DateTime.parse(json['analyzedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'messageCount': messageCount,
      'sentimentScore': sentimentScore,
      'engagementScore': engagementScore,
      'topics': topics,
      'recommendations': recommendations,
      'insights': insights,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}

enum AIAssistantType {
  general,
  dating,
  relationship,
  safety,
  personality,
}

enum AIMessageType {
  text,
  suggestion,
  icebreaker,
  warning,
  tip,
  analysis,
}

enum SuggestionType {
  reply,
  icebreaker,
  topic,
  compliment,
  question,
  general,
}
