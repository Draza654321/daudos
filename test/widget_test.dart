// This is a basic Flutter widget test for DaudOS app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daudos/main.dart';

void main() {
  testWidgets('DaudOS app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(DaudOSApp());

    // Verify that the app loads with the splash screen or dashboard
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for any initial animations or loading
    await tester.pumpAndSettle();
    
    // The app should load successfully without errors
    expect(tester.takeException(), isNull);
  });

  testWidgets('Navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(DaudOSApp());
    
    // Wait for the app to load
    await tester.pumpAndSettle();
    
    // Look for bottom navigation or main UI elements
    // This is a basic test to ensure the app structure is working
    expect(find.byType(Scaffold), findsWidgets);
  });
}

