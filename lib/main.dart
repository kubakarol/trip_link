import 'package:flutter/material.dart';
import 'package:trip_link/services/firebase_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/register/register_screen.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/auth/setup_screen.dart';
import 'screens/app_shell.dart';
import 'screens/profile/language_screen.dart';
import 'screens/profile/swipe_prefs_screen.dart';
import 'screens/profile/account_actions_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(seedColor: Colors.blue);
    final scheme = base.copyWith(
      background: Colors.white,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'TripLink',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.background,
        canvasColor: scheme.surface,
        cardColor: scheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: scheme.surface,
          selectedItemColor: scheme.primary,
          unselectedItemColor: scheme.onSurface.withOpacity(0.6),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: scheme.primary,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/setup': (_) => const SetupScreen(),
        '/home': (_) => const AppShell(),
        '/profile/settings/language': (_) => const LanguageScreen(),
        '/profile/settings/swipe_prefs': (_) => const SwipePrefsScreen(),
        '/profile/settings/account_actions': (_) =>
            const AccountActionsScreen(),
        '/profile/settings/notifications': (_) => const NotificationsScreen(),
        '/profile/settings/change_password': (_) =>
            const ChangePasswordScreen(),
      },
    );
  }
}
