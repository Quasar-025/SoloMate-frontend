import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class ChecklistCard extends StatelessWidget {
  const ChecklistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      color: const Color(0xFFDCFD00),
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
                  "Today's Checklist",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Text(
                      'View Plans',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w300,
                        fontFamily: 'gilroy',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildChecklistItem('Book accommodation in Goa Hotel', true),
            _buildChecklistItem('Download offline maps', false),
            _buildChecklistItem('Research local customs', false),
            _buildChecklistItem('Breakfast', false),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.black : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : Colors.black,
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
