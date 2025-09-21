import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'woti_attendance';
  static const String version = '1.0.0';
  
  // GPS Configuration
  static const double locationAccuracyThreshold = 50.0; // meters
  static const int locationTimeoutSeconds = 30;
  
  // Work Site Configuration
  static const double workSiteRadius = 100.0; // meters
  
  // Timesheet Configuration
  static const int timesheetGenerationDay = 7; // Sunday
  
  // Storage
  static const String profileImagesBucket = 'profile-images';
  static const String attendancePhotosBucket = 'attendance-photos';
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF2196F3),
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF2196F3),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}