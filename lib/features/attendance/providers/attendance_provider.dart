import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/attendance_service.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService;
  final LocationService _locationService;

  AttendanceProvider(this._attendanceService, this._locationService) {
    _init();
  }

  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentLocation;
  bool _isLocationLoading = false;

  AttendanceModel? get todayAttendance => _todayAttendance;
  List<AttendanceModel> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  bool get isLocationLoading => _isLocationLoading;
  String? get errorMessage => _errorMessage;
  Position? get currentLocation => _currentLocation;
  
  bool get isCheckedIn => _todayAttendance?.status == 'checked_in';
  bool get isCheckedOut => _todayAttendance?.status == 'checked_out';

  void _init() {
    _getCurrentLocation();
  }

  Future<void> loadTodayAttendance(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _todayAttendance = await _attendanceService.getTodayAttendance(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceHistory(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _attendanceHistory = await _attendanceService.getAttendanceHistory(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _isLocationLoading = true;
      notifyListeners();

      _currentLocation = await _locationService.getCurrentLocation();
      _isLocationLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Get address
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Check in
      final attendanceId = await _attendanceService.checkIn(
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      // Refresh today's attendance
      await loadTodayAttendance(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut() async {
    if (_todayAttendance == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Get address
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Check out
      await _attendanceService.checkOut(
        attendanceId: _todayAttendance!.id,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      // Refresh today's attendance
      await loadTodayAttendance(_todayAttendance!.userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Duration get currentSessionDuration {
    if (_todayAttendance?.status != 'checked_in') return Duration.zero;
    return DateTime.now().difference(_todayAttendance!.checkInTime);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
