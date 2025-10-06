import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String get name => (_email ?? '').split('@').first;

  Future<void> register({
    required String email,
    required String password,
  }) async {}

  Future<bool> login({required String email, required String password}) async {
    _isAuthenticated = true;
    _email = email.trim();
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _email = null;
    notifyListeners();
  }
}
