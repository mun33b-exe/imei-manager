import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String cnic,
    required UserRole role,
  }) async {
    try {
      // Create user with Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Create user document in Firestore
        final AppUser appUser = AppUser(
          uid: user.uid,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          cnic: cnic,
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(appUser.toFirestore());

        // Update display name
        await user.updateDisplayName(fullName);

        return appUser;
      }
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
    return null;
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        return await getUserData(user.uid);
      }
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
    return null;
  }

  // Sign in with phone number (for Pakistani phone numbers)
  Future<AppUser?> signInWithPhoneNumber({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // First, get user by phone number from Firestore
      final QuerySnapshot userQuery =
          await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No user found with this phone number');
      }

      final userData = userQuery.docs.first.data() as Map<String, dynamic>;
      final email = userData['email'] as String;

      // Sign in with email and password
      return await signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Phone sign in failed: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
    return null;
  }

  // Update user data
  Future<void> updateUserData(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.copyWith(updatedAt: DateTime.now()).toFirestore());
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Check if email exists
  Future<bool> isEmailRegistered(String email) async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if phone number exists
  Future<bool> isPhoneRegistered(String phoneNumber) async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if CNIC exists
  Future<bool> isCnicRegistered(String cnic) async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('users')
              .where('cnic', isEqualTo: cnic)
              .limit(1)
              .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get all users (for admin)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection('users')
              .orderBy('createdAt', descending: true)
              .get();

      return result.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all users: ${e.toString()}');
    }
  }

  // Get user statistics (for admin)
  Future<Map<String, int>> getUserStats() async {
    try {
      final QuerySnapshot allUsersResult =
          await _firestore.collection('users').get();

      final QuerySnapshot adminUsersResult =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'admin')
              .get();

      final QuerySnapshot regularUsersResult =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'user')
              .get();

      return {
        'total': allUsersResult.docs.length,
        'admin': adminUsersResult.docs.length,
        'user': regularUsersResult.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get user stats: ${e.toString()}');
    }
  }
}
