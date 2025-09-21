// This is a basic Flutter widget test for the authentication MVP.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:woti_attendance/main.dart';
import 'package:woti_attendance/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('App loads and shows login screen when not authenticated', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is displayed
    expect(find.text('Woti Attendance'), findsOneWidget);
    expect(find.text('Sign in to track your attendance'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Try to submit empty form
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Should show validation errors
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Navigation to register screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap the register link
    await tester.tap(find.text("Don't have an account? Sign up"));
    await tester.pumpAndSettle();

    // Should navigate to register screen
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join Woti Attendance'), findsOneWidget);
  });

  testWidgets('Mock authentication works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Enter mock credentials
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'test123');

    // Tap sign in button
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Should show loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for authentication to complete
    await tester.pumpAndSettle();

    // Should navigate to dashboard
    expect(find.text('Welcome, Test User!'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
