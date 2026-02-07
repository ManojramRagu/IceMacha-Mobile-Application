import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator to access localhost
  static const String baseUrl = 'https://d36bnb8wo21edh.cloudfront.net/api';

  ApiService();

  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String deviceName,
  ) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': deviceName,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        // Fallback for unexpected format, though we expect a Map
        return {'token': response.body};
      } catch (e) {
        return {'token': response.body};
      }
    } else {
      // Try to parse server error message
      String msg = 'Login failed: ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          msg = '$msg: ${body['message']}';
        } else {
          msg = '$msg ${response.body}';
        }
      } catch (_) {
        msg = '$msg ${response.body}';
      }
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? address,
    String? phoneNumber,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': 'user',
        'address': address,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      String msg = 'Registration failed: ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          msg = '$msg: ${body['message']}';
        } else {
          msg = '$msg ${response.body}';
        }
      } catch (_) {
        msg = '$msg ${response.body}';
      }
      throw Exception(msg);
    }
  }

  Future<String> fetchProducts() async {
    final url = Uri.parse('$baseUrl/v1/products');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<String> fetchExternalData(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      }
      throw Exception('Failed to load external data: ${response.statusCode}');
    } catch (e) {
      // Log error but don't crash app flow usually
      print('External fetch error: $e');
      rethrow;
    }
  }

  Future<bool> placeOrder(Map<String, dynamic> orderData) async {
    final url = Uri.parse('$baseUrl/v1/orders');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
