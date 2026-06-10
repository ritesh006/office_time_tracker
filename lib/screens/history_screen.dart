import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final history = provider.records.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No records found.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                return _buildHistoryCard(context, record);
              },
            ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AttendanceRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(record.date)),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('In: ${_formatTime(record.checkIn)}'),
                Text('Out: ${_formatTime(record.checkOut)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${_formatDuration(record.totalHours)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('hh:mm a').format(time);
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
