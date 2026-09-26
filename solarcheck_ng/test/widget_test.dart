import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solarcheck_ng/main.dart';

void main() {
  testWidgets('App launches and shows the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarCheckApp());
    await tester.pumpAndSettle();

    expect(find.text('SolarCheck NG'), findsOneWidget);
    expect(find.text('What you can do'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Bottom navigation switches to the sizing tab', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarCheckApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Size'));
    await tester.pumpAndSettle();

    expect(find.text('Solar Sizing'), findsOneWidget);
  });
}
