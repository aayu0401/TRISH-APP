import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/personality.dart';
import 'auth_service.dart';

class PersonalityService {
  final AuthService _authService = AuthService();

  Future<PersonalityProfile?> getPersonalityProfile([String? userId]) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      String url = '$API_URL/api/personality/profile';
      if (userId != null) {
        url += '?userId=$userId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return PersonalityProfile.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching personality profile: $e');
      return null;
    }
  }

  Future<bool> updatePersonalityProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$API_URL/api/personality/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(profileData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating personality profile: $e');
      return false;
    }
  }

  Future<bool> takePersonalityTest({
    required String testType,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/personality/test'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'testType': testType,
          'answers': answers,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting personality test: $e');
      return false;
    }
  }

  Future<CompatibilityAnalysis?> getCompatibilityAnalysis(String userId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/personality/compatibility/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return CompatibilityAnalysis.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching compatibility analysis: $e');
      return null;
    }
  }

  Future<List<PersonalityInsight>> getPersonalityInsights() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/personality/insights'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((i) => PersonalityInsight.fromJson(i)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching personality insights: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMBTIProfile() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/personality/mbti'),
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
      print('Error fetching MBTI profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEnneagramProfile() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/personality/enneagram'),
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
      print('Error fetching Enneagram profile: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMatchRecommendations() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/personality/recommendations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching match recommendations: $e');
      return [];
    }
  }
}
