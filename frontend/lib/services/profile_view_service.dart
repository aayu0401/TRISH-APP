import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class ProfileViewService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getWhoViewedMe({int page = 0, int size = 20}) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/profile-views?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile views');
    }
  }

  Future<int> getViewCount() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/profile-views/count'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    } else {
      return 0;
    }
  }

  Future<void> recordView(int viewedUserId) async {
    final headers = await _authService.getAuthHeaders();
    await http.post(
      Uri.parse('$API_URL/api/profile-views/record?viewedUserId=$viewedUserId'),
      headers: headers,
    );
  }
}
