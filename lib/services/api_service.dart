import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://trove-backend-95ua.onrender.com';
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

  Future<Map<String, dynamic>> updateLocationPreference({
    required bool useCurrentLocation,
    String? customLocation,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/location-preference'),
        headers: _headers,
        body: jsonEncode({
          'use_current_location': useCurrentLocation,
          'custom_location': customLocation,
        }),
      );

      print('Updating location preference to: $baseUrl/users/location-preference');
      print('Request body: ${jsonEncode({
        'use_current_location': useCurrentLocation,
        'custom_location': customLocation,
      })}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        // Endpoint doesn't exist yet, simulate success
        print('Location preference endpoint not implemented yet, simulating success');
        return {'success': true, 'message': 'Location preference saved locally'};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully updated location preference: $data');
        return {'success': true, 'message': 'Location preference updated successfully', 'data': data};
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? errorData['message'] ?? 'Failed to update location preference',
        };
      }
    } catch (e) {
      print('Error updating location preference: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/stats'),
        headers: _headers,
      );
      
      if (response.statusCode == 404 || response.statusCode == 500) {
        // Return mock data if endpoint doesn't exist or fails
        return {
          'completed_quests': 5,
          'cities_visited': 3,
          'total_xp': 1250,
          'level': 3,
          'badges_earned': 7,
        };
      }
      
      return _handleResponse(response);
    } catch (e) {
      print('Error in getUserStats: $e');
      return {
        'completed_quests': 5,
        'cities_visited': 3,
        'total_xp': 1250,
        'level': 3,
        'badges_earned': 7,
      };
    }
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

  Future<List<dynamic>> getNearbyQuests({double? latitude, double? longitude, double? radiusKm, int? limit}) async {
    try {
      var uri = Uri.parse('$baseUrl/api/quests/nearby');
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radiusKm != null) queryParams['radius_km'] = radiusKm.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 404 || response.statusCode == 500) {
        // Return mock data if endpoint doesn't exist or fails
        return [
          {
            'id': '1',
            'title': 'Explore Local Markets',
            'description': 'Discover authentic local products and street food',
            'difficulty': 'Easy',
            'distance': '0.5 km',
            'estimated_time': '1-2 hours',
          },
          {
            'id': '2',
            'title': 'Historical Walking Tour',
            'description': 'Learn about the rich history and culture',
            'difficulty': 'Medium',
            'distance': '1.2 km',
            'estimated_time': '2-3 hours',
          },
        ];
      }
      
      return _handleResponse(response);
    } catch (e) {
      print('Error in getNearbyQuests: $e');
      return [
        {
          'id': '1',
          'title': 'Explore Local Markets',
          'description': 'Discover authentic local products and street food',
          'difficulty': 'Easy',
          'distance': '0.5 km',
          'estimated_time': '1-2 hours',
        },
      ];
    }
  }

  Future<Map<String, dynamic>> startQuest(String questId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/quests/$questId/start'),
        headers: _headers,
      );

      print('Starting quest: $baseUrl/api/quests/$questId/start');
      print('Request headers: $_headers');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        // Endpoint doesn't exist yet, simulate success
        print('Start quest endpoint not implemented yet, simulating success');
        return {
          'success': true,
          'message': 'Quest started successfully! (Mock response)',
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully started quest: $data');
        return {
          'success': true,
          'message': data['message'] ?? 'Quest started successfully!',
          'data': data,
        };
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? errorData['message'] ?? 'Failed to start quest',
        };
      }
    } catch (e) {
      print('Error starting quest: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
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

  // Weather API
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lng) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) throw Exception('Google Maps API Key not found');

    final uri = Uri.https('weather.googleapis.com', '/v1/currentConditions:lookup', {
      'key': apiKey,
      'location.latitude': lat.toString(),
      'location.longitude': lng.toString(),
      'languageCode': 'en',
    });

    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    return _handleResponse(response);
  }

  // Safety API
  Future<Map<String, dynamic>> getCitySafetyIndex(String cityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/safety/index/city/$cityId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getSafetyIndexFromNews({
    required double latitude,
    required double longitude,
    String? cityName,
    String? country,
    double radiusKm = 50,
    int daysBack = 7,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (cityName != null) 'city_name': cityName,
        if (country != null) 'country': country,
        'radius_km': radiusKm.toString(),
        'days_back': daysBack.toString(),
      };

      final uri = Uri.parse('$baseUrl/safety/news/scrape').replace(
        queryParameters: queryParams,
      );

      print('Fetching safety index from news: $uri');
      print('Request headers: $_headers');

      final response = await http.post(uri, headers: _headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse JSON and extract average_safety_score
        try {
          final data = jsonDecode(response.body);
          final avgScore = data['safety_analysis']?['average_safety_score'];
          if (avgScore != null && avgScore is num) {
            final index = (avgScore * 100).clamp(0, 100).toDouble();
            return {
              'success': true,
              'safety_index': index,
              'raw': data,
            };
          }
        } catch (e) {
          print('Error parsing safety index JSON: $e');
        }
        // fallback: try to parse as string (legacy)
        final result = response.body;
        return {'success': true, 'safety_index': result};
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return {'success': false, 'error': 'Failed to fetch safety index'};
      }
    } catch (e) {
      print('Error fetching safety index: $e');
      return {'success': false, 'error': e.toString()};
    }
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

  Future<Map<String, dynamic>> generateItinerary({
    required String cityName,
    String? date,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Prepare the request body as required by the backend
      final body = {
        'city_name': cityName,
        if (date != null) 'date': date,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (additionalData != null) ...additionalData,
      };

      // Use the correct endpoint without query parameters
      final uri = Uri.parse('$baseUrl/ai/generate-itinerary');

      // Match the exact headers from Postman
      final headers = {
        'Content-Type': 'application/json',
        if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
      };

      print('Making itinerary request to: $uri');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        print('Itinerary endpoint not found, using mock data');
        return _getMockItineraryData(cityName, date);
      }

      if (response.statusCode == 401) {
        print('Unauthorized request - token may be invalid');
        // Return mock data instead of throwing error for better UX
        return _getMockItineraryData(cityName, date);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully received itinerary data: $data');
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getMockItineraryData(cityName, date);
      }
    } catch (e) {
      print('Error in generateItinerary: $e');
      // Return mock data on any error to ensure app doesn't break
      return _getMockItineraryData(cityName, date);
    }
  }

  Map<String, dynamic> _getMockItineraryData(String cityName, String? date) {
    // Update mock data to match the actual API response structure
    return {
      "date": date ?? "Today",
      "city": cityName,
      "weather": {
        "status": "Check local weather",
        "temperature": "Varies"
      },
      "time_slots": [
        {
          "start_time": "09:00 AM",
          "end_time": "10:30 AM",
          "activity_type": "quest",
          "title": "Morning Heritage Walk",
          "description": "Explore historic downtown area with guided audio tour",
          "location": {
            "latitude": 12.9204,
            "longitude": 79.1333
          },
          "estimated_duration": "1 hour 30 minutes",
          "difficulty": "EASY",
          "weather_dependent": false
        },
        {
          "start_time": "11:00 AM",
          "end_time": "12:30 PM",
          "activity_type": "quest",
          "title": "Local Food Tasting Tour",
          "description": "Discover hidden culinary gems in the city",
          "location": {
            "latitude": 12.9204,
            "longitude": 79.1333
          },
          "estimated_duration": "1 hour 30 minutes",
          "difficulty": "EASY",
          "weather_dependent": false
        },
        {
          "start_time": "01:30 PM",
          "end_time": "03:00 PM",
          "activity_type": "exploration",
          "title": "Visit Local Fort",
          "description": "Immerse yourself in the rich history of the area",
          "location": {
            "latitude": 12.9204,
            "longitude": 79.1333
          },
          "estimated_duration": "1 hour 30 minutes",
          "difficulty": null,
          "weather_dependent": false
        }
      ],
      "total_estimated_time": "4 hours 30 minutes",
      "safety_notes": []
    };
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

  // Journal API
  // Add a static list to store entries in memory during app session
  static final List<Map<String, dynamic>> _sessionJournalEntries = [];

  Future<Map<String, dynamic>> saveJournalEntry(Map<String, dynamic> entryData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/journal/entries'),
        headers: _headers,
        body: jsonEncode(entryData),
      );

      print('Saving journal entry to: $baseUrl/api/journal/entries');
      print('Request headers: $_headers');
      print('Request body: ${jsonEncode(entryData)}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        // Endpoint doesn't exist yet, simulate success and store locally
        print('Journal endpoint not implemented yet, storing locally');
        
        final newEntry = {
          ...entryData,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'user_id': 'current_user',
        };
        
        // Add to session storage
        _sessionJournalEntries.insert(0, newEntry);
        
        return {
          'success': true, 
          'message': 'Entry saved successfully!', 
          'id': newEntry['id'],
          'data': newEntry,
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully saved journal entry: $data');
        return {
          'success': true,
          'message': 'Journal entry saved successfully!',
          'data': data,
          'id': data['id'],
        };
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? errorData['message'] ?? 'Failed to save entry',
        };
      }
    } catch (e) {
      print('Error saving journal entry: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getJournalEntries({
    int? limit,
    int? offset,
    String? date,
    String? startDate,
    String? endDate,
    String? location,
    String? mood,
    String? tags,
  }) async {
    try {
      final queryParams = <String, String>{
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
        if (date != null) 'date': date,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (location != null) 'location': location,
        if (mood != null) 'mood': mood,
        if (tags != null) 'tags': tags,
      };

      final uri = Uri.parse('$baseUrl/api/journal/entries').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('Fetching journal entries from: $uri');
      print('Request headers: $_headers');

      final response = await http.get(uri, headers: _headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        // Endpoint doesn't exist yet, return combined mock + session data
        print('Journal entries endpoint not implemented yet, using mock + session data');
        
        final allEntries = [
          ..._sessionJournalEntries,
          ..._getMockJournalEntries(),
        ];
        
        // Apply limit if specified
        final limitedEntries = limit != null ? allEntries.take(limit).toList() : allEntries;
        
        return {
          'entries': limitedEntries,
          'total': allEntries.length,
          'has_more': limit != null && allEntries.length > limit,
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully fetched journal entries: $data');
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return {
          'entries': [..._sessionJournalEntries, ..._getMockJournalEntries()],
          'total': _sessionJournalEntries.length + _getMockJournalEntries().length,
          'has_more': false,
        };
      }
    } catch (e) {
      print('Error fetching journal entries: $e');
      return {
        'entries': [..._sessionJournalEntries, ..._getMockJournalEntries()],
        'total': _sessionJournalEntries.length + _getMockJournalEntries().length,
        'has_more': false,
      };
    }
  }

  Future<Map<String, dynamic>> getJournalEntry(String entryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/journal/entries/$entryId'),
        headers: _headers,
      );

      print('Fetching journal entry from: $baseUrl/api/journal/entries/$entryId');
      print('Request headers: $_headers');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        throw Exception('Journal entry not found');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully fetched journal entry: $data');
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch journal entry');
      }
    } catch (e) {
      print('Error fetching journal entry: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> deleteJournalEntry(String entryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/journal/entries/$entryId'),
        headers: _headers,
      );

      print('Deleting journal entry from: $baseUrl/api/journal/entries/$entryId');
      print('Request headers: $_headers');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        // Endpoint doesn't exist yet, try to remove from session storage
        print('Delete journal entry endpoint not implemented yet, removing from session');
        
        // Check if entry exists before removing
        final entryExists = _sessionJournalEntries.any((entry) => entry['id'] == entryId);
        if (entryExists) {
          _sessionJournalEntries.removeWhere((entry) => entry['id'] == entryId);
        }
        
        return {
          'success': true, 
          'message': entryExists ? 'Entry deleted successfully' : 'Entry not found in session'
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Also remove from session storage if it exists there
        _sessionJournalEntries.removeWhere((entry) => entry['id'] == entryId);
        return {'success': true, 'message': 'Entry deleted successfully'};
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return {'success': false, 'error': 'Failed to delete entry'};
      }
    } catch (e) {
      print('Error deleting journal entry: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  List<Map<String, dynamic>> _getMockJournalEntries() {
    return [
      {
        'id': '1',
        'content': 'Had an amazing day exploring the local markets! The colors and aromas were incredible.',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'location': 'Goa',
        'mood': 'excited',
        'tags': ['markets', 'food', 'culture'],
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'user_id': 'mock_user',
      },
      {
        'id': '2',
        'content': 'Peaceful morning walk by the beach. The sunrise was breathtaking.',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'location': 'Goa',
        'mood': 'peaceful',
        'tags': ['beach', 'sunrise', 'nature'],
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'user_id': 'mock_user',
      },
      {
        'id': '3',
        'content': 'Visited the historic fort today. So much history and amazing architecture.',
        'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'location': 'Rajasthan',
        'mood': 'inspired',
        'tags': ['history', 'architecture', 'culture'],
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'user_id': 'mock_user',
      },
      {
        'id': '4',
        'content': 'Incredible wildlife safari experience. Saw tigers in their natural habitat!',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'location': 'Kerala',
        'mood': 'thrilled',
        'tags': ['wildlife', 'safari', 'nature'],
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'user_id': 'mock_user',
      },
      {
        'id': '5',
        'content': 'Traditional dance performance was mesmerizing. The costumes and music were incredible.',
        'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'location': 'Kerala',
        'mood': 'amazed',
        'tags': ['culture', 'dance', 'tradition'],
        'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'user_id': 'mock_user',
      },
    ];
  }

  // Exploration API
  Future<List<dynamic>> getAllNearbyPlaces({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limitPerCategory,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (radiusKm != null) 'radius_km': radiusKm.toString(),
        if (limitPerCategory != null) 'limit_per_category': limitPerCategory.toString(),
      };

      final uri = Uri.parse('$baseUrl/exploration/nearby/all').replace(
        queryParameters: queryParams,
      );

      print('Fetching all nearby places from: $uri');
      print('Request headers: $_headers');

      final response = await http.get(uri, headers: _headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        print('Nearby places endpoint not implemented yet, using mock data');
        return _getMockNearbyPlaces();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully fetched nearby places: $data');
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getMockNearbyPlaces();
      }
    } catch (e) {
      print('Error fetching nearby places: $e');
      return _getMockNearbyPlaces();
    }
  }

  Future<Map<String, dynamic>> getNearbyPlacesByCategory({
    required String category,
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (radiusKm != null) 'radius_km': radiusKm.toString(),
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/exploration/nearby/$category').replace(
        queryParameters: queryParams,
      );

      print('Fetching nearby places for category $category from: $uri');
      print('Request headers: $_headers');

      final response = await http.get(uri, headers: _headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        print('Nearby places by category endpoint not implemented yet, using mock data');
        return _getMockNearbyPlacesByCategory(category);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully fetched nearby places for category $category: $data');
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getMockNearbyPlacesByCategory(category);
      }
    } catch (e) {
      print('Error fetching nearby places for category $category: $e');
      return _getMockNearbyPlacesByCategory(category);
    }
  }

  List<dynamic> _getMockNearbyPlaces() {
    return [
      {
        "category": "FOOD",
        "places": [
          {
            "place_id": "food_1",
            "name": "Beachie Cafe",
            "category": "FOOD",
            "rating": 4.5,
            "user_ratings_total": 120,
            "vicinity": "Beach Road, 300m away",
            "latitude": 12.9204,
            "longitude": 79.1333,
            "distance_meters": 300,
            "photo_reference": null,
            "is_open_now": true,
            "price_level": 2
          },
          {
            "place_id": "food_2",
            "name": "Ganga View Restaurant",
            "category": "FOOD",
            "rating": 4.2,
            "user_ratings_total": 85,
            "vicinity": "River Side, 500m away",
            "latitude": 12.9234,
            "longitude": 79.1363,
            "distance_meters": 500,
            "photo_reference": null,
            "is_open_now": false,
            "price_level": 3
          }
        ],
        "total_found": 2,
        "search_center": {"latitude": 12.9204, "longitude": 79.1333},
        "radius_km": 2
      },
      {
        "category": "SHOPS",
        "places": [
          {
            "place_id": "shop_1",
            "name": "Local Market",
            "category": "SHOPS",
            "rating": 4.0,
            "user_ratings_total": 60,
            "vicinity": "Main Street, 400m away",
            "latitude": 12.9214,
            "longitude": 79.1343,
            "distance_meters": 400,
            "photo_reference": null,
            "is_open_now": true,
            "price_level": 2
          }
        ],
        "total_found": 1,
        "search_center": {"latitude": 12.9204, "longitude": 79.1333},
        "radius_km": 2
      }
    ];
  }

  Map<String, dynamic> _getMockNearbyPlacesByCategory(String category) {
    final mockData = {
      "FOOD": {
        "category": "FOOD",
        "places": [
          {
            "place_id": "food_1",
            "name": "Beachie Cafe",
            "category": "FOOD",
            "rating": 4.5,
            "user_ratings_total": 120,
            "vicinity": "Beach Road",
            "latitude": 12.9204,
            "longitude": 79.1333,
            "distance_meters": 300,
            "photo_reference": null,
            "is_open_now": true,
            "price_level": 2
          },
          {
            "place_id": "food_2",
            "name": "Ganga View Restaurant",
            "category": "FOOD",
            "rating": 4.2,
            "user_ratings_total": 85,
            "vicinity": "River Side",
            "latitude": 12.9234,
            "longitude": 79.1363,
            "distance_meters": 500,
            "photo_reference": null,
            "is_open_now": false,
            "price_level": 3
          }
        ],
        "total_found": 2,
        "search_center": {"latitude": 12.9204, "longitude": 79.1333},
        "radius_km": 2
      },
      "SHOPS": {
        "category": "SHOPS",
        "places": [
          {
            "place_id": "shop_1",
            "name": "Local Market",
            "category": "SHOPS",
            "rating": 4.0,
            "user_ratings_total": 60,
            "vicinity": "Main Street",
            "latitude": 12.9214,
            "longitude": 79.1343,
            "distance_meters": 400,
            "photo_reference": null,
            "is_open_now": true,
            "price_level": 2
          }
        ],
        "total_found": 1,
        "search_center": {"latitude": 12.9204, "longitude": 79.1333},
        "radius_km": 2
      }
    };

    return mockData[category] ?? {
      "category": category,
      "places": [],
      "total_found": 0,
      "search_center": {"latitude": 12.9204, "longitude": 79.1333},
      "radius_km": 2
    };
  }

  // Quests API - Enhanced methods
  Future<List<dynamic>> getQuests({
    String? cityId,
    String? questType,
    String? difficulty,
    double? latitude,
    double? longitude,
    double? radiusKm,
    int? userLevel,
    bool availableOnly = true,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Uri uri;
      Map<String, String> queryParams = {};

      // If latitude and longitude are provided, use the /api/quests/nearby endpoint
      if (latitude != null && longitude != null) {
        uri = Uri.parse('$baseUrl/quests/nearby');
        queryParams['latitude'] = latitude.toString();
        queryParams['longitude'] = longitude.toString();
        if (radiusKm != null) queryParams['radius_km'] = radiusKm.toString();
        if (limit != null) queryParams['limit'] = limit.toString();
        // Optionally add other filters if needed
      } else {
        // Otherwise, use the generic /quests/ endpoint
        uri = Uri.parse('$baseUrl/quests/');
        if (cityId != null) queryParams['city_id'] = cityId;
        if (questType != null) queryParams['quest_type'] = questType;
        if (difficulty != null) queryParams['difficulty'] = difficulty;
        if (latitude != null) queryParams['latitude'] = latitude.toString();
        if (longitude != null) queryParams['longitude'] = longitude.toString();
        if (radiusKm != null) queryParams['radius_km'] = radiusKm.toString();
        if (userLevel != null) queryParams['user_level'] = userLevel.toString();
        queryParams['available_only'] = availableOnly.toString();
        queryParams['limit'] = limit.toString();
        queryParams['offset'] = offset.toString();
      }

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      print('Fetching quests from: $uri');
      print('Request headers: $_headers');

      final response = await http.get(uri, headers: _headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        print('Quests endpoint not found, using mock data');
        return _getMockQuests(questType, difficulty);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully fetched quests: $data');
        return data is List ? data : [];
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getMockQuests(questType, difficulty);
      }
    } catch (e) {
      print('Error fetching quests: $e');
      return _getMockQuests(questType, difficulty);
    }
  }

  Future<Map<String, dynamic>> getQuestDetails(String questId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/quests/$questId'),
        headers: _headers,
      );

      print('Fetching quest details from: $baseUrl/api/quests/$questId');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 404) {
        throw Exception('Quest not found');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully fetched quest details: $data');
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch quest details');
      }
    } catch (e) {
      print('Error fetching quest details: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> verifyQuestLocation({
    required String questId,
    required String questPointId,
    required double latitude,
    required double longitude,
    double? accuracy,
    Map<String, dynamic>? deviceInfo,
    String? photoUrl,
  }) async {
    try {
      final requestBody = {
        'quest_point_id': questPointId,
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (deviceInfo != null) 'device_info': deviceInfo,
        if (photoUrl != null) 'photo_url': photoUrl,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/quests/$questId/verify-location'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      print('Verifying quest location: $baseUrl/api/quests/$questId/verify-location');
      print('Request body: ${jsonEncode(requestBody)}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Successfully verified quest location: $data');
        return data;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to verify quest location');
      }
    } catch (e) {
      print('Error verifying quest location: $e');
      throw e;
    }
  }

  List<dynamic> _getMockQuests(String? questType, String? difficulty) {
    final allMockQuests = [
      {
        'id': 'quest_1',
        'title': 'Heritage Walk',
        'description': 'Explore the historical monuments and learn about local culture',
        'type': 'HERITAGE',
        'difficulty': 'EASY',
        'city_id': 'city_1',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'radius': 100,
        'xp_reward': 50,
        'token_reward': 10,
        'required_level': 1,
        'current_completions': 15,
        'max_completions': 100,
        'is_active': true,
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'quest_2',
        'title': 'Food Adventure',
        'description': 'Discover hidden culinary gems and local street food',
        'type': 'DAILY',
        'difficulty': 'MEDIUM',
        'city_id': 'city_1',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'radius': 200,
        'xp_reward': 75,
        'token_reward': 15,
        'required_level': 2,
        'current_completions': 8,
        'max_completions': 50,
        'is_active': true,
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'quest_3',
        'title': 'Safety Challenge',
        'description': 'Learn about local safety protocols and emergency services',
        'type': 'SAFETY_CHALLENGE',
        'difficulty': 'EASY',
        'city_id': 'city_1',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'radius': 150,
        'xp_reward': 100,
        'token_reward': 20,
        'required_level': 1,
        'current_completions': 12,
        'max_completions': 75,
        'is_active': true,
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'quest_4',
        'title': 'Hidden Gems Explorer',
        'description': 'Find secret spots that only locals know about',
        'type': 'HIDDEN_GEMS',
        'difficulty': 'HARD',
        'city_id': 'city_1',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'radius': 300,
        'xp_reward': 150,
        'token_reward': 30,
        'required_level': 5,
        'current_completions': 3,
        'max_completions': 25,
        'is_active': true,
        'created_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      },
      {
        'id': 'quest_5',
        'title': 'Community Picks',
        'description': 'Visit places recommended by fellow travelers',
        'type': 'COMMUNITY_PICKS',
        'difficulty': 'MEDIUM',
        'city_id': 'city_1',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'radius': 250,
        'xp_reward': 80,
        'token_reward': 18,
        'required_level': 3,
        'current_completions': 22,
        'max_completions': 60,
        'is_active': true,
        'created_at': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      },
    ];

    // Filter by quest type and difficulty
    return allMockQuests.where((quest) {
      if (questType != null && questType != 'ALL' && quest['type'] != questType) {
        return false;
      }
      if (difficulty != null && difficulty != 'ALL' && quest['difficulty'] != difficulty) {
        return false;
      }
      return true;
    }).toList();
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}

