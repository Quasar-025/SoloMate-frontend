import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../screens/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  final Map<String, dynamic>? userInfo;

  const HomeHeader({
    super.key,
    this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    
    final displayName = userInfo?['name'] ?? userInfo?['username'] ?? 'User';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $displayName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'gilroy',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const Text(
                'Ready for your adventure?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: NeuContainer(
            color: Colors.white,
            borderColor: Colors.black,
            borderWidth: 2,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF4ECDC4),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
