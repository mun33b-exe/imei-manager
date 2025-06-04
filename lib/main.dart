import 'package:flutter/material.dart';
import 'package:imei/presentation/screens/auth/signin_screen.dart';
import 'package:imei/presentation/screens/auth/signup_screen.dart';
import 'package:imei/config/theme/app_theme.dart';

void main() {
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
      home: const SignInScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

