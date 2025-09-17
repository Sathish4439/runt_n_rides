import 'package:RUTSNRIDES/feature/ongoing/widget/ongoing_wid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';

class AttendanceDetailSheet extends StatelessWidget {
  final Attendance attendance;

  const AttendanceDetailSheet({Key? key, required this.attendance})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Attendance Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildDetailRow('Rider Name', attendance.riderName),
          _buildDetailRow('Phone Number', attendance.phoneNumber),
          _buildDetailRow('Program', attendance.programBooked),
          _buildDetailRow('Session Date', attendance.sessionDate),
          _buildDetailRow(
            'Session Number',
            '${attendance.sessionsCompleted}/${attendance.totalSessions}',
          ),
          _buildDetailRow('Status', attendance.sessionCompletion),
          _buildDetailRow(
            'Completion',
            '${attendance.sessionsCompleted} sessions completed',
          ),

          if (attendance.completedDates.isNotEmpty) ...[
            // SizedBox(height: 16),
            Text(
              'Completed Dates:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...attendance.completedDates
                .map(
                  (date) => ListTile(
                    title: Text(formatDate(DateTime.parse(date.date))),
                    subtitle: Text('Duration: ${date.duration}'),
                  ),
                )
                .toList(),
          ],

          SizedBox(height: 20),
          //   _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus('Present'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Mark Present', style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus('Absent'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Mark Absent', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void _updateStatus(String status) {
    // This would be handled by the controller
    Get.back();
    Get.snackbar('Status Updated', 'Marked as $status');
  }
}
