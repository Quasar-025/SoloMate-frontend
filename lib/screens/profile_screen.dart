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
  List<dynamic> _journalEntries = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isLoadingJournal = false;
  String _selectedTab = 'Journal';

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
      final response = await _apiService.getJournalEntries(limit: 20);
      
      if (mounted) {
        setState(() {
          _journalEntries = response['entries'] ?? [];
          _isLoadingJournal = false;
        });
      }
    } catch (e) {
      print('Error loading journal entries: $e');
      if (mounted) {
        setState(() {
          _journalEntries = [];
          _isLoadingJournal = false;
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

    if (_journalEntries.isEmpty) {
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: _journalEntries.length,
      itemBuilder: (context, index) {
        return _buildJournalCard(_journalEntries[index]);
      },
    );
  }

  Widget _buildNFTContent() {
    return GridView.builder(
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
        // Remove the entry from the local list
        setState(() {
          _journalEntries.removeWhere((entry) => entry['id'] == entryId);
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
