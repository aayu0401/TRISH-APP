import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/wallet.dart';
import 'auth_service.dart';

class WalletService {
  final AuthService _authService = AuthService();

  Future<Wallet?> getWallet() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/wallet'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Wallet.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching wallet: $e');
      return null;
    }
  }

  Future<bool> addMoney(double amount, String paymentMethod) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/wallet/add-money'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'paymentMethod': paymentMethod,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding money: $e');
      return false;
    }
  }

  Future<bool> withdraw(double amount, Map<String, dynamic> bankDetails) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/wallet/withdraw'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'bankDetails': bankDetails,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error withdrawing money: $e');
      return false;
    }
  }

  Future<List<Transaction>> getTransactions({int page = 0, int limit = 20}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$API_URL/api/wallet/transactions?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded is Map<String, dynamic>
            ? (decoded['content'] is List ? decoded['content'] as List : const [])
            : (decoded is List ? decoded : const []);
        return data
            .whereType<Map>()
            .map((t) => Transaction.fromJson(Map<String, dynamic>.from(t)))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<Transaction?> getTransactionById(String transactionId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/wallet/transactions/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching transaction: $e');
      return null;
    }
  }

  Future<bool> verifyPayment(String paymentId, String signature) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$API_URL/api/wallet/verify-payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'paymentId': paymentId,
          'signature': signature,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getWalletStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$API_URL/api/wallet/stats'),
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
      print('Error fetching wallet stats: $e');
      return null;
    }
  }
}
