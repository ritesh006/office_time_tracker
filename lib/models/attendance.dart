import 'dart:convert';

class AttendanceRecord {
  final String date;
  final DateTime? checkIn;
  final DateTime? checkOut;

  AttendanceRecord({
    required this.date,
    this.checkIn,
    this.checkOut,
  });

  // Calculate total worked duration
  Duration get totalHours {
    if (checkIn != null && checkOut != null) {
      return checkOut!.difference(checkIn!);
    } else if (checkIn != null && checkOut == null) {
      // If checked in but not out, calculate until now
      return DateTime.now().difference(checkIn!);
    }
    return Duration.zero;
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
    };
  }

  // Create from Map
  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      date: map['date'],
      checkIn: map['checkIn'] != null ? DateTime.parse(map['checkIn']) : null,
      checkOut: map['checkOut'] != null ? DateTime.parse(map['checkOut']) : null,
    );
  }

  // JSON helpers
  String toJson() => json.encode(toMap());
  factory AttendanceRecord.fromJson(String source) => AttendanceRecord.fromMap(json.decode(source));
}
