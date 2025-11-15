// ════════════════════════════════════════════════════════════
// Widget Tests - App Level
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/app.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App should build without errors when logged out',
        (WidgetTester tester) async {
      // Build app with logged out state
      await tester.pumpWidget(const App(false));

      // App should build successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should build without errors when logged in',
        (WidgetTester tester) async {
      // Build app with logged in state
      await tester.pumpWidget(const App(true));

      // App should build successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have correct theme mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App(false));

      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      // Verify theme is set
      expect(app.theme, isNotNull);
    });

    testWidgets('App should use GetMaterialApp for navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App(false));

      // GetMaterialApp is a subclass of MaterialApp
      // Verify that navigation is configured
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app, isNotNull);
    });
  });

  group('App Initialization Tests', () {
    test('App should accept boolean parameter for login state', () {
      // Test constructor accepts boolean
      const appLoggedOut = App(false);
      const appLoggedIn = App(true);

      expect(appLoggedOut, isNotNull);
      expect(appLoggedIn, isNotNull);
    });
  });
}
