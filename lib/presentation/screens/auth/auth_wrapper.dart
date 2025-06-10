import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/user_role.dart';
import '../auth/signin_screen.dart';
import '../dashboard/user_dashboard_screen.dart';
import '../dashboard/admin_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is not signed in, show sign in screen
        if (!snapshot.hasData || snapshot.data == null) {
          return const SignInScreen();
        }

        // If user is signed in, determine which dashboard to show
        return FutureBuilder<AppUser?>(
          future: AuthService().getUserData(snapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError || !userSnapshot.hasData) {
              return const SignInScreen();
            }

            final user = userSnapshot.data!;

            // Navigate to appropriate dashboard based on role
            if (user.role == UserRole.admin) {
              return const AdminDashboardScreen();
            } else {
              return const UserDashboardScreen();
            }
          },
        );
      },
    );
  }
}
