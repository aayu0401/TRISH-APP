import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/subscription.dart';
import 'auth_service.dart';

class SubscriptionService {
  final AuthService _authService = AuthService();

  Future<Subscription?> getCurrentSubscription() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/subscription/current'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Subscription.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching current subscription: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailablePlans() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/subscription/plans'),
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
      print('Error fetching available plans: $e');
      return [];
    }
  }

  Future<bool> subscribeToPlan({
    required SubscriptionPlan plan,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/subscription/subscribe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'plan': plan.toString().split('.').last,
          'paymentMethod': paymentMethod,
          'promoCode': promoCode,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error subscribing to plan: $e');
      return false;
    }
  }

  Future<bool> cancelSubscription() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/subscription/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    }
  }

  Future<bool> updateAutoRenew(bool autoRenew) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$API_URL/api/subscription/auto-renew'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'autoRenew': autoRenew,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating auto-renew: $e');
      return false;
    }
  }

  Future<List<PremiumFeature>> getPremiumFeatures() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/subscription/features'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((f) => PremiumFeature.fromJson(f)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching premium features: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> validatePromoCode(String promoCode) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$API_URL/api/subscription/validate-promo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'promoCode': promoCode,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error validating promo code: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSubscriptionHistory() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/subscription/history'),
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
      print('Error fetching subscription history: $e');
      return [];
    }
  }
}
