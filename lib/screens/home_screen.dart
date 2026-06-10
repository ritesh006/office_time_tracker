import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh UI every minute to update worked hours/remaining time/current time
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Time Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentTimeCard(),
            const SizedBox(height: 16),
            _buildStatusCard(provider),
            const SizedBox(height: 16),
            _buildLeaveStatusCard(provider),
            const SizedBox(height: 16),
            _buildDashboard(provider),
            const SizedBox(height: 24),
            _buildActionButtons(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            const Text('Current Time', style: TextStyle(fontSize: 14)),
            Text(
              DateFormat('hh:mm A').format(DateTime.now()),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AttendanceProvider provider) {
    final today = provider.todayRecord;
    final isCheckedIn = today != null && today.checkOut == null;
    final progress = provider.progress;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${isCheckedIn ? "Checked In" : "Checked Out"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildStatusRow('Today\'s Goal', '9h 15m'),
            _buildStatusRow('Remaining', _formatDuration(provider.remainingTime)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}% of daily goal',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLeaveStatusCard(AttendanceProvider provider) {
    final isAchieved = provider.isTargetAchieved;
    final today = provider.todayRecord;

    if (today == null) return const SizedBox.shrink();

    return Card(
      color: isAchieved ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isAchieved ? Icons.check_circle : Icons.cancel,
              color: isAchieved ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAchieved ? 'Daily target achieved!' : 'Need ${_formatDuration(provider.remainingTime)} more',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAchieved ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                  Text(
                    isAchieved ? 'You can leave now.' : 'Can I Leave Now?',
                    style: TextStyle(color: isAchieved ? Colors.green.shade700 : Colors.red.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(AttendanceProvider provider) {
    final today = provider.todayRecord;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildInfoTile('Check In', _formatTime(today?.checkIn), Icons.login),
        _buildInfoTile('Leave Time', _formatTime(provider.expectedLeaveTime), Icons.event_available),
        _buildInfoTile('Worked', _formatDuration(today?.totalHours ?? Duration.zero), Icons.timer),
        _buildInfoTile('Check Out', _formatTime(today?.checkOut), Icons.logout),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.blueGrey),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AttendanceProvider provider) {
    final today = provider.todayRecord;
    final canCheckIn = today == null;
    final canCheckOut = today != null && today.checkOut == null;

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: canCheckIn ? () => provider.checkIn() : null,
          icon: const Icon(Icons.login),
          label: const Text('CHECK IN', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: canCheckOut ? () => provider.checkOut() : null,
          icon: const Icon(Icons.logout),
          label: const Text('CHECK OUT', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return Colors.red;
    if (progress < 0.9) return Colors.orange;
    return Colors.green;
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
