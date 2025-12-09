import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/ai_assistant.dart';
import 'auth_service.dart';

class AIService {
  final AuthService _authService = AuthService();

  Future<List<AISuggestion>> getChatSuggestions({
    required String matchId,
    String? lastMessage,
    String? context,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.post(
        Uri.parse('$API_URL/api/ai/chat-suggestions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'matchId': matchId,
          'lastMessage': lastMessage,
          'context': context,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((s) => AISuggestion.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching chat suggestions: $e');
      return [];
    }
  }

  Future<List<Icebreaker>> getIcebreakers({
    required String matchId,
    String? category,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      String url = '$API_URL/api/ai/icebreakers?matchId=$matchId';
      if (category != null) {
        url += '&category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((i) => Icebreaker.fromJson(i)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching icebreakers: $e');
      return [];
    }
  }

  Future<ConversationAnalysis?> analyzeConversation(String matchId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/ai/analyze-conversation/$matchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ConversationAnalysis.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error analyzing conversation: $e');
      return null;
    }
  }

  Future<String?> generateResponse({
    required String matchId,
    required String prompt,
    String? tone,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$API_URL/api/ai/generate-response'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'matchId': matchId,
          'prompt': prompt,
          'tone': tone,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'];
      }
      return null;
    } catch (e) {
      print('Error generating response: $e');
      return null;
    }
  }

  Future<List<String>> detectRedFlags({
    required String matchId,
    required String message,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.post(
        Uri.parse('$API_URL/api/ai/detect-red-flags'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'matchId': matchId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['redFlags'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error detecting red flags: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSafetyScore(String matchId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/ai/safety-score/$matchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching safety score: $e');
      return null;
    }
  }

  Future<List<String>> getConversationTopics(String matchId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/ai/conversation-topics/$matchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['topics'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching conversation topics: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRelationshipInsights(String matchId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/ai/relationship-insights/$matchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching relationship insights: $e');
      return null;
    }
  }
}
