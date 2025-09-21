import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get auth state stream
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    Map<String, dynamic>? data,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (data != null) updates.addAll(data);

      final response = await _client.auth.updateUser(
        UserAttributes(data: updates),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
