import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

enum ReportCategory {
  HARASSMENT,
  FAKE_PROFILE,
  INAPPROPRIATE_CONTENT,
  SPAM,
  SCAM,
  UNDERAGE,
  VIOLENCE,
  OTHER
}

class ReportService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> submitReport({
    required int reportedUserId,
    required ReportCategory category,
    required String reason,
    String? evidence,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$API_URL/api/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reportedUserId': reportedUserId,
          'category': category.name,
          'reason': reason,
          'evidence': evidence,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<dynamic>> getMyReports() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$API_URL/api/report/my-reports'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['reports'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  String getCategoryDisplayName(ReportCategory category) {
    switch (category) {
      case ReportCategory.HARASSMENT:
        return 'Harassment or Bullying';
      case ReportCategory.FAKE_PROFILE:
        return 'Fake Profile';
      case ReportCategory.INAPPROPRIATE_CONTENT:
        return 'Inappropriate Content';
      case ReportCategory.SPAM:
        return 'Spam';
      case ReportCategory.SCAM:
        return 'Scam or Fraud';
      case ReportCategory.UNDERAGE:
        return 'Underage User';
      case ReportCategory.VIOLENCE:
        return 'Violence or Threats';
      case ReportCategory.OTHER:
        return 'Other';
    }
  }

  String getCategoryDescription(ReportCategory category) {
    switch (category) {
      case ReportCategory.HARASSMENT:
        return 'User is harassing, bullying, or threatening you';
      case ReportCategory.FAKE_PROFILE:
        return 'Profile appears to be fake or impersonating someone';
      case ReportCategory.INAPPROPRIATE_CONTENT:
        return 'Profile contains inappropriate photos or content';
      case ReportCategory.SPAM:
        return 'User is sending spam or promotional content';
      case ReportCategory.SCAM:
        return 'User appears to be running a scam or fraud';
      case ReportCategory.UNDERAGE:
        return 'User appears to be under 18 years old';
      case ReportCategory.VIOLENCE:
        return 'User is promoting violence or making threats';
      case ReportCategory.OTHER:
        return 'Other reason not listed above';
    }
  }
}
