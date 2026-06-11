import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:office_time_tracker/main.dart';
import 'package:office_time_tracker/providers/attendance_provider.dart';

void main() {
  testWidgets('Home screen loads with required UI elements', (WidgetTester tester) async {
    // We use a fresh provider for testing
    final provider = AttendanceProvider();

    // Wrap MyApp with the provider as it's normally done in main.dart's runApp
    await tester.pumpWidget(
      ChangeNotifierProvider<AttendanceProvider>.value(
        value: provider,
        child: const MyApp(),
      ),
    );

    // Allow animations and providers to settle
    await tester.pumpAndSettle();

    // 1. Verify App Bar Title
    expect(find.text('Office Time Tracker'), findsOneWidget);
    
    // 2. Verify Dashboard Goals
    expect(find.text('Today\'s Goal'), findsOneWidget);
    expect(find.text('9h 15m'), findsWidgets); // One in dashboard, maybe one in status card

    // 3. Verify Action Buttons
    expect(find.text('CHECK IN'), findsOneWidget);
    expect(find.text('CHECK OUT'), findsOneWidget);
    
    // 4. Verify History Icon is present
    expect(find.byIcon(Icons.history), findsOneWidget);
  });
}
