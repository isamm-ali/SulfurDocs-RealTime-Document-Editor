import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/signup_provider.dart';
import 'package:frontend/config/environment.dart';

class AuthService {
  static String get baseUrl => Environment.apiUrl;
  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> signup(SignupState data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': data.username.trim(),
          'email': data.email.trim().toLowerCase(),
          'password': data.password,
          'pfp': data.pfp,
        }),
      );
      final responseData = _decodeResponse(response);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': responseData['message'] ?? 'Something went wrong',
        'user': responseData['user'],
      };
    } catch (e) {
      debugPrint('Signup request failed: $e');
      return {'success': false, 'message': 'Unable to connect to the server'};
    }
  }

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );
      final responseData = _decodeResponse(response);
      final success = response.statusCode >= 200 && response.statusCode < 300;
      return {
        'success': success,
        'message': responseData['message'] ?? 'Something went wrong',
        'token': responseData['token'],
        'user': responseData['user'],
      };
    } catch (e) {
      debugPrint('Signin request failed: $e');
      return {'success': false, 'message': 'Unable to connect to the server'};
    }
  }

  Future<Map<String, dynamic>?> getUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        return null;
      }
      final responseData = _decodeResponse(response);
      final user = responseData['user'];
      if (user is! Map) {
        return null;
      }
      return Map<String, dynamic>.from(user);
    } catch (e) {
      debugPrint('Get user data failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return null;
    }
    final user = await getUserData(token);
    if (user == null) {
      await prefs.remove('token');
      return null;
    }
    return {...user, 'token': token};
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
