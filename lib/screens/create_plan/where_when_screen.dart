import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class WhereWhenScreen extends StatefulWidget {
  final VoidCallback onNext;

  const WhereWhenScreen({super.key, required this.onNext});

  @override
  State<WhereWhenScreen> createState() => _WhereWhenScreenState();
}

class _WhereWhenScreenState extends State<WhereWhenScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  String? _selectedDestination;

  final List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Goa',
      'rating': 4.9,
      'tags': ['Beach', 'Solo Friendly', 'Budget'],
    },
    {
      'name': 'Rishikesh',
      'rating': 4.8,
      'tags': ['Nature', 'Solo Friendly', 'Devotional'],
    },
    {
      'name': 'Rameshwaram',
      'rating': 4.2,
      'tags': ['Beach', 'Solo Friendly', 'Adventure'],
    },
    {
      'name': 'Vizag',
      'rating': 4.1,
      'tags': ['Beach', 'Solo Friendly', 'Budget'],
    },
  ];

  bool get _canProceed => _selectedDestination != null && 
                         _tripNameController.text.isNotEmpty &&
                         _startDateController.text.isNotEmpty &&
                         _endDateController.text.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    _tripNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'beach':
        return Colors.blue;
      case 'solo friendly':
        return Colors.green;
      case 'budget':
        return Colors.orange;
      case 'nature':
        return Colors.green[700]!;
      case 'devotional':
        return Colors.purple;
      case 'adventure':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        controller.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Center aligned like in image
          const Center(
            child: Column(
              children: [
                Text(
                  'Where & When?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Let\'s start with the basics',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'gilroy',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Search Bar
          NeuContainer(
            color: Colors.white,
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search destinations',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              style: const TextStyle(fontFamily: 'gilroy'),
            ),
          ),
          const SizedBox(height: 16),

          // Suggestions - Left aligned
          const Text(
            'Suggestions..',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 12),

          // Destination Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1, // Adjusted for better card proportions
            ),
            itemCount: _destinations.length,
            itemBuilder: (context, index) {
              final destination = _destinations[index];
              final isSelected = _selectedDestination == destination['name'];
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDestination = destination['name']);
                },
                child: NeuContainer(
                  color: isSelected ? const Color(0xFF4ECDC4) : Colors.white,
                  borderColor: Colors.black,
                  borderWidth: 3,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top section with name and selection indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                destination['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontFamily: 'gilroy',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.white : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Color(0xFF4ECDC4),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        
                        // Rating section
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: isSelected ? Colors.white : Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              destination['rating'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black,
                                fontFamily: 'gilroy',
                              ),
                            ),
                          ],
                        ),
                        
                        // Tags section - properly aligned
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: (destination['tags'] as List<String>).take(3).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.2) 
                                        : _getTagColor(tag).withOpacity(0.1),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : _getTagColor(tag),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: isSelected ? Colors.white : _getTagColor(tag),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'gilroy',
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Trip Name - Left aligned
          const Text(
            'Trip Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 8),
          NeuContainer(
            color: Colors.white,
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              controller: _tripNameController,
              decoration: const InputDecoration(
                hintText: 'Enter trip name',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              style: const TextStyle(fontFamily: 'gilroy'),
            ),
          ),
          const SizedBox(height: 16),

          // Date Selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'gilroy',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(_startDateController),
                      child: NeuContainer(
                        color: Colors.white,
                        borderColor: Colors.black,
                        borderWidth: 3,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _startDateController.text.isEmpty 
                                      ? 'DD-MM-YYYY'
                                      : _startDateController.text,
                                  style: TextStyle(
                                    color: _startDateController.text.isEmpty 
                                        ? Colors.grey 
                                        : Colors.black,
                                    fontFamily: 'gilroy',
                                  ),
                                ),
                              ),
                              const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'gilroy',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(_endDateController),
                      child: NeuContainer(
                        color: Colors.white,
                        borderColor: Colors.black,
                        borderWidth: 3,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _endDateController.text.isEmpty 
                                      ? 'DD-MM-YYYY'
                                      : _endDateController.text,
                                  style: TextStyle(
                                    color: _endDateController.text.isEmpty 
                                        ? Colors.grey 
                                        : Colors.black,
                                    fontFamily: 'gilroy',
                                  ),
                                ),
                              ),
                              const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4ECDC4), width: 1),
            ),
            child: const Text(
              'Your Itinerary created based your selected Dates. You can edit this at plan screen',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4ECDC4),
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Next Button
          SizedBox(
            width: double.infinity,
            child: NeuTextButton(
              enableAnimation: true,
              onPressed: _canProceed ? widget.onNext : null,
              buttonColor: _canProceed 
                  ? const Color(0xFF4ECDC4) 
                  : Colors.grey[300] ?? const Color(0xFFE0E0E0),
              borderColor: Colors.black,
              borderWidth: 2,
              borderRadius: BorderRadius.circular(12),
              buttonHeight: 50,
              text: Text(
                'NEXT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _canProceed ? Colors.white : Colors.grey,
                  fontFamily: 'gilroy',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
