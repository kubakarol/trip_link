import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trip_link/screens/register/register_screen.dart';
import 'package:trip_link/screens/settings_screen.dart';
import 'package:trip_link/screens/setup_screen.dart';
import 'services/firebase_config.dart';
import 'screens/welcome_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripLink',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const AppShell(),
        '/setup': (context) => const SetupScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
