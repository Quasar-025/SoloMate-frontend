import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final LocationService _locationService = LocationService();
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

  @override
  void initState() {
    super.initState();
    _locationService.init();
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
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search for safety requirements',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(fontFamily: 'gilroy'),
              ),
            ),
            const SizedBox(height: 20),

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
}
