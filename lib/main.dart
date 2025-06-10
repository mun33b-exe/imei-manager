import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:imei/presentation/screens/auth/signin_screen.dart';
import 'package:imei/presentation/screens/auth/signup_screen.dart';
import 'package:imei/presentation/screens/auth/auth_wrapper.dart';
import 'package:imei/presentation/screens/dashboard/user_dashboard_screen.dart';
import 'package:imei/presentation/screens/dashboard/admin_dashboard_screen.dart';
import 'package:imei/config/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMEI Registration',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/user-dashboard': (context) => const UserDashboardScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
