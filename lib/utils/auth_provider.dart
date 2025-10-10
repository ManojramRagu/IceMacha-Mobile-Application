import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _email;

  // ========== NEW ============
  String? _displayName; // session-only friendly name
  String? _homeAddress; // session-only home address
  //========== END OF NEW ============

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;

  /// Friendly display name for UI:
  /// prefer edited display name; else email prefix; else "Guest".
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
    // ========== NEW ============
    String? address,
    //========== END OF NEW ============
  }) async {
    // Registration does not auto-login (per your flow)
    _email = email.trim();
    // Initialize a sensible display name based on email
    _displayName = _email!.split('@').first;
    // Optional home address captured at registration
    _homeAddress = (address ?? '').trim().isEmpty ? null : address!.trim();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isAuthenticated = true;
    _email = email.trim();

    // ========== NEW ============
    // If display name isn't set for this session, use email prefix
    if ((_displayName ?? '').trim().isEmpty) {
      _displayName = _email!.split('@').first;
    }
    //========== END OF NEW ============

    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _email = null;

    // ========== NEW ============
    // Session-only data cleared on logout
    _displayName = null;
    _homeAddress = null;
    //========== END OF NEW ============

    notifyListeners();
  }

  /// Update profile in-session. Empty values are ignored.
  void updateProfile({String? name, String? password}) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) _displayName = n;
    // Password changes are not persisted (no backend), ignore safely.
    notifyListeners();
  }
}
