import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/kyc.dart';
import 'auth_service.dart';

class KYCService {
  final AuthService _authService = AuthService();

  Future<KYCVerification?> getKYCStatus() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/kyc/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return KYCVerification.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching KYC status: $e');
      return null;
    }
  }

  Future<bool> submitKYC({
    required KYCType type,
    required Map<String, dynamic> documentData,
    required List<File> documentImages,
    File? selfieImage,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$API_URL/api/kyc/submit'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['type'] = type.toString().split('.').last;
      request.fields['documentData'] = json.encode(documentData);

      // Add document images
      for (int i = 0; i < documentImages.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documentImages',
            documentImages[i].path,
          ),
        );
      }

      // Add selfie if provided
      if (selfieImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'selfieImage',
            selfieImage.path,
          ),
        );
      }

      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error submitting KYC: $e');
      return false;
    }
  }

  Future<bool> verifyAadhar(String aadharNumber, String otp) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/kyc/verify-aadhar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'aadharNumber': aadharNumber,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying Aadhar: $e');
      return false;
    }
  }

  Future<bool> sendAadharOTP(String aadharNumber) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/kyc/send-aadhar-otp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'aadharNumber': aadharNumber,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending Aadhar OTP: $e');
      return false;
    }
  }

  Future<bool> verifyPAN(String panNumber, String name, String dob) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/kyc/verify-pan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'panNumber': panNumber,
          'name': name,
          'dob': dob,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying PAN: $e');
      return false;
    }
  }

  Future<SafetyVerification?> getSafetyVerification() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/safety/verification'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return SafetyVerification.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching safety verification: $e');
      return null;
    }
  }

  Future<bool> verifyPhone(String phoneNumber, String otp) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/safety/verify-phone'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying phone: $e');
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String otp) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/safety/verify-email'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying email: $e');
      return false;
    }
  }

  Future<bool> submitFaceVerification(File faceImage) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$API_URL/api/safety/verify-face'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'faceImage',
          faceImage.path,
        ),
      );

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting face verification: $e');
      return false;
    }
  }
}
