import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/screens/auth/signin_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/home/admin_dashboard.dart';
import 'presentation/screens/home/user_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://psjdzxdrzszriulpogmo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzamR6eGRyenN6cml1bHBvZ21vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwMzgyMzEsImV4cCI6MjA2NDYxNDIzMX0.l0HQUKLIZrmAVJHs2NUbMQe8QPKk83Hqp05fGMdGhF4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMEI App',
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/user_dashboard': (context) => UserDashboard(),
      },
    );
  }
}
