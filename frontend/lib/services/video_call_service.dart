import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class VideoCallService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    return await _authService.getAuthHeaders();
  }

  Future<Map<String, dynamic>> generateToken(int receiverId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/video/token?receiverId=$receiverId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to generate call token');
  }

  Future<Map<String, dynamic>> startCall(int receiverId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/video/start?receiverId=$receiverId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to start call');
  }

  Future<Map<String, dynamic>> answerCall(int callId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/video/$callId/answer'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to answer call');
  }

  Future<Map<String, dynamic>> endCall(int callId, {String? reason}) async {
    final headers = await _getHeaders();
    var url = '$API_URL/api/video/$callId/end';
    if (reason != null) {
      url += '?reason=${Uri.encodeComponent(reason)}';
    }
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to end call');
  }

  Future<Map<String, dynamic>> rejectCall(int callId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$API_URL/api/video/$callId/reject'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to reject call');
  }
}
