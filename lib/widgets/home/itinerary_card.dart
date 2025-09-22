import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../screens/itinerary/itinerary_screen.dart';

class ItineraryCard extends StatelessWidget {
  final Map<String, dynamic>? itineraryData;
  final bool isLoading;

  const ItineraryCard({
    super.key,
    this.itineraryData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItineraryScreen(
                            itineraryData: itineraryData,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Full Itinerary',
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
            if (isLoading)
              _buildLoadingState()
            else if (itineraryData != null && itineraryData!['time_slots'] != null)
              _buildItineraryItems()
            else
              _buildFallbackItems(),
            if (itineraryData?['safety_notes'] != null && (itineraryData!['safety_notes'] as List).isNotEmpty)
              _buildSafetyNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) => 
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryItems() {
    final timeSlots = itineraryData!['time_slots'] as List;
    final displaySlots = timeSlots.take(3).toList(); // Show only first 3 items
    
    return Column(
      children: displaySlots.map<Widget>((slot) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildItineraryItem(
            slot['title'] ?? 'Activity',
            slot['description'] ?? 'Location details',
            '${slot['start_time'] ?? ''} - ${slot['end_time'] ?? ''}',
            slot['estimated_duration'] ?? 'Start Navigation',
            slot['difficulty'],
            slot['weather_dependent'] ?? false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFallbackItems() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildItineraryItem(
            'Morning Exploration', 
            'Start your day discovering local attractions', 
            '9:00 AM - 11:00 AM', 
            '2 hours',
            'Easy',
            false,
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
            'Afternoon Experience', 
            'Immerse yourself in local culture and cuisine', 
            '2:00 PM - 4:00 PM', 
            '2 hours',
            'Easy',
            false,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: _buildItineraryItem(
            'Evening Discovery', 
            'End your day with scenic views and relaxation', 
            '6:00 PM - 8:00 PM', 
            '2 hours',
            'Medium',
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryItem(
    String title, 
    String subtitle, 
    String time, 
    String duration,
    String? difficulty,
    bool weatherDependent,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with title and difficulty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
              ),
              if (difficulty != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(difficulty),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    difficulty,
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
          const SizedBox(height: 4),
          // Description
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'gilroy',
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          // Time row with navigation button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  if (weatherDependent) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.wb_cloudy,
                      size: 14,
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAA3DB),
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Implement navigation functionality
                  },
                  child: const Text(
                    'Navigate',
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotes() {
    final safetyNotes = itineraryData!['safety_notes'] as List;
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              safetyNotes.join(' • '),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
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
}


