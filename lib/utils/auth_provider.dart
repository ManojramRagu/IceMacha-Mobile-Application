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
    return (_email ?? '').split('@').first;
  }

  String? get homeAddress => _homeAddress;

  Future<void> register({
    required String email,
    required String password,

    String? address,
  }) async {
    _email = email.trim();
    _homeAddress = (address ?? '').trim().isEmpty ? null : address!.trim();

    notifyListeners();
  }

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

  /// Update profile. Empty inputs are ignored.
  void updateProfile({String? name, String? password}) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) _displayName = n;

    final p = (password ?? '').trim();
    if (p.isNotEmpty) notifyListeners();
  }
}
