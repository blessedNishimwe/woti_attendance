import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/location_models.dart';
import '../../config/supabase_config.dart';

// Simple LocationService for basic location operations
class LocationService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<Facility>> getAllFacilities() async {
    try {
      final response = await _supabase
          .from('facilities')
          .select('''
            *,
            councils (
              *,
              regions (*)
            )
          ''')
          .order('name');

      return (response as List)
          .map((item) => Facility.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get facilities: $e');
    }
  }

  Future<Facility?> getFacilityById(String facilityId) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select('''
            *,
            councils (
              *,
              regions (*)
            )
          ''')
          .eq('id', facilityId)
          .maybeSingle();

      return response != null ? Facility.fromMap(response) : null;
    } catch (e) {
      throw Exception('Failed to get facility: $e');
    }
  }

  Future<bool> isWithinFacilityRadius({
    required String facilityId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final facility = await getFacilityById(facilityId);
      if (facility == null) return false;

      // Calculate distance using Haversine formula (simplified)
      final distance = _calculateDistance(
        latitude,
        longitude,
        facility.latitude,
        facility.longitude,
      );

      return distance <= facility.radiusMeters;
    } catch (e) {
      return false;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation in meters
    // In production, use a proper geolocation library
    const double earthRadius = 6371000; // Earth radius in meters
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLon = (lon2 - lon1) * (pi / 180);
    
    final double a = (dLat / 2) * (dLat / 2) +
        (dLon / 2) * (dLon / 2) * cos(lat1 * pi / 180) * cos(lat2 * pi / 180);
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
}

class LocationHierarchyService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ============ REGIONS ============
  Future<List<Region>> getAllRegions() async {
    try {
      final response = await _supabase
          .from('regions')
          .select()
          .order('name');

      return (response as List)
          .map((item) => Region.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get regions: $e');
    }
  }

  Future<Region> createRegion(String name) async {
    try {
      final response = await _supabase
          .from('regions')
          .insert({'name': name})
          .select()
          .single();

      return Region.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create region: $e');
    }
  }

  // ============ COUNCILS ============
  Future<List<Council>> getCouncilsByRegion(String regionId) async {
    try {
      final response = await _supabase
          .from('councils')
          .select('''
            *,
            regions (*)
          ''')
          .eq('region_id', regionId)
          .order('name');

      return (response as List)
          .map((item) => Council.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get councils: $e');
    }
  }

  Future<List<Council>> getAllCouncils() async {
    try {
      final response = await _supabase
          .from('councils')
          .select('''
            *,
            regions (*)
          ''')
          .order('name');

      return (response as List)
          .map((item) => Council.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all councils: $e');
    }
  }

  Future<Council> createCouncil({
    required String regionId,
    required String name,
  }) async {
    try {
      final response = await _supabase
          .from('councils')
          .insert({
            'region_id': regionId,
            'name': name,
          })
          .select('''
            *,
            regions (*)
          ''')
          .single();

      return Council.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create council: $e');
    }
  }

  // ============ FACILITIES ============
  Future<List<Facility>> getFacilitiesByCouncil(String councilId) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select('''
            *,
            councils (
              *,
              regions (*)
            )
          ''')
          .eq('council_id', councilId)
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((item) => Facility.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get facilities: $e');
    }
  }

  Future<List<Facility>> getAllActiveFacilities() async {
    try {
      final response = await _supabase
          .from('facilities')
          .select('''
            *,
            councils (
              *,
              regions (*)
            )
          ''')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((item) => Facility.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all facilities: $e');
    }
  }

  Future<Facility?> getFacilityById(String facilityId) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select('''
            *,
            councils (
              *,
              regions (*)
            )
          ''')
          .eq('id', facilityId)
          .single();

      return Facility.fromMap(response);
    } catch (e) {
      print('Failed to get facility by ID: $e');
      return null;
    }
  }

  Future<Facility> createFacility({
    required String councilId,
    required String name,
    required double latitude,
    required double longitude,
    int radiusMeters = 100,
  }) async {
    try {
      final response = await _supabase
          .from('facilities')
          .insert({
            'council_id': councilId,
            'name': name,
            'latitude': latitude,
            'longitude': longitude,
            'radius_meters': radiusMeters,
          })
          .select('''
            *,
            councils (
              *,
              regions (*)
            )
          ''')
          .single();

      return Facility.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create facility: $e');
    }
  }

  Future<void> updateFacility({
    required String facilityId,
    String? name,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (radiusMeters != null) updates['radius_meters'] = radiusMeters;
      if (isActive != null) updates['is_active'] = isActive;

      await _supabase
          .from('facilities')
          .update(updates)
          .eq('id', facilityId);
    } catch (e) {
      throw Exception('Failed to update facility: $e');
    }
  }

  // ============ UTILITY METHODS ============
  Future<List<Facility>> searchFacilities(String searchTerm) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select('''
            *,
            councils (
              *,
              regions (*)
            )
          ''')
          .ilike('name', '%$searchTerm%')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((item) => Facility.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search facilities: $e');
    }
  }
}