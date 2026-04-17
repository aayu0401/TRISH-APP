import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/match.dart';
import '../models/user.dart';
import 'auth_service.dart';

class MatchService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> swipe({
    required int targetUserId,
    required String swipeType, // 'LIKE', 'PASS', 'SUPER_LIKE'
  }) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/swipes'),
      headers: headers,
      body: jsonEncode({
        'targetUserId': targetUserId,
        'type': swipeType,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process swipe');
    }
  }

  Future<List<Match>> getMatches() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/matches'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<Map<String, dynamic>> rewind() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/rewind'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to rewind');
    }
  }

  Future<List<User>> getRecommendations() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/recommendations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recommendations');
    }
  }
}
