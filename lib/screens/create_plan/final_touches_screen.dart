import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FinalTouchesScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const FinalTouchesScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<FinalTouchesScreen> createState() => _FinalTouchesScreenState();
}

class _FinalTouchesScreenState extends State<FinalTouchesScreen> {
  String _selectedSafetyPriority = 'Medium';
  final TextEditingController _specialRequestsController = TextEditingController();
  String? _uploadedFileName;
  File? _uploadedFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _safetyOptions = ['High', 'Medium', 'Low'];

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _selectSafetyPriority(String priority) {
    setState(() {
      _selectedSafetyPriority = priority;
    });
  }

  Future<void> _pickImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _uploadedFileName = image.name;
                        _uploadedFile = File(image.path);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _uploadedFileName = image.name;
                        _uploadedFile = File(image.path);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Final touches',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Any special requirements?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'gilroy',
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 32),

          // Safety Priority Section
          const Text(
            'Safety Priority',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: _safetyOptions.map((option) {
              final isSelected = _selectedSafetyPriority == option;
              String subtitle = '';
              switch (option) {
                case 'High':
                  subtitle = 'Extra safe';
                  break;
                case 'Medium':
                  subtitle = 'Balanced';
                  break;
                case 'Low':
                  subtitle = 'Adventures';
                  break;
              }
              
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: option != _safetyOptions.last ? 8 : 0,
                    left: option != _safetyOptions.first ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _selectSafetyPriority(option),
                    child: NeuContainer(
                      color: isSelected ? Colors.black : Colors.white,
                      borderColor: Colors.black,
                      borderWidth: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Column(
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : Colors.black,
                                fontFamily: 'gilroy',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white70 : Colors.grey,
                                fontFamily: 'gilroy',
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Special Requests Section
          const Text(
            'Special Requests (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 12),

          NeuContainer(
            color: Colors.white,
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              controller: _specialRequestsController,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Special Request\'s',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                counterText: '',
              ),
              style: const TextStyle(fontFamily: 'gilroy'),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '1000 characters left',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'gilroy',
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Upload Documents Section
          const Text(
            'Upload any travel documents if required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'gilroy',
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _pickImage,
            child: NeuContainer(
              color: Colors.white,
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    if (_uploadedFileName != null)
                      Text(
                        _uploadedFileName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          fontFamily: 'gilroy',
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      const Column(
                        children: [
                          Text(
                            'Click to upload',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                              fontFamily: 'gilroy',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Photos from camera or gallery',
                            style: TextStyle(
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
            ),
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
                  onPressed: widget.onNext,
                  buttonColor: const Color(0xFF4ECDC4),
                  borderColor: Colors.black,
                  borderWidth: 2,
                  borderRadius: BorderRadius.circular(12),
                  buttonHeight: 50,
                  text: const Text(
                    'Done',
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
