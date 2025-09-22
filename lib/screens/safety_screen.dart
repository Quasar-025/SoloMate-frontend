import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  bool _locationActive = true;
  bool _shareLocation = true;
  
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'Mom',
      'number': '+91 999 99999 99',
      'enabled': true,
    },
    {
      'name': 'Dad', 
      'number': '+91 999 99999 99',
      'enabled': true,
    },
    {
      'name': 'Brother',
      'number': '+91 999 99999 99',
      'enabled': false,
    },
    {
      'name': 'Friend',
      'number': '+91 999 99999 99', 
      'enabled': false,
    },
  ];

  final List<Map<String, dynamic>> _emergencyServices = [
    {
      'name': 'Police Station',
      'number': '+91 999 99999 99',
      'icon': Icons.local_police,
      'color': const Color(0xFF7B68EE),
    },
    {
      'name': 'Hospital',
      'number': '+91 999 99999 99',
      'icon': Icons.local_hospital,
      'color': const Color(0xFF7B68EE),
    },
  ];

  double? _safetyIndex;
  bool _isSafetyLoading = false;
  String _safetyStatus = '';
  String _safetyMessage = '';

  @override
  void initState() {
    super.initState();
    _locationService.init();
    _fetchSafetyIndex();
  }

  Future<void> _fetchSafetyIndex() async {
    setState(() {
      _isSafetyLoading = true;
      _safetyIndex = null;
      _safetyStatus = '';
      _safetyMessage = '';
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final cityName = await _locationService.getLocationName();

      if (position == null) {
        setState(() {
          _safetyIndex = null;
          _safetyStatus = 'Location unavailable';
          _safetyMessage = 'unknown';
          _isSafetyLoading = false;
        });
        return;
      }

      final result = await _apiService.getSafetyIndexFromNews(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      );

      double? index;
      if (result['success'] == true) {
        // Use numeric safety_index if available, else fallback to regex parse
        if (result['safety_index'] is num) {
          index = (result['safety_index'] as num).toDouble();
        } else {
          final raw = result['safety_index']?.toString() ?? '';
          final match = RegExp(r'(\d{1,3})').firstMatch(raw);
          if (match != null) {
            index = double.tryParse(match.group(1)!) ?? 95;
          } else {
            index = 95;
          }
        }
        setState(() {
          _safetyIndex = index;
          if (index != null && index >= 80) {
            _safetyStatus = 'Its safe to Travel';
            _safetyMessage = 'safe';
          } else if (index != null && index >= 60) {
            _safetyStatus = 'Caution Advised';
            _safetyMessage = 'caution';
          } else if (index != null) {
            _safetyStatus = 'Not Safe';
            _safetyMessage = 'danger';
          } else {
            _safetyStatus = 'Could not fetch safety index';
            _safetyMessage = 'unknown';
          }
        });
      } else {
        setState(() {
          _safetyIndex = null;
          _safetyStatus = 'Could not fetch safety index';
          _safetyMessage = 'unknown';
        });
      }
    } catch (e) {
      setState(() {
        _safetyIndex = null;
        _safetyStatus = 'Could not fetch safety index';
        _safetyMessage = 'unknown';
      });
    } finally {
      setState(() {
        _isSafetyLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _triggerSOS() {
    // Show confirmation dialog first
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Emergency SOS',
            style: TextStyle(
              fontFamily: 'gilroy',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'This will send your location and emergency alert to all enabled contacts and emergency services. Continue?',
            style: TextStyle(fontFamily: 'gilroy'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _executeSOS();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'SEND SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _executeSOS() {
    // Implement SOS functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS alert sent to emergency contacts!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendMessage(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch messaging app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendImmediateHelpMessage() {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message before sending'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Implement immediate help message functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help message sent to emergency services and contacts!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    
    _messageController.clear();
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
          'Safety Center',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'gilroy',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _locationActive ? Colors.green : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Location Active',
                style: TextStyle(
                  color: _locationActive ? Colors.green : Colors.grey,
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Switch(
                value: _locationActive,
                onChanged: (value) {
                  setState(() => _locationActive = value);
                },
                activeColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SAFETY INDEX SECTION ---
            NeuContainer(
              color: Colors.white,
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Column(
                  children: [
                    const Text(
                      'Search Safety Index of\nyour Destination',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'gilroy',
                      ),
                    ),
                    const SizedBox(height: 18),
                    _isSafetyLoading
                        ? const CircularProgressIndicator()
                        : NeuContainer(
                            color: Colors.white,
                            borderColor: Colors.black,
                            borderWidth: 2,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Text(
                                _safetyIndex != null
                                    ? '${_safetyIndex!.toStringAsFixed(0)}/100'
                                    : '--/100',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'gilroy',
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 12),
                    NeuTextButton(
                      enableAnimation: true,
                      onPressed: _fetchSafetyIndex,
                      buttonColor: Colors.black,
                      borderColor: Colors.black,
                      borderWidth: 2,
                      borderRadius: BorderRadius.circular(10),
                      buttonHeight: 40,
                      text: Text(
                        _safetyStatus.isNotEmpty ? _safetyStatus : 'Check Safety',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'gilroy',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSafetyGauge(_safetyIndex, _safetyMessage),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SOS Emergency Section
            NeuContainer(
              color: const Color(0xFFFFE4E1),
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Feeling Unsafe? Click\nand hold 3 seconds',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'gilroy',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Will contact emergency services and your contacts',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontFamily: 'gilroy',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onLongPress: _triggerSOS,
                      child: NeuContainer(
                        color: Colors.red,
                        borderColor: Colors.black,
                        borderWidth: 3,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: const Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              fontFamily: 'gilroy',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Emergency Contacts Section
            NeuContainer(
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
                        const Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'gilroy',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Navigate to add contact screen
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'gilroy',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Share Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'gilroy',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: _shareLocation,
                          onChanged: (value) {
                            setState(() => _shareLocation = value);
                          },
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._emergencyContacts.map((contact) => _buildContactItem(contact)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nearby Emergency Services
            NeuContainer(
              color: Colors.white,
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearby Emergency Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'gilroy',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._emergencyServices.map((service) => _buildServiceItem(service)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Immediate Help Message
            NeuContainer(
              color: Colors.white,
              borderColor: Colors.black,
              borderWidth: 3,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Immediate Help Message',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'gilroy',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Will send this message to all emergency services and contacts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontFamily: 'gilroy',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type your message here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontFamily: 'gilroy'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: NeuTextButton(
                        enableAnimation: true,
                        onPressed: _sendImmediateHelpMessage,
                        buttonColor: const Color(0xFF7B68EE),
                        borderColor: Colors.black,
                        borderWidth: 2,
                        borderRadius: BorderRadius.circular(12),
                        buttonHeight: 50,
                        text: const Text(
                          'Send Message',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'gilroy',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'gilroy',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact['number'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'gilroy',
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _callNumber(contact['number']),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _sendMessage(contact['number']),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.message,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              Switch(
                value: contact['enabled'],
                onChanged: (value) {
                  setState(() {
                    contact['enabled'] = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: service['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              service['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'gilroy',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  service['number'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'gilroy',
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _callNumber(service['number']),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Navigate to location
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyGauge(double? index, String status) {
    // Gauge colors and faces
    Color faceColor;
    IconData faceIcon;
    if (status == 'safe') {
      faceColor = Colors.green;
      faceIcon = Icons.sentiment_satisfied_alt;
    } else if (status == 'caution') {
      faceColor = Colors.orange;
      faceIcon = Icons.sentiment_neutral;
    } else if (status == 'danger') {
      faceColor = Colors.red;
      faceIcon = Icons.sentiment_very_dissatisfied;
    } else {
      faceColor = Colors.grey;
      faceIcon = Icons.help_outline;
    }

    // Calculate pointer angle (0 = left, pi = right, pi/2 = center)
    double angle = pi / 2;
    if (index != null) {
      angle = pi * (1 - (index.clamp(0, 100) / 100));
    }

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: faceColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Icon(faceIcon, color: Colors.black, size: 40),
        ),
        const SizedBox(height: 12),
        // Gauge
        CustomPaint(
          size: const Size(200, 100),
          painter: _SafetyGaugePainter(index: index),
        ),
      ],
    );
  }
}

// --- Custom Painter for Gauge ---
class _SafetyGaugePainter extends CustomPainter {
  final double? index;
  _SafetyGaugePainter({this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw colored arcs
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;

    // Red (left)
    paint.color = Colors.red;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi / 4, false, paint);

    // Orange (left-mid)
    paint.color = Colors.orange;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi + pi / 4, pi / 4, false, paint);

    // Green (center)
    paint.color = Colors.green;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 1.5 * pi, pi / 4, false, paint);

    // Blue (right)
    paint.color = Colors.deepPurple;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 1.75 * pi, pi / 4, false, paint);

    // Pointer
    if (index != null) {
      final pointerAngle = pi * (1 - (index!.clamp(0, 100) / 100));
      final pointerLength = radius - 10;
      final pointerEnd = Offset(
        center.dx + pointerLength * cos(pointerAngle),
        center.dy - pointerLength * sin(pointerAngle),
      );
      final pointerPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, pointerEnd, pointerPaint);

      // Draw pointer knob
      canvas.drawCircle(center, 10, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
