# Woti Attendance - Flutter MVP

A Flutter application for attendance tracking with authentication.

## Features

### ✅ Authentication System
- **Login Screen**: Email/password authentication with validation
- **Registration Screen**: Account creation with full name, email, and password
- **Forgot Password**: Password reset functionality
- **State Management**: Provider pattern for authentication state
- **Auto Navigation**: Automatic routing based on authentication status

### ✅ Dashboard
- **Welcome Screen**: Personalized greeting with user information
- **Quick Actions**: Grid layout with attendance features (placeholder)
- **Logout Functionality**: Secure sign out with confirmation dialog
- **Modern UI**: Material Design 3 with consistent theming

### ✅ Mock Authentication (for Testing)
- **Test Credentials**: 
  - Email: `test@example.com`
  - Password: `test123`
- **Registration**: Create new accounts (mock storage)

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/blessedNishimwe/woti_attendance.git
   cd woti_attendance
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Testing the App

#### Login Testing
1. Launch the app
2. Use the test credentials:
   - Email: `test@example.com`
   - Password: `test123`
3. Click "Sign In"
4. You should be redirected to the dashboard

#### Registration Testing
1. From the login screen, click "Don't have an account? Sign up"
2. Fill in the registration form:
   - Full Name: Your name
   - Email: Any valid email format
   - Password: At least 6 characters
   - Confirm Password: Must match the password
3. Click "Create Account"
4. You should be automatically signed in and redirected to the dashboard

#### Other Features
- **Forgot Password**: Click "Forgot Password?" and enter an email
- **Logout**: From the dashboard, tap the menu (⋮) and select "Logout"
- **Quick Actions**: Tap any card on the dashboard (shows "Coming Soon" dialog)

## Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # App configuration constants
│   └── supabase_config.dart     # Supabase setup (placeholder)
├── core/
│   └── services/
│       └── auth_service.dart    # Authentication service
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart    # Authentication state management
│   │   └── screens/
│   │       ├── login_screen.dart     # Login UI
│   │       └── register_screen.dart  # Registration UI
│   └── dashboard/
│       └── screens/
│           └── dashboard_screen.dart # Main dashboard
├── shared/                      # Shared components and models
└── main.dart                   # App entry point
```

## Dependencies

### Core Dependencies
- `flutter`: Framework
- `provider`: State management
- `supabase_flutter`: Authentication backend (ready for integration)
- `geolocator`: Location services (for attendance tracking)

### Development
- `flutter_test`: Testing framework
- `flutter_lints`: Code analysis

## Current Implementation

This is an MVP (Minimum Viable Product) with mock authentication. Key features:

### Authentication Flow
1. **AuthWrapper**: Manages authentication state and navigation
2. **AuthProvider**: Handles login, registration, and logout
3. **Mock Authentication**: Uses hardcoded credentials for testing
4. **Form Validation**: Client-side validation for all forms
5. **Loading States**: Shows progress indicators during operations
6. **Error Handling**: User-friendly error messages

### UI/UX
- **Material Design 3**: Modern, consistent design
- **Responsive Layout**: Works on different screen sizes
- **Smooth Navigation**: Seamless transitions between screens
- **Dark/Light Theme**: Supports system theme preferences

## Next Steps for Production

1. **Replace Mock Authentication**: 
   - Set up Supabase project
   - Add real credentials to `supabase_config.dart`
   - Replace `MockUser` with real Supabase `User`

2. **Add Attendance Features**:
   - Clock In/Out functionality
   - Location verification
   - Attendance history
   - Schedule management

3. **Enhanced Features**:
   - User profile management
   - Reports and analytics
   - Push notifications
   - Offline support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue on GitHub.
