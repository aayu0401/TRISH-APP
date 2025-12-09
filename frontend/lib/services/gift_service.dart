import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/gift.dart';
import 'auth_service.dart';

class GiftService {
  final AuthService _authService = AuthService();

  Future<List<Gift>> getAllGifts({GiftCategory? category, GiftType? type}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      String url = '$API_URL/api/gifts';
      List<String> params = [];
      
      if (category != null) {
        params.add('category=${category.toString().split('.').last}');
      }
      if (type != null) {
        params.add('type=${type.toString().split('.').last}');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((g) => Gift.fromJson(g)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }

  Future<Gift?> getGiftById(String giftId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/gifts/$giftId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Gift.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching gift: $e');
      return null;
    }
  }

  Future<GiftTransaction?> sendGift({
    required String receiverId,
    required String giftId,
    String? message,
    Map<String, dynamic>? deliveryDetails,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$API_URL/api/gifts/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'receiverId': receiverId,
          'giftId': giftId,
          'message': message,
          'deliveryDetails': deliveryDetails,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GiftTransaction.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error sending gift: $e');
      return null;
    }
  }

  Future<List<GiftTransaction>> getSentGifts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/gifts/sent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((g) => GiftTransaction.fromJson(g)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching sent gifts: $e');
      return [];
    }
  }

  Future<List<GiftTransaction>> getReceivedGifts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/gifts/received'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((g) => GiftTransaction.fromJson(g)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching received gifts: $e');
      return [];
    }
  }

  Future<GiftTransaction?> trackGift(String transactionId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/gifts/track/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return GiftTransaction.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error tracking gift: $e');
      return null;
    }
  }

  Future<bool> cancelGift(String transactionId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/gifts/cancel/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelling gift: $e');
      return false;
    }
  }

  Future<List<Gift>> getPopularGifts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/gifts/popular'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((g) => Gift.fromJson(g)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching popular gifts: $e');
      return [];
    }
  }
}
