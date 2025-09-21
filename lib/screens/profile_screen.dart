import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _userStats;
  List<dynamic> _userBadges = [];
  List<dynamic> _friends = [];
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      child: Row(
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
              _buildTabHeader('Posts', true),
              const SizedBox(width: 24),
              _buildTabHeader('NFTs owned', false),
            ],
          ),
          const SizedBox(height: 16),
          // Grid content
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: 4, // Placeholder count
            itemBuilder: (context, index) {
              return _buildPostCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(String title, bool isSelected) {
    return Column(
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
    );
  }

  Widget _buildPostCard(int index) {
    final locations = ['Nainital', 'Goa', 'Kerala', 'Rajasthan'];
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              locations[index % locations.length],
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
