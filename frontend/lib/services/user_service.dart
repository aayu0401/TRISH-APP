import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/user.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  Future<User> getProfile() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/users/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<User> getUserById(int id) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/users/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.put(
      Uri.parse('$API_URL/api/users/profile'),
      headers: headers,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<User> updateLocation(double latitude, double longitude) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.put(
      Uri.parse('$API_URL/api/users/location'),
      headers: headers,
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update location');
    }
  }

  Future<User> updatePreferences({
    String? interestedInGender,
    int? minAge,
    int? maxAge,
    int? maxDistance,
  }) async {
    final headers = await _authService.getAuthHeaders();
    final body = <String, dynamic>{};
    
    if (interestedInGender != null) body['interestedInGender'] = interestedInGender;
    if (minAge != null) body['minAge'] = minAge;
    if (maxAge != null) body['maxAge'] = maxAge;
    if (maxDistance != null) body['maxDistance'] = maxDistance;

    final response = await http.put(
      Uri.parse('$API_URL/api/users/preferences'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update preferences');
    }
  }

  Future<Photo> uploadPhoto(File file) async {
    final token = await _authService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$API_URL/api/users/photos'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Photo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload photo');
    }
  }

  Future<void> deletePhoto(int photoId) async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$API_URL/api/users/photos/$photoId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo');
    }
  }

  Future<List<Photo>> getPhotos() async {
    final headers = await _authService.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$API_URL/api/users/photos'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }
}
