import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class MemoriesJournalCard extends StatelessWidget {
  const MemoriesJournalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      color: const Color(0xFFFDEABF),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memories & Journal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'gilroy',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'What did you love today...',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Share your thoughts here...',
                style: TextStyle(
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '0/1000',
              style: TextStyle(
                fontFamily: 'gilroy',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Icon(Icons.photo, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Icon(Icons.mic, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Icon(Icons.videocam, size: 20),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 12,
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
      ),
    );
  }
}
