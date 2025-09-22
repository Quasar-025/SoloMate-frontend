import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class ItineraryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itineraryItem;

  const ItineraryDetailScreen({
    super.key,
    required this.itineraryItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header image
              Container(
                height: 240,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/itinerary_detail_bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black26,
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      // Title and time
                      Text(
                        itineraryItem['title'] ?? 'Activity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'gilroy',
                        ),
                      ),
                      Text(
                        '${itineraryItem['start_time']} • ${itineraryItem['estimated_duration']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontFamily: 'gilroy',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tour highlights section
                    const Text(
                      'Tour Highlights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'gilroy',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        _buildHighlightItem('Explore the Laxman Jhula Area, a historic suspension bridge with breathtaking views of the Ganges.'),
                        _buildHighlightItem('Visit nearby local temples and experience the spiritual charm of Rishikesh.'),
                        _buildHighlightItem('Discover hidden artisan shops tucked along the walking route.'),
                        _buildHighlightItem('Learn fascinating stories and legends from your local guide.'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Info section
                    _buildInfoSection(
                      'Duration',
                      'Approx. ${itineraryItem['estimated_duration']}',
                      Icons.access_time,
                    ),
                    _buildInfoSection(
                      'Difficulty',
                      itineraryItem['difficulty'] ?? 'Easy',
                      Icons.trending_up,
                    ),
                    if (itineraryItem['weather_dependent'] == true)
                      _buildInfoSection(
                        'Weather',
                        'Sunny, 24°C',
                        Icons.wb_sunny,
                      ),
                    const SizedBox(height: 24),
                    // Start Navigation button
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                        child: NeuTextButton(
                          enableAnimation: true,
                          onPressed: () {},
                          buttonColor: const Color(0xFFFAA3DB),
                          borderColor: Colors.black,
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(12),
                          buttonHeight: 50,
                          text: const Text(
                            'Start Navigation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: 'gilroy',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Add bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: 'gilroy',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'gilroy',
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'gilroy',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
