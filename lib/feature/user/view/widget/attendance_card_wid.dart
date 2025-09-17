import 'package:RUTSNRIDES/feature/ongoing/widget/ongoing_wid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';

class AttendanceCard extends StatelessWidget {
  final Attendance attendance;
  final VoidCallback onTap;

  const AttendanceCard({
    Key? key,
    required this.attendance,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            attendance.riderName[0],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          attendance.riderName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${attendance.phoneNumber}'),
            Text('Program: ${attendance.programBooked}'),
            Text(
              'Session: ${formatDate(DateTime.parse(attendance.sessionDate))}',
            ),
          ],
        ),
        trailing: _buildStatusIndicator(attendance.sessionCompletion),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'present':
        color = Colors.green;
        break;
      case 'absent':
        color = Colors.red;
        break;
      case 'late':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
