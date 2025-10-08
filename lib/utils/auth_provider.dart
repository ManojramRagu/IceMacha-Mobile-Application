import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _email;

  // ========== NEW ============
  String? _displayName; // display name stored in-session
  String? _homeAddress; // optional address from Register
  String? _password; // stored so Edit Profile can change it
  //========== END OF NEW ============

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;

  // ========== NEW ============
  /// Display name > fallback to email local-part > 'Guest'
  String get displayName {
    final n = (_displayName ?? '').trim();
    if (n.isNotEmpty) return n;
    final e = (_email ?? '').trim();
    if (e.isNotEmpty) return e.split('@').first;
    return 'Guest';
  }

  String? get homeAddress => _homeAddress;
  //========== END OF NEW ============

  Future<void> register({
    required String email,
    required String password,
    // ========== NEW ============
    String? address,
    //========== END OF NEW ============
  }) async {
    // ========== NEW ============
    // Seed session with the last registered details (not auto-login)
    _email = email.trim();
    _password = password.trim();
    _displayName = _email!.split('@').first;
    final addr = (address ?? '').trim();
    _homeAddress = addr.isEmpty ? null : addr;
    notifyListeners();
    //========== END OF NEW ============
  }

  Future<bool> login({required String email, required String password}) async {
    // ========== NEW ============
    final e = email.trim();
    final p = password.trim();

    // If a registration exists, require the same credentials.
    // If not registered yet, accept and treat this as first login.
    if (_email != null && _password != null) {
      final ok = (_email == e && _password == p);
      if (!ok) return false;
    } else {
      _email = e;
      _displayName ??= e.split('@').first;
      _password = p;
    }
    //========== END OF NEW ============

    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    // ========== NEW ============
    // Keep registration details so user can log back in.
    //========== END OF NEW ============
    notifyListeners();
  }

  // ========== NEW ============
  /// Update profile (session-only). Empty inputs are ignored.
  void updateProfile({String? name, String? password}) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) _displayName = n;

    final p = (password ?? '').trim();
    if (p.isNotEmpty) _password = p;

    notifyListeners();
  }

  //========== END OF NEW ============
}
