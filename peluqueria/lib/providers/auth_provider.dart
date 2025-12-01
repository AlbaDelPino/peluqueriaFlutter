import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _loading = false;
  String? _userEmail;

  bool get loading => _loading;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _userEmail != null;

  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _loading = false;
    if (email.isNotEmpty && password.length >= 4) {
      _userEmail = email;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> signup({required String name, required String email, required String password}) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _loading = false;
    if (name.isNotEmpty && email.contains('@') && password.length >= 4) {
      _userEmail = email;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void logout() {
    _userEmail = null;
    notifyListeners();
  }
}
