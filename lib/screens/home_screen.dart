import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../screens/profile_screen.dart';
import '../widgets/common/home_header.dart';
import '../widgets/home/weather_card.dart';
import '../widgets/home/checklist_card.dart';
import '../widgets/home/itinerary_card.dart';
import '../widgets/home/nearby_explore_card.dart';
import '../widgets/home/memories_journal_card.dart';
import '../widgets/home/safety_snapshot_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _userStats;
  List<dynamic> _nearbyQuests = [];
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _itineraryData;
  String? _locationName;
  bool _isLoading = true;
  bool _isItineraryLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    // Clear the callback when disposing
    _locationService.setLocationChangeCallback(null);
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _locationService.init();
    
    // Set up callback for location changes
    _locationService.setLocationChangeCallback(() {
      print('Location changed, refreshing data...');
      _refreshLocationDependentData();
    });
    
    _loadData();
  }

  Future<void> _refreshLocationDependentData() async {
    // Refresh weather and itinerary data when location changes
    await _loadWeatherData();
    
    // Also trigger refresh in child widgets by calling setState
    if (mounted) {
      setState(() {
        // This will cause child widgets to rebuild and fetch new data
      });
    }
  }

  Future<void> _loadData() async {
    try {
      if (!_authService.isAuthenticated) {
        if (mounted) {
          // Clear navigation stack and go to get started
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/get_started',
            (Route<dynamic> route) => false,
          );
        }
        return;
      }

      final userInfo = await _authService.getCurrentUser();
      
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });

      _loadAdditionalData();
      _loadWeatherData();
      
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading user data: $e');
      
      if (e.toString().contains('401') || e.toString().contains('authentication')) {
        // Clear auth and navigate to get started
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/get_started',
            (Route<dynamic> route) => false,
          );
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! Some features may be limited.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadAdditionalData() async {
    try {
      final userStats = await _apiService.getUserStats();
      final nearbyQuests = await _apiService.getNearbyQuests();
      
      if (mounted) {
        setState(() {
          _userStats = userStats;
          _nearbyQuests = nearbyQuests;
        });
      }
    } catch (e) {
      print('Error loading additional data: $e');
      // Set default data instead of leaving empty
      if (mounted) {
        setState(() {
          _userStats = {
            'completed_quests': 0,
            'cities_visited': 0,
            'total_xp': 0,
            'level': 1,
          };
          _nearbyQuests = [];
        });
      }
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        throw Exception('Unable to get location');
      }

      print('Current position: ${position.latitude}, ${position.longitude}');

      final locationName = await _locationService.getLocationName();
      final weatherData = await _apiService.getCurrentWeather(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _locationName = locationName;
        });
        
        // Load itinerary after we have location data
        _loadItineraryData(position.latitude, position.longitude, locationName);
      }
    } catch (e) {
      print('Error loading weather data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not fetch weather. ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadItineraryData(double latitude, double longitude, String cityName) async {
    if (_isItineraryLoading) return;
    
    setState(() => _isItineraryLoading = true);
    
    try {
      final now = DateTime.now();
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      final formattedDate = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
      
      print('Loading itinerary for: $cityName on $formattedDate at ($latitude, $longitude)');
      
      final itineraryData = await _apiService.generateItinerary(
        cityName: cityName,
        date: formattedDate,
        latitude: latitude,
        longitude: longitude,
        additionalData: {}, // Send empty object as in Postman
      );
      
      print('Received itinerary data: $itineraryData');
      
      if (mounted) {
        setState(() {
          _itineraryData = itineraryData;
          _isItineraryLoading = false;
        });
      }
    } catch (e) {
      print('Error loading itinerary data: $e');
      if (mounted) {
        setState(() {
          _isItineraryLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFF3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation from home screen
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFF3),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadData();
              // Reload itinerary if we have location data
              final position = await _locationService.getCurrentPosition();
              if (position != null && _locationName != null) {
                await _loadItineraryData(position.latitude, position.longitude, _locationName!);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(userInfo: _userInfo),
                  const SizedBox(height: 20),
                  WeatherCard(
                    weatherData: _weatherData,
                    locationName: _locationName,
                  ),
                  const SizedBox(height: 20),
                  const ChecklistCard(),
                  const SizedBox(height: 20),
                  ItineraryCard(
                    itineraryData: _itineraryData,
                    isLoading: _isItineraryLoading,
                  ),
                  const SizedBox(height: 20),
                  const NearbyExploreCard(),
                  const SizedBox(height: 20),
                  const MemoriesJournalCard(),
                  const SizedBox(height: 20),
                  const SafetySnapshotCard(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 3)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Capture'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Social'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}