import 'package:flutter_test/flutter_test.dart';
import 'package:office_time_tracker/providers/attendance_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Required to mock SharedPreferences in tests
    SharedPreferences.setMockInitialValues({});
  });

  group('AttendanceProvider Logic Tests', () {
    test('Initial state: Target duration should be 9h 15m', () {
      final provider = AttendanceProvider();
      expect(
        provider.targetDuration,
        const Duration(hours: 9, minutes: 15),
      );
    });

    test('Initial state: Records list should be empty', () {
      final provider = AttendanceProvider();
      expect(provider.records.isEmpty, true);
    });

    test('Check In should create a today record', () async {
      final provider = AttendanceProvider();
      await provider.checkIn();
      
      expect(provider.records.length, 1);
      expect(provider.todayRecord, isNotNull);
      expect(provider.todayRecord!.checkIn, isNotNull);
      expect(provider.todayRecord!.checkOut, isNull);
    });

    test('Check Out should update the today record', () async {
      final provider = AttendanceProvider();
      await provider.checkIn();
      await provider.checkOut();
      
      expect(provider.todayRecord!.checkOut, isNotNull);
    });

    test('Deficit should be target duration when no hours worked', () {
      final provider = AttendanceProvider();
      expect(provider.deficit, provider.targetDuration);
    });

    test('isTargetAchieved should be false initially', () {
      final provider = AttendanceProvider();
      expect(provider.isTargetAchieved, false);
    });

    test('currentWorkedTime should be zero initially', () {
      final provider = AttendanceProvider();
      expect(provider.currentWorkedTime, Duration.zero);
    });

    test('remainingTime should equal target when not checked in', () {
      final provider = AttendanceProvider();
      expect(
        provider.remainingTime,
        const Duration(hours: 9, minutes: 15),
      );
    });

    test('leave status should require more time initially', () {
      final provider = AttendanceProvider();
      expect(
        provider.leaveStatus.contains('Need'),
        true,
      );
    });
  });
}
