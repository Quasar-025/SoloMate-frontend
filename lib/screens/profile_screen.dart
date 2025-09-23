import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _userStats;
  List<dynamic> _userBadges = [];
  List<dynamic> _friends = [];
  List<dynamic> _journalEntries = [];
  Map<String, List<Map<String, dynamic>>> _groupedJournalEntries = {};
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isLoadingJournal = false;
  String _selectedTab = 'Journal';
  
  // Location selector state
  bool _useCurrentLocation = true;
  String _customLocation = '';
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLocationPreference();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationPreference() async {
    await _locationService.init();
    setState(() {
      _useCurrentLocation = _locationService.useCurrentLocation;
      _customLocation = _locationService.customLocation;
      _locationController.text = _customLocation;
    });
  }

  Future<void> _saveLocationPreference() async {
    try {
      await _locationService.updateLocationPreference(
        useCurrentLocation: _useCurrentLocation,
        customLocation: _customLocation,
      );

      // Also save to API
      final response = await _apiService.updateLocationPreference(
        useCurrentLocation: _useCurrentLocation,
        customLocation: _customLocation,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Location preference saved successfully!'),
            backgroundColor: response['success'] == true ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location preference: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLocationSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Location Preference',
                style: TextStyle(
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current location option
                  RadioListTile<bool>(
                    title: const Text(
                      'Use Current Location',
                      style: TextStyle(
                        fontFamily: 'gilroy',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Automatically detect your location',
                      style: TextStyle(
                        fontFamily: 'gilroy',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    value: true,
                    groupValue: _useCurrentLocation,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        _useCurrentLocation = value ?? true;
                      });
                    },
                  ),
                  // Custom location option
                  RadioListTile<bool>(
                    title: const Text(
                      'Custom Location',
                      style: TextStyle(
                        fontFamily: 'gilroy',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Manually enter your location',
                      style: TextStyle(
                        fontFamily: 'gilroy',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    value: false,
                    groupValue: _useCurrentLocation,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        _useCurrentLocation = value ?? true;
                      });
                    },
                  ),
                  // Custom location input field
                  if (!_useCurrentLocation) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Location',
                        hintText: 'e.g., New York, London, Tokyo',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(fontFamily: 'gilroy'),
                      onChanged: (value) {
                        _customLocation = value;
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'gilroy'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!_useCurrentLocation && _customLocation.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a location'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    setState(() {
                      // Update the main state
                    });
                    
                    Navigator.of(context).pop();
                    _saveLocationPreference();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontFamily: 'gilroy'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch all user data from the single /auth/me endpoint
      final userData = await _authService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _userProfile = userData;
          // Extract stats from the same user data object
          _userStats = {
            'completed_quests': 0, // Not in /auth/me response, default to 0
            'cities_visited': 0, // Not in /auth/me response, default to 0
            'total_xp': userData['total_xp'] ?? 0,
            'level': userData['level'] ?? 1,
          };
          _userBadges = []; // Not in /auth/me response
          _friends = []; // Not in /auth/me response
          _isLoading = false;
        });
        
        // Load journal entries after user data is loaded
        _loadJournalEntries();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        // Fallback to mock data if API fails
        setState(() {
          _userProfile = {
            'username': 'User',
            'email': 'user@example.com',
            'is_verified': false,
            'profile_image_url': null,
          };
          _userStats = {
            'completed_quests': 0,
            'cities_visited': 0,
            'total_xp': 0,
            'level': 1,
          };
          _isLoading = false;
        });
        _loadJournalEntries(); // Still try to load journal entries
      }
    }
  }

  Future<void> _loadJournalEntries() async {
    setState(() => _isLoadingJournal = true);
    
    try {
      final response = await _apiService.getJournalEntries(limit: 50);
      
      if (mounted) {
        final entries = response['entries'] ?? [];
        
        // Group entries by location/city
        final Map<String, List<Map<String, dynamic>>> groupedEntries = {};
        
        for (final entry in entries) {
          final location = entry['location'] ?? 'Unknown Location';
          if (!groupedEntries.containsKey(location)) {
            groupedEntries[location] = [];
          }
          groupedEntries[location]!.add(entry);
        }
        
        // Sort entries within each city by date (newest first)
        groupedEntries.forEach((city, cityEntries) {
          cityEntries.sort((a, b) {
            final dateA = DateTime.parse(a['date']);
            final dateB = DateTime.parse(b['date']);
            return dateB.compareTo(dateA);
          });
        });
        
        setState(() {
          _journalEntries = entries;
          _groupedJournalEntries = groupedEntries;
          _isLoadingJournal = false;
        });
      }
    } catch (e) {
      print('Error loading journal entries: $e');
      if (mounted) {
        setState(() {
          _journalEntries = [];
          _groupedJournalEntries = {};
          _isLoadingJournal = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      // Clear navigation stack and go to get started
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/get_started',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F5E8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileCard(),
              _buildStatsCards(),
              _buildActionButtons(),
              _buildTabSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 24),
          ),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'gilroy',
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text(
                  'Logout',
                  style: TextStyle(fontFamily: 'gilroy'),
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // Background with mountain illustration
          NeuContainer(
            color: const Color(0xFFB19CD9),
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB19CD9), Color(0xFF9B7EBD)],
                ),
              ),
              child: CustomPaint(
                painter: MountainPainter(),
              ),
            ),
          ),
          // Profile content
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Profile image
                NeuContainer(
                  color: Colors.white,
                  borderColor: Colors.black,
                  borderWidth: 3,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF4ECDC4),
                    ),
                    child: _userProfile?['profile_image_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _userProfile!['profile_image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // Username and verification
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _userProfile?['name'] ?? _userProfile?['username'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'gilroy',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_userProfile?['is_verified'] == true)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '@${(_userProfile?['username'] ?? 'user').toLowerCase().replaceAll(' ', '')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'gilroy',
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adventure seeker exploring the world one quest at a time!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontFamily: 'gilroy',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '${_friends.length}',
              'Followers',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '${_userBadges.length}',
              'NFTs Owned',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '${_userStats?['cities_visited'] ?? 0}',
              'Locations',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return NeuContainer(
      color: Colors.white,
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Location selector
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: NeuContainer(
              color: const Color(0xFFF0F0F0),
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _showLocationSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location Preference',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily: 'gilroy',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _locationService.getDisplayLocation(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontFamily: 'gilroy',
                                fontWeight: FontWeight.w300,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Existing action buttons
          Row(
            children: [
              Expanded(
                child: NeuContainer(
                  color: const Color(0xFFCDFF85),
                  borderColor: Colors.black,
                  borderWidth: 3,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      setState(() => _isFollowing = !_isFollowing);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isFollowing ? 'Following' : 'Edit Profile',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'gilroy',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isFollowing ? Icons.check : Icons.edit,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              NeuContainer(
                color: Colors.white,
                borderColor: Colors.black,
                borderWidth: 3,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  child: const Icon(Icons.share, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tab headers
          Row(
            children: [
              _buildTabHeader('Journal', _selectedTab == 'Journal'),
              const SizedBox(width: 24),
              _buildTabHeader('NFTs owned', _selectedTab == 'NFTs owned'),
            ],
          ),
          const SizedBox(height: 16),
          // Tab content
          _selectedTab == 'Journal' ? _buildJournalContent() : _buildNFTContent(),
        ],
      ),
    );
  }

  Widget _buildTabHeader(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : Colors.grey,
              fontFamily: 'gilroy',
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: Colors.black,
            ),
        ],
      ),
    );
  }

  Widget _buildJournalContent() {
    if (_isLoadingJournal) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_groupedJournalEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No journal entries yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start writing about your adventures!',
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
      children: _groupedJournalEntries.entries.map((cityEntry) {
        final cityName = cityEntry.key;
        final cityEntries = cityEntry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C88FF), Color(0xFF7B68EE)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cityEntries.length} ${cityEntries.length == 1 ? 'entry' : 'entries'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // City entries
            ...cityEntries.map((entry) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildJournalCard(entry),
              ),
            ).toList(),
            
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNFTContent() {
    final List<Map<String, String>> nftImages = [
      {'image': 'assets/images/culture.png', 'title': 'Culture Quest'},
      {'image': 'assets/images/deepsea.png', 'title': 'Deep Sea Diver'},
      {'image': 'assets/images/night.png', 'title': 'Night Owl Quest'},
      {'image': 'assets/images/star.png', 'title': 'Star Gazer'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: nftImages.length,
      itemBuilder: (context, index) {
        return _buildPostCard(nftImages[index]);
      },
    );
  }

  Widget _buildPostCard(Map<String, String> nftData) {
    return NeuContainer(
      color: const Color(0xFFF0F0F0),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(nftData['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nftData['title']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'gilroy',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(Map<String, dynamic> entry) {
    final DateTime entryDate = DateTime.parse(entry['date']);
    final String formattedDate = '${entryDate.day}/${entryDate.month}/${entryDate.year}';
    final String content = entry['content'] ?? '';
    final String location = entry['location'] ?? '';
    final List<dynamic> tags = entry['tags'] ?? [];

    return NeuContainer(
      color: Colors.white,
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'gilroy',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'gilroy',
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'gilroy',
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags.take(3).map<Widget>((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontFamily: 'gilroy',
                              fontWeight: FontWeight.w500,
                            ),
                          ));
                        }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation(entry['id']);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String entryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Journal Entry'),
          content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJournalEntry(entryId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteJournalEntry(String entryId) async {
    try {
      final response = await _apiService.deleteJournalEntry(entryId);
      
      if (response['success'] == true) {
        // Remove the entry from both the flat list and grouped entries
        setState(() {
          _journalEntries.removeWhere((entry) => entry['id'] == entryId);
          
          // Remove from grouped entries and clean up empty cities
          _groupedJournalEntries.forEach((city, entries) {
            entries.removeWhere((entry) => entry['id'] == entryId);
          });
          
          // Remove cities with no entries
          _groupedJournalEntries.removeWhere((city, entries) => entries.isEmpty);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journal entry deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to delete entry'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting entry: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Custom painter for mountain background
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Draw mountain silhouettes
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw tent
    final tentPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final tentPath = Path();
    final tentX = size.width * 0.3;
    final tentY = size.height * 0.8;
    
    tentPath.moveTo(tentX - 20, tentY);
    tentPath.lineTo(tentX, tentY - 30);
    tentPath.lineTo(tentX + 20, tentY);
    tentPath.close();

    canvas.drawPath(tentPath, tentPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}