import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/personal_info_screen.dart';
import 'screens/auth/ai_preferences_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth/get_started_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/safety_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize services
    await AuthService().init();
    await LocationService().init();
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
        scaffoldBackgroundColor: const Color(0xFFFFFFF3),
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
      home: const AuthWrapper(),
      routes: {
        // '/': (context) => const SplashScreen(),
        '/get_started': (context) => const GetStartedScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/personal_info': (context) => const PersonalInfoScreen(),
        '/ai_preferences': (context) => const AIPreferencesScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        // '/safety': (context) => const SafetyScreen(),
        '/quest': (context) => const QuestScreen(),
        '/safety': (context) => const SafetyScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authService = AuthService();
      
      // Check if user has a valid token
      if (authService.isAuthenticated) {
        // Verify token is still valid by trying to get user info
        await authService.getCurrentUser();
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Auth check failed: $e');
      // If auth check fails, clear any invalid tokens and show get started
      await AuthService().logout();
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFF3),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const HomeScreen();
    } else {
      return const GetStartedScreen();
    }
  }
}
