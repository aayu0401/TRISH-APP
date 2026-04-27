import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userService.getProfile();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _currentUser = await _userService.updateProfile(updates);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLocation(double lat, double lng) async {
    try {
      _currentUser = await _userService.updateLocation(lat, lng);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clear() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
