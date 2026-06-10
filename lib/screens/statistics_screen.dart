import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard(
              context,
              'Overall Summary',
              [
                _buildStatRow('Total Days Worked', '${provider.totalDaysWorked}'),
                _buildStatRow('Weekly Average', _formatDuration(provider.weeklyAverage)),
                _buildStatRow('Total Overtime', _formatDuration(provider.totalOvertime)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              'Records',
              [
                _buildDayStatRow('Best Day', provider.bestDay),
                _buildDayStatRow('Worst Day', provider.worstDay),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDayStatRow(String label, dynamic record) {
    String value = '--';
    if (record != null) {
      final date = DateFormat('MMM d').format(DateTime.parse(record.date));
      value = '$date (${_formatDuration(record.totalHours)})';
    }
    return _buildStatRow(label, value);
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
