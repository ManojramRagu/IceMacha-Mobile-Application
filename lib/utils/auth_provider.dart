import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _email;
  String? _displayName;
  String? _homeAddress;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String get name {
    final n = (_displayName ?? '').trim();
    if (n.isNotEmpty) return n;
    final e = (_email ?? '').trim();
    if (e.isNotEmpty) return e.split('@').first;
    return 'Guest';
  }

  String? get homeAddress => _homeAddress;

  Future<void> register({
    required String email,
    required String password,
    String? address,
  }) async {
    // Registration does not auto-login
    _email = email.trim();
    // Display name based on email
    _displayName = null;
    // Home address at registration
    _homeAddress = (address ?? '').trim().isEmpty ? null : address!.trim();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isAuthenticated = true;
    _email = email.trim();
    if ((_displayName ?? '').trim().isEmpty) {
      _displayName = _email!.split('@').first;
    }

    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _email = null;
    _displayName = null;
    _homeAddress = null;

    notifyListeners();
  }

  /// Update profile in-session. Empty values are ignored.
  void updateProfile({String? name, String? password}) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) _displayName = n;
    notifyListeners();
  }
}
