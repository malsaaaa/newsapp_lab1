import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () => throw TimeoutException('Signup request timeout'),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Save token and user data
        await _saveToken(data['token']);
        await _saveUser(data['user']);
        
        return {'success': true, 'message': 'Signup successful', 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () => throw TimeoutException('Login request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save token and user data
        await _saveToken(data['token']);
        await _saveUser(data['user']);
        
        return {'success': true, 'message': 'Login successful', 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Save token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Save user data
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Add bookmark
  static Future<Map<String, dynamic>> addBookmark({
    required String articleUrl,
    required String title,
    String? description,
    String? urlToImage,
    String? source,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/bookmarks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'articleUrl': articleUrl,
          'title': title,
          'description': description,
          'urlToImage': urlToImage,
          'source': source,
        }),
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () => throw TimeoutException('Bookmark request timeout'),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'], 'bookmark': data['bookmark']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to bookmark'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get bookmarks
  static Future<Map<String, dynamic>> getBookmarks() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated', 'bookmarks': []};
      }

      final response = await http.get(
        Uri.parse('${AppConfig.backendUrl}/bookmarks'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () => throw TimeoutException('Fetch bookmarks request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'bookmarks': data['bookmarks'] ?? []};
      } else {
        return {'success': false, 'message': 'Failed to fetch bookmarks', 'bookmarks': []};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}', 'bookmarks': []};
    }
  }

  // Remove bookmark
  static Future<Map<String, dynamic>> removeBookmark(String bookmarkId) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.backendUrl}/bookmarks/$bookmarkId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () => throw TimeoutException('Delete bookmark request timeout'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Bookmark removed'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to remove bookmark'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
