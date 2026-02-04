import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icemacha/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isAuthenticated = false;
  String? _email;
  String? _displayName;
  String? _homeAddress;

  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
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
    _email = email.trim();
    _displayName = null;
    _homeAddress = (address ?? '').trim().isEmpty ? null : address!.trim();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final token = await _api.login(email, password, 'mobile_app');
      _isAuthenticated = true;
      _email = email.trim();
      _token = token;

      if ((_displayName ?? '').trim().isEmpty) {
        _displayName = _email!.split('@').first;
      }

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_email', _email!);

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) return false;

    _token = prefs.getString('auth_token');
    _email = prefs.getString('auth_email');
    _isAuthenticated = true;

    if (_email != null) {
      _displayName = _email!.split('@').first;
    }

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _email = null;
    _displayName = null;
    _homeAddress = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_email');

    notifyListeners();
  }

  /// Update profile in-session. Empty values are ignored.
  void updateProfile({String? name, String? password}) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) _displayName = n;
    notifyListeners();
  }
}
