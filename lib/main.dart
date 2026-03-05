import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/views/auth/login_screen.dart';
import 'core/themes/app_theme.dart';
import 'views/onboarding/onboarding_screen.dart';

import 'services/auth_provider.dart';
import 'services/task_provider.dart';
import 'views/home/home_screen.dart';

import 'services/notification_service.dart';

import 'services/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management App',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    // If we're not authenticated, show either Onboarding or Login
    if (_showLogin) {
      return const LoginScreen();
    }

    return OnboardingScreen(onStart: () => setState(() => _showLogin = true));
  }
}

// Temporary simple state management
class AppState extends ChangeNotifier {
  // Add state logic here later
}
