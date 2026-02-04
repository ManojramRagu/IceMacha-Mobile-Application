import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator to access localhost
  static const String baseUrl = 'https://d36bnb8wo21edh.cloudfront.net/api';

  ApiService();

  Future<String> login(String email, String password, String deviceName) async {
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
      // Assuming the token is returned directly as a string or in a JSON object
      // Laravel Sanctum usually returns just the token string if configured simply,
      // or a JSON object like { "token": "..." }
      // The user instructions say "Implement a POST login method that sends email, password, and device_name."
      // I'll assume standard Sanctum JSON return: { "token": "..." } or check if it's plaintext.
      // Let's safe parse it.

      // However, typical Sanctum tutorial return is often just the token string.
      // But standard is JSON. Let's try to parse as JSON first.
      try {
        final data = jsonDecode(response.body);
        // It might be data['token'] or just the string body.
        // Let's assume standard response format: token
        if (data is Map && data.containsKey('token')) {
          return data['token'];
        }
        // If not a map with token, maybe the body IS the token?
        // But safer to assume standard API response.
        // Let's start with expecting a JSON with 'token' or 'access_token'.
        if (data is String) return data; // Just in case
        return response.body;
      } catch (e) {
        return response.body;
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

  Future<List<dynamic>> fetchProducts() async {
    // Placeholder for fetchProducts implementation
    // Eventually will call GET /v1/products
    // final url = Uri.parse('$baseUrl/v1/products');
    // final response = await http.get(url);
    // if (response.statusCode == 200) {
    //   return json.decode(response.body);
    // } else {
    //   throw Exception('Failed to load products');
    // }

    // For now, return empty list
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
