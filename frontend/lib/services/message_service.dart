import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/message.dart';
import 'auth_service.dart';

class MessageService {
  final AuthService _authService = AuthService();

  Future<Message> sendMessage({
    required int matchId,
    required String content,
  }) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/messages'),
      headers: headers,
      body: jsonEncode({
        'matchId': matchId,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<List<Message>> getConversation(int matchId) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/messages/match/$matchId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversation');
    }
  }

  Future<void> markAsRead(int messageId) async {
    final headers = await _authService.getAuthHeaders();
    await http.put(
      Uri.parse('$API_URL/api/messages/$messageId/read'),
      headers: headers,
    );
  }

  Future<int> getUnreadCount() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/messages/unread-count'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    } else {
      return 0;
    }
  }
}
