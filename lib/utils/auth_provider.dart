import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _email;
  String? _displayName;
  String? _homeAddress;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String get displayName {
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
    _email = email.trim();
    _displayName = _email!.split('@').first;
    final addr = (address ?? '').trim();
    _homeAddress = addr.isEmpty ? null : addr;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _email = email.trim();
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void updateProfile({String? name, String? password}) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) _displayName = n;
    notifyListeners();
  }
}
