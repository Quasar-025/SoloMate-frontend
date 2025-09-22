import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';

class NearbyExploreCard extends StatefulWidget {
  const NearbyExploreCard({super.key});

  @override
  State<NearbyExploreCard> createState() => _NearbyExploreCardState();
}

class _NearbyExploreCardState extends State<NearbyExploreCard> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  String _selectedCategory = 'FOOD';
  List<dynamic> _nearbyPlaces = [];
  bool _isLoading = false;
  Position? _currentPosition;

  final Map<String, String> _categoryLabels = {
    'FOOD': 'Eat',
    'SHOPS': 'Shop',
    'MEDICAL': 'Medical',
    'TRAVEL': 'Travel',
    'TOURISM': 'Tourism',
    'ENTERTAINMENT': 'Fun',
    'SERVICES': 'Services',
  };

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeAndLoadData() async {
    await _locationService.init();
    await _getCurrentLocationAndLoadData();
  }

  @override
  void didUpdateWidget(NearbyExploreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when widget updates (triggered by parent setState)
    _getCurrentLocationAndLoadData();
  }

  Future<void> _getCurrentLocationAndLoadData() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      await _loadNearbyPlaces();
    } catch (e) {
      print('Error getting location: $e');
      // Load with mock data if location fails
      _loadMockData();
    }
  }

  Future<void> _loadNearbyPlaces() async {
    if (_currentPosition == null) return;

    setState(() => _isLoading = true);

    try {
      final data = await _apiService.getNearbyPlacesByCategory(
        category: _selectedCategory,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 2.0,
        limit: 5,
      );

      if (mounted) {
        setState(() {
          _nearbyPlaces = data['places'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading nearby places: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _loadMockData();
      }
    }
  }

  void _loadMockData() {
    setState(() {
      _nearbyPlaces = [
        {
          'name': 'Beachie Cafe',
          'vicinity': 'Chill Cafe',
          'distance_meters': 300,
          'is_open_now': true,
        },
        {
          'name': 'Ganga View Restaurant',
          'vicinity': 'River view dining',
          'distance_meters': 500,
          'is_open_now': false,
        },
        {
          'name': 'Pani Shop',
          'vicinity': 'Smoking Spot',
          'distance_meters': 300,
          'is_open_now': true,
        },
      ];
    });
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      _loadNearbyPlaces();
    }
  }

  String _formatDistance(dynamic distanceMeters) {
    if (distanceMeters == null) return '';
    
    final distance = distanceMeters is double 
        ? distanceMeters.round() 
        : distanceMeters is int 
            ? distanceMeters 
            : int.tryParse(distanceMeters.toString()) ?? 0;
    
    if (distance < 1000) {
      return '${distance}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categoryLabels.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildExploreChip(
                      entry.value,
                      entry.key,
                      _selectedCategory == entry.key,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Loading or places list
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_nearbyPlaces.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No places found nearby',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              )
            else
              // Places list
              Column(
                children: _nearbyPlaces.take(3).map<Widget>((place) {
                  return _buildNearbyItem(
                    place['name'] ?? 'Unknown Place',
                    '${place['vicinity'] ?? ''} • ${_formatDistance(place['distance_meters'])}',
                    place['is_open_now'] == true ? 'Open' : place['is_open_now'] == false ? 'Closed' : 'Unknown',
                    'Navigate',
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreChip(String label, String category, bool isSelected) {
    return GestureDetector(
      onTap: () => _onCategorySelected(category),
      child: Container(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'gilroy',
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
                      fontWeight: FontWeight.w500,
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
              onTap: () => _navigateToPlace(name),
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

  Future<void> _navigateToPlace(String placeName) async {
    try {
      // Find the place data for coordinates
      final place = _nearbyPlaces.firstWhere(
        (p) => p['name'] == placeName,
        orElse: () => null,
      );

      if (place != null && place['latitude'] != null && place['longitude'] != null) {
        // Use coordinates if available
        final lat = place['latitude'];
        final lng = place['longitude'];
        await _launchMaps(lat, lng, placeName);
      } else {
        // Fallback to search by name
        if (_currentPosition != null) {
          final currentLat = _currentPosition!.latitude;
          final currentLng = _currentPosition!.longitude;
          await _launchMapsSearch(placeName, currentLat, currentLng);
        } else {
          await _launchMapsSearch(placeName);
        }
      }
    } catch (e) {
      print('Error opening maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchMaps(double lat, double lng, String placeName) async {
    // Try multiple approaches in order of preference
    final List<String> attempts = [
      // Google Maps app with coordinates
      'google.navigation:q=$lat,$lng',
      // Generic geo intent
      'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(placeName)})',
      // Google Maps web with coordinates
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      // Fallback web URL
      'https://maps.google.com/?q=$lat,$lng',
    ];

    for (String urlString in attempts) {
      try {
        final uri = Uri.parse(urlString);
        print('Trying to launch: $urlString');
        
        // For the first two attempts (app intents), try to launch directly
        if (urlString.startsWith('google.navigation:') || urlString.startsWith('geo:')) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('Successfully launched: $urlString');
            return; // Success, exit the function
          } catch (e) {
            print('Failed to launch $urlString: $e');
            continue; // Try next option
          }
        } else {
          // For web URLs, check if they can be launched first
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('Successfully launched: $urlString');
            return; // Success, exit the function
          }
        }
      } catch (e) {
        print('Error with URL $urlString: $e');
        continue;
      }
    }

    // If all attempts failed, show error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps. Please install Google Maps or another maps app.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchMapsSearch(String placeName, [double? lat, double? lng]) async {
    final List<String> attempts = [
      // Google Maps app search
      if (lat != null && lng != null)
        'google.navigation:q=${Uri.encodeComponent(placeName)}&center=$lat,$lng',
      // Generic geo search
      if (lat != null && lng != null)
        'geo:$lat,$lng?q=${Uri.encodeComponent(placeName)}',
      // Google Maps web search
      if (lat != null && lng != null)
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(placeName)}&center=$lat,$lng',
      // Simple search without location
      'geo:0,0?q=${Uri.encodeComponent(placeName)}',
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(placeName)}',
      'https://maps.google.com/?q=${Uri.encodeComponent(placeName)}',
    ];

    for (String urlString in attempts) {
      try {
        final uri = Uri.parse(urlString);
        print('Trying to launch search: $urlString');
        
        if (urlString.startsWith('google.navigation:') || urlString.startsWith('geo:')) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('Successfully launched search: $urlString');
            return;
          } catch (e) {
            print('Failed to launch search $urlString: $e');
            continue;
          }
        } else {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('Successfully launched search: $urlString');
            return;
          }
        }
      } catch (e) {
        print('Error with search URL $urlString: $e');
        continue;
      }
    }

    // If all attempts failed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps. Please install Google Maps or another maps app.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
