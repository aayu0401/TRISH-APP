import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String _extractErrorMessage(http.Response response, String fallback) {
    try {
      final body = response.body;
      if (body.trim().isEmpty) return fallback;
      final decoded = jsonDecode(body);
      if (decoded is String && decoded.trim().isNotEmpty) return decoded;
      if (decoded is Map) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) return message;
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) return error;
      }
      return fallback;
    } catch (_e) {
      final body = response.body;
      return body.trim().isNotEmpty ? body : fallback;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    final response = await http.post(
      Uri.parse('$API_URL/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0],
        'gender': gender,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      await _saveUserId(data['userId']);
      return data;
    } else {
      throw Exception(_extractErrorMessage(response, 'Registration failed'));
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$API_URL/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      await _saveUserId(data['userId']);
      return data;
    } else {
      throw Exception(_extractErrorMessage(response, 'Login failed'));
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  Future<String?> getToken() async {
    final secure = await _secureStorage.read(key: _tokenKey);
    if (secure != null && secure.trim().isNotEmpty) return secure;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> sendVerificationEmail() async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/auth/send-verification'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send verification email');
    }
  }

  Future<bool> verifyEmail(String token) async {
    final response = await http.post(
      Uri.parse('$API_URL/api/auth/verify-email?token=$token'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  Future<int?> getUserId() async {
    final secure = await _secureStorage.read(key: _userIdKey);
    if (secure != null && secure.trim().isNotEmpty) {
      final parsed = int.tryParse(secure);
      if (parsed != null) return parsed;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUserId(int userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId.toString());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
