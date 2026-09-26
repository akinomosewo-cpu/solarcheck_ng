import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:solarcheck_ng/data/auth_repository.dart';
import 'package:solarcheck_ng/main.dart';

// The end-to-end signup/login → dashboard navigation flow (which exercises
// real Hive disk I/O through AuthRepository) is covered by
// test/auth_repository_test.dart, which runs under the plain VM test
// runner where real async I/O completes normally. Under the widget test
// binding, Hive's real (non-fake-timer) writes never resolve without
// jumping through a fragile runAsync dance, so this file sticks to
// rendering checks that don't depend on that I/O completing mid-test.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('solarcheck_widget_test');
    Hive.init(tempDir.path);
    await AuthRepository.instance.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    await AuthRepository.instance.clearAllForTesting();
  });

  testWidgets('Splash screen shows brand and routes to login when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarCheckApp());
    await tester.pump();

    expect(find.text('SolarCheck NG'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Sign up screen exposes name, email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarCheckApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.textContaining('Sign up', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Full name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email address'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password (min 4 characters)'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create account'), findsOneWidget);
  });
}
