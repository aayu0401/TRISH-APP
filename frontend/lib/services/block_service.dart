import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class BlockService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> blockUser(int userId, {String? reason}) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$API_URL/api/block/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unblockUser(int userId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$API_URL/api/block/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<dynamic>> getBlockedUsers() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$API_URL/api/block/list'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['blockedUsers'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> isBlocked(int userId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$API_URL/api/block/check/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data['isBlocked'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
