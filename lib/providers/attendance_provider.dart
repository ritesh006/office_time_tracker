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
      // If record exists but checkIn is null
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
    if (index != -1 && _records[index].checkOut == null) {
      _records[index] = AttendanceRecord(
        date: today,
        checkIn: _records[index].checkIn,
        checkOut: now,
      );
      await _storageService.saveRecords(_records);
      notifyListeners();
    }
  }

  // Live calculation of current worked time
  Duration get currentWorkedTime {
    final today = todayRecord;
    if (today == null || today.checkIn == null) return Duration.zero;
    if (today.checkOut != null) return today.totalHours;
    return DateTime.now().difference(today.checkIn!);
  }

  // Calculate remaining time using live worked time
  Duration get remainingTime {
    final worked = currentWorkedTime;
    return worked >= targetDuration ? Duration.zero : targetDuration - worked;
  }

  // Calculate overtime using live worked time
  Duration get overtime {
    final worked = currentWorkedTime;
    return worked > targetDuration ? worked - targetDuration : Duration.zero;
  }

  bool get isTargetAchieved => currentWorkedTime >= targetDuration;

  String get leaveStatus {
    final remaining = remainingTime;
    return isTargetAchieved
        ? "✅ You can leave now"
        : "❌ Need ${remaining.inHours}h ${remaining.inMinutes % 60}m more";
  }

  // Calculate weekly average (last 5 working days)
  Duration get weeklyAverage {
    if (_records.isEmpty) return Duration.zero;

    // Ensure records are sorted by date
    final sorted = List<AttendanceRecord>.from(_records)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get last 5 records
    final lastRecords = sorted.length > 5 
        ? sorted.sublist(sorted.length - 5) 
        : sorted;

    int totalMinutes = 0;
    for (var record in lastRecords) {
      Duration worked;
      if (record.checkOut != null) {
        worked = record.totalHours;
      } else if (record.checkIn != null) {
        // Handle active day
        worked = DateTime.now().difference(record.checkIn!);
      } else {
        worked = Duration.zero;
      }
      totalMinutes += worked.inMinutes;
    }

    return Duration(minutes: (totalMinutes / lastRecords.length).round());
  }

  bool get weeklyGoalMet => weeklyAverage >= targetDuration;

  Duration get deficit {
    final avg = weeklyAverage;
    if (avg >= targetDuration) return Duration.zero;
    return targetDuration - avg;
  }

  // Statistics
  int get totalDaysWorked => _records.length;

  Duration get totalOvertime {
    Duration total = Duration.zero;
    for (var record in _records) {
      if (record.checkIn != null && record.checkOut != null) {
        if (record.totalHours > targetDuration) {
          total += record.totalHours - targetDuration;
        }
      }
    }
    return total;
  }

  AttendanceRecord? get bestDay {
    final completed = _records.where((r) => r.checkOut != null).toList();
    if (completed.isEmpty) return null;
    return completed.reduce((a, b) => a.totalHours > b.totalHours ? a : b);
  }

  AttendanceRecord? get worstDay {
    final completed = _records.where((r) => r.checkOut != null).toList();
    if (completed.isEmpty) return null;
    return completed.reduce((a, b) => a.totalHours < b.totalHours ? a : b);
  }

  // Calculate expected leave time
  DateTime? get expectedLeaveTime {
    final today = todayRecord;
    if (today == null || today.checkIn == null) return null;
    return today.checkIn!.add(targetDuration);
  }

  // Progress percentage for UI
  double get progress {
    if (targetDuration.inMinutes == 0) return 0.0;
    double p = currentWorkedTime.inMinutes / targetDuration.inMinutes;
    return p.clamp(0.0, 1.0);
  }
}
