import 'package:flutter/foundation.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Mock User class for testing without Supabase
class MockUser {
  final String id;
  final String email;
  final Map<String, dynamic>? userMetadata;

  MockUser({
    required this.id,
    required this.email,
    this.userMetadata,
  });
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  MockUser? _user;
  String? _errorMessage;

  // Mock credentials for testing
  static const String _mockEmail = 'test@example.com';
  static const String _mockPassword = 'test123';

  AuthStatus get status => _status;
  MockUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    // For testing, start as unauthenticated
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock authentication logic for testing
      if (email == _mockEmail && password == _mockPassword) {
        _user = MockUser(
          id: '123',
          email: email,
          userMetadata: {'full_name': 'Test User'},
        );
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _setLoading();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock registration logic for testing
      if (email.isNotEmpty && password.length >= 6) {
        _user = MockUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          userMetadata: {'full_name': fullName ?? 'User'},
        );
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading();
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock password reset
      if (email.isNotEmpty && email.contains('@')) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email address');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _status = AuthStatus.error;
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
