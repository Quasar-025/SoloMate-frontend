import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  final AuthService _authService = AuthService();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
  };

  // Users API
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers,
      body: jsonEncode(userData),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/stats'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getUserBadges() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/badges'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getFriends() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/friends'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addFriend(String walletAddress) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/add-friend/$walletAddress'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Quests API
  Future<List<dynamic>> getQuests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/quests/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getNearbyQuests({double? lat, double? lng}) async {
    var uri = Uri.parse('$baseUrl/api/quests/nearby');
    if (lat != null && lng != null) {
      uri = uri.replace(queryParameters: {'lat': lat.toString(), 'lng': lng.toString()});
    }
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> startQuest(String questId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/quests/$questId/start'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Cities API
  Future<List<dynamic>> getCities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/cities/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getCityStats(String cityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/cities/$cityId/stats'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Safety API
  Future<Map<String, dynamic>> getCitySafetyIndex(String cityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/safety/index/city/$cityId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // AI Recommendations API
  Future<List<dynamic>> getAIRecommendations(String type) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/recommendations/$type'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getUserInsights() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ai/insights'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Leaderboards API
  Future<List<dynamic>> getLeaderboards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/leaderboards/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getUserLeaderboardPosition(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/leaderboards/user/$userId/position'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
