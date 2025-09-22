import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'itinerary_detail_screen.dart';

class ItineraryScreen extends StatelessWidget {
  final Map<String, dynamic>? itineraryData;

  const ItineraryScreen({
    super.key,
    this.itineraryData,
  });

  Map<String, dynamic> get _fallbackData => {
        'time_slots': [
          {
            'start_time': '09:00 AM',
            'end_time': '10:30 AM',
            'title': 'Morning Heritage Walk',
            'description': 'Explore historic downtown area',
            'difficulty': 'Easy',
            'weather_dependent': true,
            'estimated_duration': '1.5 hours'
          },
          {
            'start_time': '11:00 AM',
            'end_time': '12:30 PM',
            'title': 'Local Market Visit',
            'description': 'Experience local culture and food',
            'difficulty': 'Medium',
            'weather_dependent': false,
            'estimated_duration': '1.5 hours'
          },
          {
            'start_time': '02:00 PM',
            'end_time': '04:00 PM',
            'title': 'Adventure Activity',
            'description': 'Outdoor excitement and fun',
            'difficulty': 'Hard',
            'weather_dependent': true,
            'estimated_duration': '2 hours'
          }
        ]
      };

  @override
  Widget build(BuildContext context) {
    final data = itineraryData ?? _fallbackData;
    final slots = data['time_slots'] as List?;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Today's Itinerary",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ],
              ),
            ),
            // Itinerary content
            if (slots == null || slots.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No itinerary items available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildItineraryItem(context, slot),
                    );
                  },
                ),
              ),
            // Bottom navigation
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryItem(BuildContext context, Map<String, dynamic> slot) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItineraryDetailScreen(itineraryItem: slot),
        ),
      ),
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
                  Text(
                    '${slot['start_time']} - ${slot['end_time']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(slot['difficulty']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slot['difficulty'] ?? 'Normal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                slot['title'] ?? 'Activity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'gilroy',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slot['description'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'gilroy',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (slot['weather_dependent'] == true) ...[
                        const Icon(Icons.wb_sunny, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Weather dependent',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'gilroy',
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        slot['estimated_duration'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'gilroy',
                        ),
                      ),
                    ],
                  ),
                  NeuContainer(
                    color: const Color(0xFFFAA3DB),
                    borderColor: Colors.black,
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItineraryDetailScreen(
                              itineraryItem: slot,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Read More',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'gilroy',
                          ),
                        ),
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

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.map_outlined, 'Quests', false),
          _buildNavItem(Icons.edit_note, 'Safety', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: selected ? Colors.black : Colors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.grey,
            fontSize: 12,
            fontFamily: 'gilroy',
          ),
        ),
      ],
    );
  }
}
