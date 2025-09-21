import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/user_model.dart';
import '../../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return await getUserData(response.user!.id);
      }
    } on AuthException catch (e) {
      throw Exception('Authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
    return null;
  }

  Future<UserModel?> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String name, 
    String role,
    {String? facilityId}
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
          'facility_id': facilityId,
        },
      );
      
      if (response.user != null) {
        // Wait a moment for the trigger to complete
        await Future.delayed(const Duration(milliseconds: 500));
        
        // If facilityId was provided, update the profile
        if (facilityId != null) {
          await updateUserProfile(
            userId: response.user!.id, 
            facilityId: facilityId
          );
        }
        
        return await getUserData(response.user!.id);
      }
    } on AuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
    return null;
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('''
            *,
            facilities (
              *,
              councils (
                *,
                regions (*)
              )
            )
          ''')
          .eq('id', uid)
          .single();

      return UserModel.fromMap({
        ...response,
        'id': uid,
      });
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? role,
    String? facilityId,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role;
      if (facilityId != null) updates['facility_id'] = facilityId;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('user_profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> assignUserToFacility(String userId, String facilityId) async {
    try {
      await updateUserProfile(userId: userId, facilityId: facilityId);
    } catch (e) {
      throw Exception('Failed to assign user to facility: $e');
    }
  }

  Future<List<UserModel>> getUsersByFacility(String facilityId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('''
            *,
            facilities (
              *,
              councils (
                *,
                regions (*)
              )
            )
          ''')
          .eq('facility_id', facilityId)
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((item) => UserModel.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by facility: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}

// lib/core/services/attendance_service.dart - UPDATED
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/attendance_model.dart';
import '../../config/supabase_config.dart';

class AttendanceService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<String> checkIn({
    required String userId,
    required double latitude,
    required double longitude,
    String? facilityId,
    String? address,
    String? photoPath,
  }) async {
    try {
      // Check if user is already checked in today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingAttendance = await _supabase
          .from('attendance')
          .select()
          .eq('user_id', userId)
          .gte('check_in_time', startOfDay.toIso8601String())
          .lt('check_in_time', endOfDay.toIso8601String())
          .eq('status', 'checked_in')
          .maybeSingle();

      if (existingAttendance != null) {
        throw Exception('Already checked in today');
      }

      final attendanceData = {
        'user_id': userId,
        'facility_id': facilityId,
        'check_in_time': DateTime.now().toIso8601String(),
        'check_in_latitude': latitude,
        'check_in_longitude': longitude,
        'check_in_address': address,
        'check_in_photo': photoPath,
        'status': 'checked_in',
      };

      final response = await _supabase
          .from('attendance')
          .insert(attendanceData)
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to check in: $e');
    }
  }

  Future<void> checkOut({
    required String attendanceId,
    required double latitude,
    required double longitude,
    String? address,
    String? photoPath,
  }) async {
    try {
      final checkOutTime = DateTime.now();
      
      // Get the attendance record
      final attendance = await _supabase
          .from('attendance')
          .select()
          .eq('id', attendanceId)
          .single();

      final checkInTime = DateTime.parse(attendance['check_in_time']);
      final totalMinutes = checkOutTime.difference(checkInTime).inMinutes;

      await _supabase.from('attendance').update({
        'check_out_time': checkOutTime.toIso8601String(),
        'check_out_latitude': latitude,
        'check_out_longitude': longitude,
        'check_out_address': address,
        'check_out_photo': photoPath,
        'status': 'checked_out',
        'total_hours_minutes': totalMinutes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', attendanceId);
    } catch (e) {
      throw Exception('Failed to check out: $e');
    }
  }

  Future<AttendanceModel?> getTodayAttendance(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('attendance')
          .select('''
            *,
            user_profiles (*),
            facilities (
              *,
              councils (
                *,
                regions (*)
              )
            )
          ''')
          .eq('user_id', userId)
          .gte('check_in_time', startOfDay.toIso8601String())
          .lt('check_in_time', endOfDay.toIso8601String())
          .order('check_in_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return AttendanceModel.fromMap(response);
      }
    } catch (e) {
      print('Failed to get today attendance: $e');
    }
    return null;
  }

  Future<List<AttendanceModel>> getAttendanceHistory(String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('attendance')
          .select('''
            *,
            user_profiles (*),
            facilities (
              *,
              councils (
                *,
                regions (*)
              )
            )
          ''')
          .eq('user_id', userId)
          .order('check_in_time', ascending: false);

      if (startDate != null) {
        query = query.gte('check_in_time', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('check_in_time', endDate.toIso8601String());
      }

      final response = await query.limit(limit);

      return (response as List).map((item) => AttendanceModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to get attendance history: $e');
    }
  }

  // NEW: Get attendance by facility
  Future<List<AttendanceModel>> getFacilityAttendance(String facilityId, {
    DateTime? date,
    int limit = 100,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('attendance')
          .select('''
            *,
            user_profiles (*),
            facilities (
              *,
              councils (
                *,
                regions (*)
              )
            )
          ''')
          .eq('facility_id', facilityId)
          .gte('check_in_time', startOfDay.toIso8601String())
          .lt('check_in_time', endOfDay.toIso8601String())
          .order('check_in_time', ascending: false)
          .limit(limit);

      return (response as List).map((item) => AttendanceModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to get facility attendance: $e');
    }
  }

  Stream<List<AttendanceModel>> getAttendanceStream(String userId) {
    return _supabase
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('check_in_time', ascending: false)
        .limit(10)
        .map((data) => data.map((item) => AttendanceModel.fromMap(item)).toList());
  }
}