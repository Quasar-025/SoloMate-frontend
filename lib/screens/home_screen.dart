import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _userStats;
  List<dynamic> _nearbyQuests = [];
  Map<String, dynamic>? _weatherData;
  String? _locationName;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // First check if user is authenticated
      if (!_authService.isAuthenticated) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      final userInfo = await _authService.getCurrentUser();
      
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });

      // Load additional data after the basic UI is shown
      _loadAdditionalData();
      _loadWeatherData();
      
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading user data: $e');
      
      // If there's an auth error, redirect to login
      if (e.toString().contains('401') || e.toString().contains('authentication')) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome! Some features may be limited.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadAdditionalData() async {
    try {
      // Load user stats and other data in background
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
      // Don't show error for additional data - just log it
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      print('Current position: ${position.latitude}, ${position.longitude}');

      // Fetch location name
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      String locationName = '...';
      if (placemarks.isNotEmpty) {
        locationName = placemarks.first.locality ?? placemarks.first.administrativeArea ?? '...';
      }

      final weatherData = await _apiService.getCurrentWeather(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _locationName = locationName;
        });
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

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildWeatherCard(),
                const SizedBox(height: 20),
                _buildChecklist(),
                const SizedBox(height: 20),
                _buildItinerary(),
                const SizedBox(height: 20),
                _buildNearbyExplore(),
                const SizedBox(height: 20),
                _buildMemoriesJournal(),
                const SizedBox(height: 20),
                _buildSafetySnapshot(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    // Determine greeting based on time of day
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    
    // Use name if available, otherwise fallback to username
    final displayName = _userInfo?['name'] ?? _userInfo?['username'] ?? 'User';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $displayName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'gilroy',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const Text(
                'Ready for your adventure?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: NeuContainer(
            color: Colors.white,
            borderColor: Colors.black,
            borderWidth: 2,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF4ECDC4),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final formattedDate = '${weekdays[now.weekday - 1]}, ${now.day}\n${months[now.month - 1]}';
    final temperature = _weatherData?['temperature']?['degrees']?.round() ?? '--';
    final condition = _weatherData?['weatherCondition']?['description']?['text'] ?? 'Loading...';
    final location = _locationName ?? '...';
    final iconBaseUri = _weatherData?['weatherCondition']?['iconBaseUri'];
    
    // Construct proper icon URL with required parameters
    String? iconUrl;
    if (iconBaseUri != null) {
      iconUrl = '$iconBaseUri.png?size=64';
    }

    return Row(
      children: [
        Expanded(
          child: NeuContainer(
            color: const Color(0xFF87CEEB),
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$temperature°',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'gilroy',
                        ),
                      ),
                      const SizedBox(width: 8),
                      iconUrl != null
                          ? Image.network(
                              iconUrl,
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                print('Weather icon load error: $error');
                                return _getWeatherIcon(condition);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                  ),
                                );
                              },
                            )
                          : _getWeatherIcon(condition),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontFamily: 'gilroy',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeuContainer(
            color: const Color(0xFFFFC0E8),
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 154,
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quest Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  Spacer(),
                  // Add quest illustration here
                  Icon(Icons.map, size: 40, color: Colors.green),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor = Colors.yellow;
    
    final conditionLower = condition.toLowerCase();
    
    if (conditionLower.contains('sunny') || conditionLower.contains('clear')) {
      iconData = Icons.wb_sunny;
      iconColor = Colors.yellow;
    } else if (conditionLower.contains('cloud')) {
      iconData = Icons.cloud;
      iconColor = Colors.white;
    } else if (conditionLower.contains('rain')) {
      iconData = Icons.grain;
      iconColor = Colors.lightBlue;
    } else if (conditionLower.contains('snow')) {
      iconData = Icons.ac_unit;
      iconColor = Colors.white;
    } else if (conditionLower.contains('thunder') || conditionLower.contains('storm')) {
      iconData = Icons.flash_on;
      iconColor = Colors.yellow;
    } else if (conditionLower.contains('fog') || conditionLower.contains('mist')) {
      iconData = Icons.blur_on;
      iconColor = Colors.grey[300]!;
    } else {
      iconData = Icons.wb_sunny;
      iconColor = Colors.yellow;
    }
    
    return Icon(iconData, color: iconColor, size: 24);
  }

  Widget _buildChecklist() {
    return NeuContainer(
      color: const Color(0xFFDCFD00),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Checklist",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Text(
                      'View Plans',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w300,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildChecklistItem('Book accommodation in Goa Hotel', true),
            _buildChecklistItem('Download offline maps', false),
            _buildChecklistItem('Research local customs', false),
            _buildChecklistItem('Breakfast', false),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.black : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : Colors.black,
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerary() {
    return NeuContainer(
      color: const Color(0xFFC5C6FF),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Itinerary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Text(
                      'View Itinerary',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w300,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildItineraryItem(
                'Local Walking Tour', 
                'Laxman Jhula Area • 8 min walk', 
                '9:00 AM', 
                'Start Navigation', 
                Colors.white
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildItineraryItem(
                'Local Walking Tour', 
                'Partly cloudy', 
                '2:00 PM', 
                'Start Navigation', 
                Colors.white
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: _buildItineraryItem(
                'Local Walking Tour', 
                'Laxman Jhula Area • 8 min walk', 
                '6:00 PM', 
                'Start Navigation', 
                Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryItem(String title, String subtitle, String time, String action, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'gilroy',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'gilroy',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFAA3DB),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {},
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontFamily: 'gilroy',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyExplore() {
    return NeuContainer(
      color: const Color(0xFFC0F7FE),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearby & Explore',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildExploreChip('Eat', true),
                const SizedBox(width: 8),
                _buildExploreChip('Shop', false),
                const SizedBox(width: 8),
                _buildExploreChip('Medical', false),
                const SizedBox(width: 8),
                _buildExploreChip('Travel', false),
              ],
            ),
            const SizedBox(height: 12),
            _buildNearbyItem('Beachie Cafe', 'Chill Cafe • 300m', 'No Rush', 'Start Navigation'),
            _buildNearbyItem('Ganga View Restaurant', 'River view dining • 500m', 'Closed', 'Start Navigation'),
            _buildNearbyItem('Pani Shop', 'Smoking Spot • 300m', 'No Rush', 'Start Navigation'),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w300,
          fontFamily: 'gilroy',
        ),
      ),
    );
  }

  Widget _buildNearbyItem(String name, String description, String status, String action) {
    Color statusColor = status == 'Closed' ? Colors.red : Colors.green;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'gilroy',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(color: statusColor, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC0F7FE),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {},
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w300,
                  fontFamily: 'gilroy',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesJournal() {
    return NeuContainer(
      color: const Color(0xFFFDEABF),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memories & Journal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'What did you love today...',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Share your thoughts here...',
                style: TextStyle(
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '0/1000',
              style: TextStyle(
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Icon(Icons.photo, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Icon(Icons.mic, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Icon(Icons.videocam, size: 20),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetySnapshot() {
    return NeuContainer(
      color: const Color(0xFFE0E0FF),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Safety Snapshot',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Currently Safe Place',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Feeling Unsafe? Click\nSOS Track & Report!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'gilroy',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      NeuContainer(
                        color: Colors.red,
                        borderColor: Colors.black,
                        borderWidth: 3,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'gilroy',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'gilroy',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLocationToggle('Mom', true),
                      _buildLocationToggle('Dad', false),
                      _buildLocationToggle('Brother', false),
                      _buildLocationToggle('Friend', false),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Live location automatically shows with nearest POLICE station On click of SOS BUTTON',
                              style: TextStyle(
                                fontSize: 10, 
                                color: Colors.red,
                                fontFamily: 'gilroy',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationToggle(String name, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name, 
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'gilroy',
              fontWeight: FontWeight.w300,
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {},
            activeColor: Colors.blue,
          ),
        ],
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
          if (index == 4) { // Profile tab
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

