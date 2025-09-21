class Region {
  final String id;
  final String name;
  final DateTime createdAt;

  Region({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Council {
  final String id;
  final String regionId;
  final String name;
  final DateTime createdAt;
  final Region? region; // Populated when doing joins

  Council({
    required this.id,
    required this.regionId,
    required this.name,
    required this.createdAt,
    this.region,
  });

  factory Council.fromMap(Map<String, dynamic> map) {
    return Council(
      id: map['id'] ?? '',
      regionId: map['region_id'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      region: map['regions'] != null ? Region.fromMap(map['regions']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'region_id': regionId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Facility {
  final String id;
  final String councilId;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final bool isActive;
  final DateTime createdAt;
  final Council? council; // Populated when doing joins

  Facility({
    required this.id,
    required this.councilId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.createdAt,
    this.council,
  });

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['id'] ?? '',
      councilId: map['council_id'] ?? '',
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      radiusMeters: map['radius_meters'] ?? 100,
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      council: map['councils'] != null ? Council.fromMap(map['councils']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'council_id': councilId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullLocationName {
    if (council?.region != null) {
      return '${council!.region!.name} → ${council!.name} → $name';
    } else if (council != null) {
      return '${council!.name} → $name';
    }
    return name;
  }
}

// lib/shared/models/user_model.dart - UPDATED
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? facilityId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Facility? facility; // Populated when doing joins

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.facilityId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.facility,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'worker',
      facilityId: map['facility_id'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['created_at']),
      facility: map['facilities'] != null ? Facility.fromMap(map['facilities']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'facility_id': facilityId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasAssignedFacility => facilityId != null;
  String get workLocationName => facility?.fullLocationName ?? 'No facility assigned';
}