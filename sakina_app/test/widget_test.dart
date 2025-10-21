// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:sakina_app/main.dart';
import 'package:sakina_app/services/storage_service.dart';

void main() {
  testWidgets('Sakina app smoke test', (WidgetTester tester) async {
    // Initialize test storage
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final storageService = StorageService(prefs, secureStorage);

    // Build our app and trigger a frame.
    await tester.pumpWidget(SakinaApp(storageService: storageService));

    // Wait for the splash screen to load
    await tester.pumpAndSettle();

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
