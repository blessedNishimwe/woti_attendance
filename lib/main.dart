import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'config/supabase_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/location_service.dart';
import 'core/services/attendance_service.dart';
import 'core/services/storage_service.dart';
import 'config/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/attendance/providers/attendance_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart'; // Add this if you have a signup screen
import 'features/dashboard/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase connection
  await Supabase.initialize(
    url: 'https://kwojruueubkfjnfhrlij.supabase.co',
    anonKey: 'sb_publishable_IgqHETZeLI5p0123ZFpnDw_DXFlvzZt',
  );
  runApp(const WotiAttendanceApp());
}

/// Root widget for the Woti Attendance project.
class WotiAttendanceApp extends StatelessWidget {
  const WotiAttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<AttendanceService>(create: (_) => AttendanceService()),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (context) => AttendanceProvider(
            context.read<AttendanceService>(),
            context.read<LocationService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(), // Add this route if you have SignupScreen
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}

/// Decides whether to show Login, Signup, or Dashboard depending on auth state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.user != null) {
          return const DashboardScreen();
        }

        // You can further customize this to allow for switching between login/signup screens.
        return const LoginScreen();
      },
    );
  }
}