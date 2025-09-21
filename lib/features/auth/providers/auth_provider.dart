import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';
import '../../shared/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  // Mock credentials for testing
  static const String _mockEmail = 'test@example.com';
  static const String _mockPassword = 'test123';

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider(this._authService) {
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
        // Create a mock UserModel
        _user = UserModel(
          id: '123',
          email: email,
          name: 'Test User',
          role: 'worker',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
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
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock registration logic for testing
      if (email.isNotEmpty && password.length >= 6) {
        _user = UserModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: name,
          role: 'worker',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
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
