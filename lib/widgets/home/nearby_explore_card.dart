import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class NearbyExploreCard extends StatelessWidget {
  const NearbyExploreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      color: const Color(0xFFC0F7FE),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearby & Explore',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildExploreChip('Eat', true),
                const SizedBox(width: 8),
                _buildExploreChip('Shop', false),
                const SizedBox(width: 8),
                _buildExploreChip('Medical', false),
                const SizedBox(width: 8),
                _buildExploreChip('Travel', false),
              ],
            ),
            const SizedBox(height: 12),
            _buildNearbyItem('Beachie Cafe', 'Chill Cafe • 300m', 'No Rush', 'Start Navigation'),
            _buildNearbyItem('Ganga View Restaurant', 'River view dining • 500m', 'Closed', 'Start Navigation'),
            _buildNearbyItem('Pani Shop', 'Smoking Spot • 300m', 'No Rush', 'Start Navigation'),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w300,
          fontFamily: 'gilroy',
        ),
      ),
    );
  }

  Widget _buildNearbyItem(String name, String description, String status, String action) {
    Color statusColor = status == 'Closed' ? Colors.red : Colors.green;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'gilroy',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(color: statusColor, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'gilroy',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC0F7FE),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {},
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w300,
                  fontFamily: 'gilroy',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
