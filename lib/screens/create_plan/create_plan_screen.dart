import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'where_when_screen.dart';
import 'budget_style_screen.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // On final step, show success and go back
      Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFF3),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Create Plan',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'gilroy',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildProgressBar(),
          ),
          // Page Content - Updated order
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                WhereWhenScreen(onNext: _nextStep),
                BudgetStyleScreen(onNext: _nextStep, onBack: _previousStep),
                _PlaceholderScreen(title: 'Final Screen', onNext: _nextStep, onBack: _previousStep),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        children: [
          // Background track
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Progress fill
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: (MediaQuery.of(context).size.width - 40) * 
                   ((_currentStep + 1) / _totalSteps), // Adjusted calculation
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Progress indicator circle
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: ((MediaQuery.of(context).size.width - 40) * 
                  ((_currentStep + 1) / _totalSteps)) - 8, // Better positioning
            top: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for future screens
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _PlaceholderScreen({
    required this.title,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: NeuTextButton(
                  enableAnimation: true,
                  onPressed: onBack,
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
                  onPressed: onNext,
                  buttonColor: const Color(0xFF4ECDC4),
                  borderColor: Colors.black,
                  borderWidth: 2,
                  borderRadius: BorderRadius.circular(12),
                  buttonHeight: 50,
                  text: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
}

