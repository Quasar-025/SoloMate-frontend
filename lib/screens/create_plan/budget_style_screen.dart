import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class BudgetStyleScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BudgetStyleScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<BudgetStyleScreen> createState() => _BudgetStyleScreenState();
}

class _BudgetStyleScreenState extends State<BudgetStyleScreen> {
  double _budget = 1000;
  String? _selectedTravelStyle;

  final List<Map<String, dynamic>> _travelStyles = [
    {
      'id': 'chill_relax',
      'title': 'Chill&Relax',
      'subtitle': 'Cafes,Beaches,slow travel',
      'color': const Color(0xFFFFD93D),
      'icon': Icons.coffee,
    },
    {
      'id': 'culture_heritage',
      'title': 'Culture & Heritage',
      'subtitle': 'Museums, local experiences',
      'color': const Color(0xFFFF6B6B),
      'icon': Icons.museum,
    },
    {
      'id': 'adventure_thrill',
      'title': 'Adventure & Thrill',
      'subtitle': 'Hiking, sports, exploration',
      'color': const Color(0xFF4ECDC4),
      'icon': Icons.hiking,
    },
    {
      'id': 'mix_everything',
      'title': 'Mix of Everything',
      'subtitle': 'Balanced experience',
      'color': const Color(0xFFB19CD9),
      'icon': Icons.apps,
    },
  ];

  bool get _canProceed => _selectedTravelStyle != null;

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
                  'Budget & Style',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'How do you like to travel?',
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

          // Budget Section - Left aligned
          const Text(
            'Budget per day: ₹3000',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 16),

          // Budget Container with Slider
          NeuContainer(
            color: Colors.white,
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Budget Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: Text(
                          '${_budget.round()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'gilroy',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF4ECDC4),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: const Color(0xFF4ECDC4),
                      overlayColor: const Color(0xFF4ECDC4).withAlpha(32),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _budget,
                      min: 500,
                      max: 10000,
                      divisions: 19,
                      onChanged: (value) {
                        setState(() => _budget = value);
                      },
                    ),
                  ),
                  
                  // Min Max Labels
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹500',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'gilroy',
                        ),
                      ),
                      Text(
                        '₹10,000',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'gilroy',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Travel Style Section - Left aligned
          const Text(
            'Travel Style',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 16),

          // Travel Style Options
          Column(
            children: _travelStyles.map((style) {
              final isSelected = _selectedTravelStyle == style['id'];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedTravelStyle = style['id']);
                  },
                  child: NeuContainer(
                    color: isSelected ? style['color'] : Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 3,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : style['color'],
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Icon(
                              style['icon'],
                              color: isSelected ? style['color'] : Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontFamily: 'gilroy',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  style['subtitle'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                    fontFamily: 'gilroy',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: NeuTextButton(
                  enableAnimation: true,
                  onPressed: widget.onBack,
                  buttonColor: Colors.white,
                  borderColor: Colors.black,
                  borderWidth: 2,
                  borderRadius: BorderRadius.circular(12),
                  buttonHeight: 50,
                  text: const Text(
                    'BACK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
