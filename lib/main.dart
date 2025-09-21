import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth/get_started_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize auth service
    await AuthService().init();
  } catch (e) {
    // Handle initialization errors gracefully
    print('Initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trove',
      theme: ThemeData(
        fontFamily: 'gilroy',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          displayMedium: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          displaySmall: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          headlineLarge: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          titleSmall: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          bodyLarge: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          bodyMedium: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          bodySmall: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          labelLarge: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w700),
          labelMedium: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
          labelSmall: TextStyle(fontFamily: 'gilroy', fontWeight: FontWeight.w300),
        ),
      ),
      // Always start with login screen to avoid auth check issues during development
      initialRoute: '/get_started',
      routes: {
        '/get_started': (context) => const GetStartedScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
