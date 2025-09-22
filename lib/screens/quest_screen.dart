import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();
  
  List<dynamic> _nearbyQuests = [];
  List<dynamic> _allQuests = [];
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;
  bool _isLocationDetected = false;
  String _selectedFilter = 'ALL';
  String _selectedDifficulty = 'ALL';
  String? _currentLocation;

  final List<String> _questTypes = ['ALL', 'DAILY', 'WEEKLY', 'HERITAGE', 'HIDDEN_GEMS', 'SAFETY_CHALLENGE', 'COMMUNITY_PICKS'];
  final List<String> _difficulties = ['ALL', 'EASY', 'MEDIUM', 'HARD', 'EXTREME'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _locationService.init();
    await _loadUserStats();
    await _detectLocation();
    await _loadQuests();
  }

  Future<void> _loadUserStats() async {
    try {
      final userData = await _authService.getCurrentUser();
      final userStats = await _apiService.getUserStats();
      
      if (mounted) {
        setState(() {
          _userStats = {
            ...userStats,
            'name': userData['name'] ?? userData['username'] ?? 'User',
            'level': userData['level'] ?? userStats['level'] ?? 1,
          };
        });
      }
    } catch (e) {
      print('Error loading user stats: $e');
      if (mounted) {
        setState(() {
          _userStats = {
            'name': 'User',
            'level': 1,
            'completed_quests': 0,
            'total_xp': 0,
            'badges_earned': 0,
          };
        });
      }
    }
  }

  Future<void> _detectLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final locationName = await _locationService.getLocationName();
        setState(() {
          _isLocationDetected = true;
          _currentLocation = locationName;
        });
      }
    } catch (e) {
      print('Error detecting location: $e');
      setState(() {
        _isLocationDetected = false;
        _currentLocation = 'Location not detected';
      });
    }
  }

  Future<void> _loadQuests() async {
    setState(() => _isLoading = true);
    
    try {
      final position = await _locationService.getCurrentPosition();
      
      // Load nearby quests if location is available
      if (position != null) {
        final nearbyQuests = await _apiService.getNearbyQuests(
          lat: position.latitude,
          lng: position.longitude,
        );
        
        setState(() {
          _nearbyQuests = nearbyQuests;
        });
      }

      // Load all quests with filters
      final allQuests = await _apiService.getQuests(
        questType: _selectedFilter != 'ALL' ? _selectedFilter : null,
        difficulty: _selectedDifficulty != 'ALL' ? _selectedDifficulty : null,
        userLevel: _userStats?['level'],
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (mounted) {
        setState(() {
          _allQuests = allQuests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading quests: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startQuest(String questId) async {
    try {
      final response = await _apiService.startQuest(questId);
      
      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Quest started successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Reload quests to update status
          _loadQuests();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to start quest'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start quest: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateTripDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Create New Trip',
            style: TextStyle(
              fontFamily: 'gilroy',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Trip creation feature coming soon! You\'ll be able to create custom adventures based on your preferences.',
            style: TextStyle(fontFamily: 'gilroy'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadQuests,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildQuestStatusCard(),
                const SizedBox(height: 20),
                _buildLocationCard(),
                const SizedBox(height: 20),
                _buildCreateTripCard(),
                const SizedBox(height: 20),
                _buildFilters(),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildQuestsList(),
                const SizedBox(height: 80), // Add padding for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, ${_userStats?['name'] ?? 'User'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'gilroy',
                ),
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
        // Add spacing between text and icon
        const SizedBox(width: 12),
        NeuContainer(
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
      ],
    );
  }

  Widget _buildQuestStatusCard() {
    final completedQuests = _userStats?['completed_quests'] ?? 0;
    final totalXP = _userStats?['total_xp'] ?? 0;
    final badgesCollected = _userStats?['badges_earned'] ?? 0;
    final level = _userStats?['level'] ?? 1;

    return NeuContainer(
      color: const Color(0xFFCDFF85),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quest Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar('Quest Status', completedQuests, 10),
                  const SizedBox(height: 12),
                  _buildProgressBar('XP', totalXP, (level + 1) * 100),
                  const SizedBox(height: 12),
                  _buildProgressBar('Badges Collected', badgesCollected, 10),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Character illustration placeholder
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int max) {
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'gilroy',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Filled portions
              ...List.generate(10, (index) {
                final isActive = index < (progress * 10);
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return NeuContainer(
      color: const Color(0xFFC0F7FE),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLocationDetected 
                        ? 'Ahh it seems you are at a new location!'
                        : 'Location Detection',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentLocation ?? 'Detecting your location...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'gilroy',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeuTextButton(
                    enableAnimation: true,
                    onPressed: _isLocationDetected ? () => _loadQuests() : _detectLocation,
                    buttonColor: const Color(0xFFCDFF85),
                    borderColor: Colors.black,
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(12),
                    buttonHeight: 40,
                    text: Text(
                      _isLocationDetected ? 'Start New Quest' : 'Detect Location',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Location illustration placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(
                Icons.location_city,
                size: 40,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTripCard() {
    return NeuContainer(
      color: const Color(0xFFB19CD9),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Want to go somewhere Exciting?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'gilroy',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            NeuTextButton(
              enableAnimation: true,
              onPressed: _showCreateTripDialog,
              buttonColor: Colors.white,
              borderColor: Colors.black,
              borderWidth: 2,
              borderRadius: BorderRadius.circular(12),
              buttonHeight: 40,
              text: const Text(
                'Create a new Trip',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'gilroy',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quest Types',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'gilroy',
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _questTypes.map((type) {
              final isSelected = _selectedFilter == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = type);
                    _loadQuests();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type.replaceAll('_', ' '),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _difficulties.map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedDifficulty = difficulty);
                    _loadQuests();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? _getDifficultyColor(difficulty) : Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestsList() {
    final questsToShow = _nearbyQuests.isNotEmpty ? _nearbyQuests : _allQuests;
    
    if (questsToShow.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.explore_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No quests available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or check back later for new adventures!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'gilroy',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _nearbyQuests.isNotEmpty ? 'Nearby Quests' : 'All Quests',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'gilroy',
          ),
        ),
        const SizedBox(height: 12),
        ...questsToShow.map((quest) => _buildQuestCard(quest)).toList(),
      ],
    );
  }

  Widget _buildQuestCard(Map<String, dynamic> quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeuContainer(
        color: Colors.white,
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
                  Expanded(
                    child: Text(
                      quest['title'] ?? 'Quest',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(quest['difficulty']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quest['difficulty'] ?? 'EASY',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quest['description'] ?? 'Explore and discover amazing places!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w300,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                children: [
                  _buildQuestInfo(Icons.star, '${quest['xp_reward'] ?? 0} XP'),
                  const SizedBox(width: 16),
                  _buildQuestInfo(Icons.access_time, quest['type'] ?? 'DAILY'),
                  const SizedBox(width: 16),
                  if (quest['required_level'] != null)
                    _buildQuestInfo(Icons.trending_up, 'Lvl ${quest['required_level']}'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Completions: ${quest['current_completions'] ?? 0}/${quest['max_completions'] ?? '∞'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                  NeuTextButton(
                    enableAnimation: true,
                    onPressed: () => _startQuest(quest['id']),
                    buttonColor: const Color(0xFF4ECDC4),
                    borderColor: Colors.black,
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(8),
                    buttonHeight: 36,
                    text: const Text(
                      'Start Quest',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'gilroy',
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HARD':
        return Colors.red;
      case 'EXTREME':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
        currentIndex: 1, // Quests tab is selected
        onTap: (index) {
          switch (index) {
            case 0:
              // Home
              Navigator.pop(context);
              break;
            case 1:
              // Quests - already here
              break;
            case 2:
              // Safety
              Navigator.pushReplacementNamed(context, '/safety');
              break;
            case 3:
              // Profile
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Quests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Safety',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
