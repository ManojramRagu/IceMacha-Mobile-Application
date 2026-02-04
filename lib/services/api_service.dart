import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator to access localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  ApiService();

  Future<bool> login(String email, String password) async {
    // Placeholder for login implementation
    // Eventually will call POST /login
    // final url = Uri.parse('$baseUrl/login');
    // final response = await http.post(
    //   url,
    //   body: {'email': email, 'password': password},
    // );
    // return response.statusCode == 200;

    // For now, return true to simulate success
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return true;
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
