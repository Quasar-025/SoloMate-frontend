import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _selectedGender == null) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your gender'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updateUserProfile({
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
      });
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/ai_preferences');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_info.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    NeuContainer(
                      color: Colors.white,
                      borderColor: Colors.black,
                      borderWidth: 2,
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Personal Info',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Your Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  if (value.length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text('Age', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Your Age',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your age';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age < 13 || age > 120) {
                                    return 'Please enter a valid age (13-120)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildGenderOption('Male', Icons.male, const Color(0xFF4ECDC4)),
                                  _buildGenderOption('Female', Icons.female, const Color(0xFFFF6B9D)),
                                  _buildGenderOption('Other', Icons.person, Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _isLoading
                                  ? Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF82B4FF),
                                        border: Border.all(color: Colors.black, width: 2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      ),
                                    )
                                  : NeuTextButton(
                                      enableAnimation: true,
                                      onPressed: _updateProfile,
                                      buttonColor: const Color(0xFF82B4FF),
                                      borderColor: Colors.black,
                                      borderWidth: 2,
                                      borderRadius: BorderRadius.circular(12),
                                      buttonHeight: 50,
                                      text: const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, Color color) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: NeuContainer(
        color: isSelected ? color : Colors.white,
        borderColor: Colors.black,
        borderWidth: 3,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 60,
          height: 60,
          child: Icon(
            icon,
            size: 30,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
