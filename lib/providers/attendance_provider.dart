import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance.dart';
import '../services/storage_service.dart';

class AttendanceProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<AttendanceRecord> _records = [];

  // Required daily work hours: 9 hours 15 minutes
  final Duration targetDuration = const Duration(hours: 9, minutes: 15);

  List<AttendanceRecord> get records => _records;

  AttendanceRecord? get todayRecord {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      return _records.firstWhere((record) => record.date == today);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadRecords() async {
    _records = await _storageService.loadRecords();
    notifyListeners();
  }

  Future<void> checkIn() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    if (todayRecord == null) {
      _records.add(AttendanceRecord(date: today, checkIn: now));
    } else {
      // If record exists but checkIn is null (shouldn't happen with current logic)
      final index = _records.indexWhere((r) => r.date == today);
      _records[index] = AttendanceRecord(
        date: today,
        checkIn: now,
        checkOut: _records[index].checkOut,
      );
    }

    await _storageService.saveRecords(_records);
    notifyListeners();
  }

  Future<void> checkOut() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final index = _records.indexWhere((r) => r.date == today);
    if (index != -1) {
      _records[index] = AttendanceRecord(
        date: today,
        checkIn: _records[index].checkIn,
        checkOut: now,
      );
      await _storageService.saveRecords(_records);
      notifyListeners();
    }
  }

  // Calculate remaining time
  Duration get remainingTime {
    final today = todayRecord;
    if (today == null || today.checkIn == null) return targetDuration;

    if (today.checkOut != null) {
      final worked = today.totalHours;
      return worked >= targetDuration ? Duration.zero : targetDuration - worked;
    }

    // Currently checked in
    final workedSoFar = DateTime.now().difference(today.checkIn!);
    return workedSoFar >= targetDuration ? Duration.zero : targetDuration - workedSoFar;
  }

  bool get isTargetAchieved {
    final today = todayRecord;
    if (today == null || today.checkIn == null) return false;
    
    Duration worked;
    if (today.checkOut != null) {
      worked = today.totalHours;
    } else {
      worked = DateTime.now().difference(today.checkIn!);
    }
    return worked >= targetDuration;
  }

  // Calculate expected leave time
  DateTime? get expectedLeaveTime {
    final today = todayRecord;
    if (today == null || today.checkIn == null) return null;
    return today.checkIn!.add(targetDuration);
  }

  // Progress percentage for UI
  double get progress {
    final today = todayRecord;
    if (today == null || today.checkIn == null) return 0.0;

    Duration worked;
    if (today.checkOut != null) {
      worked = today.totalHours;
    } else {
      worked = DateTime.now().difference(today.checkIn!);
    }

    double p = worked.inMinutes / targetDuration.inMinutes;
    return p > 1.0 ? 1.0 : p;
  }
}
