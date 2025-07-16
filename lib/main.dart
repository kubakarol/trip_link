import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trip_link/screens/auth/register/register_screen.dart';
import 'package:trip_link/screens/profile/account_actions_screen.dart';
import 'package:trip_link/screens/profile/change_password_screen.dart';
import 'package:trip_link/screens/profile/notifications_screen.dart';
import 'package:trip_link/screens/auth/setup_screen.dart';
import 'services/firebase_config.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/app_shell.dart';
import 'screens/profile/language_screen.dart';
import 'screens/profile/swipe_prefs_screen.dart';

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
        scaffoldBackgroundColor: Colors.white,
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
        '/profile/settings/language': (context) => const LanguageScreen(),
        '/profile/settings/swipe_prefs': (context) => const SwipePrefsScreen(),
        '/profile/settings/account_actions': (context) =>
            const AccountActionsScreen(),
        '/profile/settings/notifications': (context) =>
            const NotificationsScreen(),
        '/profile/settings/change_password': (context) =>
            const ChangePasswordScreen(),
      },
    );
  }
}
