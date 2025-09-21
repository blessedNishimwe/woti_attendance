class AttendanceModel {
  final String id;
  final String userId;
  final String? facilityId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final double checkInLatitude;
  final double checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final String status; // 'checked_in', 'checked_out'
  final int? totalHoursMinutes; // Changed from Duration to minutes
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user; // Populated when doing joins
  final Facility? facility; // Populated when doing joins

  AttendanceModel({
    required this.id,
    required this.userId,
    this.facilityId,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInLatitude,
    required this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInPhoto,
    this.checkOutPhoto,
    required this.status,
    this.totalHoursMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.facility,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      facilityId: map['facility_id'],
      checkInTime: DateTime.parse(map['check_in_time']),
      checkOutTime: map['check_out_time'] != null 
          ? DateTime.parse(map['check_out_time']) 
          : null,
      checkInLatitude: map['check_in_latitude']?.toDouble() ?? 0.0,
      checkInLongitude: map['check_in_longitude']?.toDouble() ?? 0.0,
      checkOutLatitude: map['check_out_latitude']?.toDouble(),
      checkOutLongitude: map['check_out_longitude']?.toDouble(),
      checkInAddress: map['check_in_address'],
      checkOutAddress: map['check_out_address'],
      checkInPhoto: map['check_in_photo'],
      checkOutPhoto: map['check_out_photo'],
      status: map['status'] ?? 'checked_in',
      totalHoursMinutes: map['total_hours_minutes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['created_at']),
      user: map['user_profiles'] != null ? UserModel.fromMap(map['user_profiles']) : null,
      facility: map['facilities'] != null ? Facility.fromMap(map['facilities']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'facility_id': facilityId,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'check_in_latitude': checkInLatitude,
      'check_in_longitude': checkInLongitude,
      'check_out_latitude': checkOutLatitude,
      'check_out_longitude': checkOutLongitude,
      'check_in_address': checkInAddress,
      'check_out_address': checkOutAddress,
      'check_in_photo': checkInPhoto,
      'check_out_photo': checkOutPhoto,
      'status': status,
      'total_hours_minutes': totalHoursMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Duration get workedHours {
    if (checkOutTime == null) return Duration.zero;
    return checkOutTime!.difference(checkInTime);
  }

  Duration? get totalHours {
    return totalHoursMinutes != null 
        ? Duration(minutes: totalHoursMinutes!) 
        : null;
  }

  String get workLocationName => facility?.fullLocationName ?? 'Unknown location';
}