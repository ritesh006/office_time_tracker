import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance.dart';

class StorageService {
  static const String _key = 'attendance_records';

  // Save all records
  Future<void> saveRecords(List<AttendanceRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      records.map((record) => record.toMap()).toList(),
    );
    await prefs.setString(_key, encodedData);
  }

  // Load all records
  Future<List<AttendanceRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);

    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => AttendanceRecord.fromMap(item)).toList();
  }
}
