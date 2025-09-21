// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_hierarchy_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/location_models.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final LocationHierarchyService _locationService = LocationHierarchyService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Location data for registration
  List<Region> _regions = [];
  List<Council> _councils = [];
  List<Facility> _facilities = [];
  
  Region? _selectedRegion;
  Council? _selectedCouncil;
  Facility? _selectedFacility;

  AuthProvider(this._authService) {
    _init();
  }

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  // Location getters
  List<Region> get regions => _regions;
  List<Council> get councils => _councils;
  List<Facility> get facilities => _facilities;
  Region? get selectedRegion => _selectedRegion;
  Council? get selectedCouncil => _selectedCouncil;
  Facility? get selectedFacility => _selectedFacility;

  void _init() {
    _authService.authStateChanges.listen((AuthState state) async {
      if (state.event == AuthChangeEvent.signedIn && state.session?.user != null) {
        try {
          _user = await _authService.getUserData(state.session!.user.id);
        } catch (e) {
          _errorMessage = e.toString();
        }
      } else if (state.event == AuthChangeEvent.signedOut) {
        _user = null;
        _clearLocationSelection();
      }
      _isLoading = false;
      notifyListeners();
    });
    
    // Load initial location data
    _loadRegions();
  }

  // Authentication methods
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithEmailAndPassword(email, password);
      _user = user;
      return user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? facilityId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.createUserWithEmailAndPassword(
        email, 
        password, 
        name, 
        role,
        facilityId: facilityId,
      );
      
      _user = user;
      return user != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _clearLocationSelection();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _clearError();
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? role,
    String? facilityId,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      await _authService.updateUserProfile(
        userId: _user!.id,
        name: name,
        role: role,
        facilityId: facilityId,
      );

      // Reload user data
      _user = await _authService.getUserData(_user!.id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Location management methods
  Future<void> _loadRegions() async {
    try {
      _regions = await _locationService.getAllRegions();
      notifyListeners();
    } catch (e) {
      print('Failed to load regions: $e');
    }
  }

  Future<void> selectRegion(Region region) async {
    _selectedRegion = region;
    _selectedCouncil = null;
    _selectedFacility = null;
    _councils.clear();
    _facilities.clear();
    
    try {
      _councils = await _locationService.getCouncilsByRegion(region.id);
    } catch (e) {
      print('Failed to load councils: $e');
    }
    
    notifyListeners();
  }

  Future<void> selectCouncil(Council council) async {
    _selectedCouncil = council;
    _selectedFacility = null;
    _facilities.clear();
    
    try {
      _facilities = await _locationService.getFacilitiesByCouncil(council.id);
    } catch (e) {
      print('Failed to load facilities: $e');
    }
    
    notifyListeners();
  }

  void selectFacility(Facility facility) {
    _selectedFacility = facility;
    notifyListeners();
  }

  void _clearLocationSelection() {
    _selectedRegion = null;
    _selectedCouncil = null;
    _selectedFacility = null;
    _councils.clear();
    _facilities.clear();
    notifyListeners();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Check if user has required facility assignment
  bool get hasRequiredFacilityAssignment {
    return _user?.facilityId != null;
  }

  // Get user's facility information
  Future<Facility?> getUserFacility() async {
    if (_user?.facilityId == null) return null;
    
    try {
      return await _locationService.getFacilityById(_user!.facilityId!);
    } catch (e) {
      return null;
    }
  }
}