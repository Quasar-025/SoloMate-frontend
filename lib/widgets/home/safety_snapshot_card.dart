import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class SafetySnapshotCard extends StatelessWidget {
  const SafetySnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      color: const Color(0xFFE0E0FF),
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
                  'Safety Snapshot',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Currently Safe Place',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Feeling Unsafe? Click\nSOS Track & Report!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'gilroy',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      NeuContainer(
                        color: Colors.red,
                        borderColor: Colors.black,
                        borderWidth: 3,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'gilroy',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'gilroy',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLocationToggle('Mom', true),
                      _buildLocationToggle('Dad', false),
                      _buildLocationToggle('Brother', false),
                      _buildLocationToggle('Friend', false),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Live location automatically shows with nearest POLICE station On click of SOS BUTTON',
                              style: TextStyle(
                                fontSize: 10, 
                                color: Colors.red,
                                fontFamily: 'gilroy',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationToggle(String name, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name, 
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'gilroy',
              fontWeight: FontWeight.w300,
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {},
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
