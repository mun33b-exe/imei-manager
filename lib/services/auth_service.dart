import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up with role
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String cnic,
    required String phone,
    required String role,
  }) async {
    // Get role_id from role name
    final roleResponse = await _supabase
        .from('roles')
        .select('id')
        .eq('name', role.toLowerCase())
        .single();

    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'cnic': cnic,
        'phone': phone,
        'role_id': roleResponse['id'],
      },
    );
  }

  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Get current user with role
  Future<Map<String, dynamic>?> getCurrentUserWithRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('users')
        .select('*, roles(*)')
        .eq('id', user.id)
        .single();

    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}