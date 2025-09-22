import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String? locationName;

  const WeatherCard({
    super.key,
    this.weatherData,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final formattedDate = '${weekdays[now.weekday - 1]}, ${now.day}\n${months[now.month - 1]}';
    final temperature = weatherData?['temperature']?['degrees']?.round() ?? '--';
    final condition = weatherData?['weatherCondition']?['description']?['text'] ?? 'Loading...';
    final location = locationName ?? '...';
    final iconBaseUri = weatherData?['weatherCondition']?['iconBaseUri'];
    
    String? iconUrl;
    if (iconBaseUri != null) {
      iconUrl = '$iconBaseUri.png?size=64';
    }

    return Row(
      children: [
        Expanded(
          child: NeuContainer(
            color: const Color(0xFF87CEEB),
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$temperature°',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'gilroy',
                        ),
                      ),
                      const SizedBox(width: 8),
                      iconUrl != null
                          ? Image.network(
                              iconUrl,
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return _getWeatherIcon(condition);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                  ),
                                );
                              },
                            )
                          : _getWeatherIcon(condition),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontFamily: 'gilroy',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeuContainer(
            color: const Color(0xFFFFC0E8),
            borderColor: Colors.black,
            borderWidth: 3,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 154,
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quest Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.map, size: 40, color: Colors.green),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor = Colors.yellow;
    
    final conditionLower = condition.toLowerCase();
    
    if (conditionLower.contains('sunny') || conditionLower.contains('clear')) {
      iconData = Icons.wb_sunny;
      iconColor = Colors.yellow;
    } else if (conditionLower.contains('cloud')) {
      iconData = Icons.cloud;
      iconColor = Colors.white;
    } else if (conditionLower.contains('rain')) {
      iconData = Icons.grain;
      iconColor = Colors.lightBlue;
    } else if (conditionLower.contains('snow')) {
      iconData = Icons.ac_unit;
      iconColor = Colors.white;
    } else if (conditionLower.contains('thunder') || conditionLower.contains('storm')) {
      iconData = Icons.flash_on;
      iconColor = Colors.yellow;
    } else if (conditionLower.contains('fog') || conditionLower.contains('mist')) {
      iconData = Icons.blur_on;
      iconColor = Colors.grey[300]!;
    } else {
      iconData = Icons.wb_sunny;
      iconColor = Colors.yellow;
    }
    
    return Icon(iconData, color: iconColor, size: 24);
  }
}
