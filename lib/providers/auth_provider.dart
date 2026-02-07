import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icemacha/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isAuthenticated = false;
  String? _email;
  String? _displayName;
  String? _homeAddress;

  int? _userId;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get email => _email;
  int? get userId => _userId;
  String get name {
    final n = (_displayName ?? '').trim();
    if (n.isNotEmpty) return n;
    final e = (_email ?? '').trim();
    if (e.isNotEmpty) return e.split('@').first;
    return 'Guest';
  }

  String? get homeAddress => _homeAddress;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? address,
    String? phone,
  }) async {
    try {
      final response = await _api.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        address: address, // Passing optional address
        phoneNumber: phone, // Passing optional phone as 'phoneNumber'
        // deviceName removed
      );

      // Assuming success response structure: { token: "...", user: { ... } }
      // Or if the API just returns the token (Sanctum style for direct login, but register might differ)
      // Usually Sanctum register returns the same as login if you structure it that way.
      // Based on ApiService implementation, we return parsed JSON.
      // Let's assume standard response containing token.

      if (response.containsKey('token')) {
        _token = response['token'];
        if (response.containsKey('user')) {
          final user = response['user'];
          if (user is Map) {
            _userId = user['id'];
          }
        }

        _isAuthenticated = true;
        _email = email.trim();
        _displayName = name.trim();

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('auth_email', _email!);
        if (_userId != null) {
          await prefs.setInt('auth_user_id', _userId!);
        }

        notifyListeners();
      } else {
        // Should catch this in ApiService or here?
        // ApiService throws on non-200. If 200/201 but no token?
        throw Exception('Registration successful but no token received.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      rethrow;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _api.login(email, password, 'mobile_app');

      if (response.containsKey('token')) {
        _token = response['token'];
        _isAuthenticated = true;
        _email = email.trim();

        if (response.containsKey('user')) {
          final user = response['user'];
          if (user is Map) {
            _userId = user['id'];
            // Could also update name/address from user object here if available
          }
        }

        if ((_displayName ?? '').trim().isEmpty) {
          _displayName = _email!.split('@').first;
        }

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('auth_email', _email!);
        if (_userId != null) {
          await prefs.setInt('auth_user_id', _userId!);
        }

        notifyListeners();
        return true;
      }
      return false;
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
    if (prefs.containsKey('auth_user_id')) {
      _userId = prefs.getInt('auth_user_id');
    }

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
    _userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_email');
    await prefs.remove('auth_user_id');

    notifyListeners();
  }

  /// Update profile in-session. Empty values are ignored.
  void updateProfile({String? name, String? password}) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) _displayName = n;
    notifyListeners();
  }
}
