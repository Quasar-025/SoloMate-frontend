import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedFilters = [];

  final List<String> _filters = ['woman safe', 'Solo Friendly', 'Budget', 'Adventure'];

  final List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Peaceful Goa Beaches',
      'description': 'Perfect beaches and vibrant nightlife',
      'tags': ['Beach', 'Solo Friendly', 'Budget'],
      'price': '₹2,000-4,000/day',
      'duration': '3 days',
      'rating': 4.9,
      'image': 'assets/images/CultureQuest.jpg',
    },
    {
      'name': 'Rishikesh',
      'description': 'Yoga capital and adventure sports',
      'tags': ['Adventure', 'Solo Friendly'],
      'price': '₹2,000-4,000/day',
      'duration': '3 days',
      'rating': 4.9,
      'image': 'assets/images/itinerary_detail_bg.jpg',
    },
    {
      'name': 'Udaipur',
      'description': 'City of lakes and royal palaces',
      'tags': ['Culture', 'Solo Friendly'],
      'price': '₹2,500-5,000/day',
      'duration': '3 days',
      'rating': 4.9,
      'image': 'assets/images/bg_profile.png',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFF3),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Trip Planner',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'gilroy',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create New Plan Card
            NeuContainer(
              color: const Color(0xFFC0F7FE),
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'gilroy',
                            ),
                          ),
                          Text(
                            'Step by step trip planning',
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
                    const Icon(Icons.arrow_forward_ios, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // AI Trip Planner Card
            NeuContainer(
              color: const Color(0xFFFFC0E8),
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Trip Planner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'gilroy',
                            ),
                          ),
                          Text(
                            'Tell us your dream,we\'ll plan',
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
                    const Icon(Icons.arrow_forward_ios, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Explore Destinations Section
            const Text(
              'Explore Destinations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search destinations',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: TextStyle(fontFamily: 'gilroy'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilters.contains(filter);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _toggleFilter(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF7B68EE) : Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
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
            const SizedBox(height: 20),
            
            // Destinations List
            ...(_destinations.map((destination) => _buildDestinationCard(destination))),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeuContainer(
        color: Colors.white,
        borderColor: Colors.black,
        borderWidth: 3,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                  image: DecorationImage(
                    image: AssetImage(destination['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'gilroy',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              destination['rating'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'gilroy',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      destination['description'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'gilroy',
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Tags
                    Wrap(
                      spacing: 4,
                      children: (destination['tags'] as List<String>).map((tag) {
                        Color tagColor;
                        switch (tag.toLowerCase()) {
                          case 'beach':
                            tagColor = Colors.blue;
                            break;
                          case 'solo friendly':
                            tagColor = Colors.green;
                            break;
                          case 'budget':
                            tagColor = Colors.orange;
                            break;
                          case 'adventure':
                            tagColor = Colors.red;
                            break;
                          case 'culture':
                            tagColor = Colors.purple;
                            break;
                          default:
                            tagColor = Colors.grey;
                        }
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.1),
                            border: Border.all(color: tagColor, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: tagColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'gilroy',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    
                    // Price and Duration
                    Row(
                      children: [
                        Text(
                          destination['price'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'gilroy',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          destination['duration'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'gilroy',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
