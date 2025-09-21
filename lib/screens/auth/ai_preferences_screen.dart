import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class AIPreferencesScreen extends StatefulWidget {
  const AIPreferencesScreen({super.key});

  @override
  State<AIPreferencesScreen> createState() => _AIPreferencesScreenState();
}

class _AIPreferencesScreenState extends State<AIPreferencesScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': "What's your ideal adventure level when exploring new places?",
      'key': 'adventure_level',
      'type': 'single',
      'options': [
        {'value': 'low_key', 'text': 'Low-key explorer', 'icon': '☕'},
        {'value': 'balanced', 'text': 'Balanced adventurer', 'icon': '⚖️'},
        {'value': 'thrill_seeker', 'text': 'Thrill Seeker', 'icon': '🏔️'},
        {'value': 'cultural', 'text': 'Cultural immersion', 'icon': '🏛️'},
      ],
    },
    {
      'question': "How important is safety and predictability in your travel plans?",
      'key': 'safety_priority',
      'type': 'single',
      'options': [
        {'value': 'high', 'text': 'High priority', 'icon': '🛡️'},
        {'value': 'medium', 'text': 'Medium priority', 'icon': '⚖️'},
        {'value': 'low', 'text': 'Low priority', 'icon': '🎲'},
        {'value': 'contextual', 'text': 'Contextual', 'icon': '🤔'},
      ],
    },
    {
      'question': "Which types of activities excite you most? (Select all that apply)",
      'key': 'activity_preferences',
      'type': 'multiple',
      'options': [
        {'value': 'heritage', 'text': 'Heritage & Historical', 'icon': '🏛️'},
        {'value': 'food', 'text': 'Food & Culinary', 'icon': '🌮'},
        {'value': 'arts', 'text': 'Arts & Cultural', 'icon': '🎨'},
        {'value': 'nature', 'text': 'Nature & Outdoor', 'icon': '🌿'},
        {'value': 'shopping', 'text': 'Shopping & Markets', 'icon': '🛍️'},
        {'value': 'entertainment', 'text': 'Entertainment', 'icon': '🎪'},
        {'value': 'photography', 'text': 'Photography', 'icon': '📸'},
        {'value': 'fitness', 'text': 'Fitness & Sports', 'icon': '🏃‍♂️'},
      ],
    },
    {
      'question': "How do you prefer to structure your exploration time?",
      'key': 'structure_preference',
      'type': 'single',
      'options': [
        {'value': 'structured', 'text': 'Structured itinerary', 'icon': '📋'},
        {'value': 'flexible', 'text': 'Flexible framework', 'icon': '🔄'},
        {'value': 'spontaneous', 'text': 'Spontaneous discovery', 'icon': '🎯'},
        {'value': 'mixed', 'text': 'Mixed approach', 'icon': '🎭'},
      ],
    },
    {
      'question': "How would you like our AI to communicate recommendations?",
      'key': 'communication_style',
      'type': 'single',
      'options': [
        {'value': 'detailed', 'text': 'Detailed explanations', 'icon': '📝'},
        {'value': 'quick', 'text': 'Quick suggestions', 'icon': '⚡'},
        {'value': 'story', 'text': 'Story-driven', 'icon': '📚'},
        {'value': 'data', 'text': 'Data-driven', 'icon': '📊'},
        {'value': 'personal', 'text': 'Personal assistant', 'icon': '🤖'},
      ],
    },
  ];

  void _selectOption(String questionKey, String optionValue, String type) {
    setState(() {
      if (type == 'multiple') {
        if (_answers[questionKey] == null) {
          _answers[questionKey] = <String>[];
        }
        List<String> currentAnswers = List<String>.from(_answers[questionKey]);
        if (currentAnswers.contains(optionValue)) {
          currentAnswers.remove(optionValue);
        } else {
          currentAnswers.add(optionValue);
        }
        _answers[questionKey] = currentAnswers;
      } else {
        _answers[questionKey] = optionValue;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitAnswers();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  bool _canProceed() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final answer = _answers[currentQuestion['key']];
    
    if (currentQuestion['type'] == 'multiple') {
      return answer != null && (answer as List).isNotEmpty;
    } else {
      return answer != null;
    }
  }

  Future<void> _submitAnswers() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Send answers to backend when API is ready
      print('AI Preferences Data: $_answers');
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_info.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with logo - same positioning as personal info screen
                  NeuContainer(
                    color: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 3,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TROVE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your next adventure awaits.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question container - same width as TROVE header
                  NeuContainer(
                    color: Colors.white,
                    borderColor: Colors.black,
                    borderWidth: 3,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        currentQuestion['question'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'gilroy',
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Options - smaller width, centered
                  ...currentQuestion['options'].map<Widget>((option) {
                    final isSelected = _isOptionSelected(
                      currentQuestion['key'],
                      option['value'],
                      currentQuestion['type'],
                    );
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Center(
                        child: SizedBox(
                          width: 250, // Smaller fixed width for options
                          child: GestureDetector(
                            onTap: () => _selectOption(
                              currentQuestion['key'],
                              option['value'],
                              currentQuestion['type'],
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFAA3DB) : const Color(0xFFC6EDEF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black, width: 3),
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Icon(
                                      currentQuestion['type'] == 'multiple'
                                          ? Icons.check_box
                                          : Icons.radio_button_checked,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  if (isSelected) const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option['text'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontFamily: 'gilroy',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                  
                  // Continue button - same width as TROVE header
                  _isLoading
                      ? Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        )
                      : NeuTextButton(
                        enableAnimation: true,
                          onPressed: _canProceed() ? _nextQuestion : null,
                          buttonColor: _canProceed()
                              ? const Color(0xFF4ECDC4)
                              : Colors.grey[300] ?? const Color(0xFFE0E0E0),
                          borderColor: Colors.black,
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(12),
                          buttonHeight: 50,
                          text: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'Continue'
                                : 'Next',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _canProceed() ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isOptionSelected(String questionKey, String optionValue, String type) {
    final answer = _answers[questionKey];
    if (answer == null) return false;
    
    if (type == 'multiple') {
      return (answer as List).contains(optionValue);
    } else {
      return answer == optionValue;
    }
  }
}