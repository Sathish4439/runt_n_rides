import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rutsnrides_admin/feature/ongoing/controller/attandance_controller.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';

class AttendanceBottomSheet extends StatefulWidget {
  final Attendance attendance;
  final Function(Attendance) onSave;

  const AttendanceBottomSheet({
    Key? key,
    required this.attendance,
    required this.onSave,
  }) : super(key: key);

  @override
  _AttendanceBottomSheetState createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<AttendanceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late Attendance _editedAttendance;
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _attendanceOptions = ['Present', 'Absent', 'Cancelled'];
  final List<String> _durationOptions = ['Full Day', 'Half Day', 'Quarter Day'];
  final List<String> _completionOptions = [
    'Completed',
    'Partial',
    'Not Started',
  ];

  @override
  void initState() {
    super.initState();
    // Create a copy of the original attendance for editing
    _editedAttendance = Attendance(
      timestamp: widget.attendance.timestamp,
      riderName: widget.attendance.riderName,
      phoneNumber: widget.attendance.phoneNumber,
      programBooked: widget.attendance.programBooked,
      sessionDate: widget.attendance.sessionDate,
      sessionNumber: widget.attendance.sessionNumber,
      totalSessions: widget.attendance.totalSessions,
      attendanceStatus: widget.attendance.attendanceStatus,
      sessionDuration: widget.attendance.sessionDuration,
      sessionCompletion: widget.attendance.sessionCompletion,
      sessionsCompleted: widget.attendance.sessionsCompleted,
      fullDaysDone: widget.attendance.fullDaysDone,
      halfDaysDone: widget.attendance.halfDaysDone,
      sessionsRemaining: widget.attendance.sessionsRemaining,
    );

    // Initialize controllers with existing data
  }

  @override
  Widget build(BuildContext context) {
    final sessionsRemaining =
        _editedAttendance.totalSessions - _editedAttendance.sessionsCompleted;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 20),

              // Rider Info
              _buildRiderInfo(),
              const SizedBox(height: 20),

              // Session Info
              _buildSessionInfo(sessionsRemaining),
              const SizedBox(height: 20),

              // Attendance Status
              _buildDropdown(
                'Attendance Status',
                _editedAttendance.attendanceStatus,
                _attendanceOptions,
                (value) => setState(
                  () => _editedAttendance = _editedAttendance.copyWith(
                    attendanceStatus: value!,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Session Duration
              _buildDropdown(
                'Session Duration',
                _editedAttendance.sessionDuration,
                _durationOptions,
                (value) => setState(
                  () => _editedAttendance = _editedAttendance.copyWith(
                    sessionDuration: value!,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Session Completion
              _buildDropdown(
                'Session Completion',
                _editedAttendance.sessionCompletion,
                _completionOptions,
                (value) => setState(
                  () => _editedAttendance = _editedAttendance.copyWith(
                    sessionCompletion: value!,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Skills Covered

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Attendance Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildRiderInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editedAttendance.riderName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Phone: ${_editedAttendance.phoneNumber}'),
            Text('Program: ${_editedAttendance.programBooked}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(int sessionsRemaining) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          // ← WRAP each box in Expanded
          child: _buildInfoBox(
            'Session',
            _editedAttendance.sessionNumber.toString(),
            editable: true,
            onChanged: (value) {
              if (value.isNotEmpty && int.tryParse(value) != null) {
                setState(() {
                  _editedAttendance = _editedAttendance.copyWith(
                    sessionNumber: int.parse(value),
                  );
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoBox(
            'Total',
            _editedAttendance.totalSessions.toString(),
            editable: true,
            onChanged: (value) {
              if (value.isNotEmpty && int.tryParse(value) != null) {
                setState(() {
                  _editedAttendance = _editedAttendance.copyWith(
                    totalSessions: int.parse(value),
                  );
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoBox(
            'Completed',
            _editedAttendance.sessionsCompleted.toString(),
            editable: true,
            onChanged: (value) {
              if (value.isNotEmpty && int.tryParse(value) != null) {
                setState(() {
                  _editedAttendance = _editedAttendance.copyWith(
                    sessionsCompleted: int.parse(value),
                  );
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoBox(
            'Remaining',
            _editedAttendance.sessionsRemaining.toString(),
            editable: true,
            onChanged: (value) {
              if (value.isNotEmpty && int.tryParse(value) != null) {
                setState(() {
                  _editedAttendance = _editedAttendance.copyWith(
                    sessionsRemaining: int.parse(value),
                  );
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(
    String title,
    String value, {
    ValueChanged<String>? onChanged,
    bool editable = false,
  }) {
    final TextEditingController controller = TextEditingController(text: value);

    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: editable ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: editable ? Border.all(color: Colors.grey.shade300) : null,
          ),
          child: editable
              ? TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                  onTap: () => controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.text.length,
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    // Ensure the value exists in items, otherwise use first item or null
    final validValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: validValue, // Use the validated value
            items: items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'Save Attendance',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _saveAttendance() {
    if (_formKey.currentState!.validate()) {
      // Update timestamp to current time
      final updatedAttendance = _editedAttendance.copyWith(
        timestamp: DateTime.now().toString(),
        skillsCovered: _skillsController.text,
        notes: _notesController.text,
      );

      widget.onSave(updatedAttendance);
      Navigator.pop(context);
    }
  }


}

 Widget buildStatsHeader(BuildContext context, AttendanceController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildStatItem(
              'Total',
              controller.stats['total']?.toString() ?? '0',
              Colors.blue,
            ),
            buildStatItem(
              'Present',
              controller.stats['present']?.toString() ?? '0',
              Colors.green,
            ),
            buildStatItem(
              'Absent',
              controller.stats['absent']?.toString() ?? '0',
              Colors.red,
            ),
            buildStatItem(
              'Rate',
              '${(controller.stats['attendanceRate'] ?? 0).toStringAsFixed(1)}%',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget buildFilterSection(BuildContext context,  AttendanceController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: controller.searchAttendance,
          ),
          const SizedBox(height: 12),

          // Filter Row
         Row(
  children: [
    Expanded(
      child: SizedBox(
        height: 50, // Set a fixed height for both widgets
        child: DropdownButtonFormField<String>(
          value: 'All',
          items: ['All', 'Present', 'Absent', 'Cancelled'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => controller.filterByStatus(value!),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: SizedBox(
        height: 50, // Match the height of the dropdown
        child: TextButton(
          onPressed: () => selectDate(context, controller),
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Obx(
            () => Text(
              'Date: ${formatDate(controller.selectedDate.value)}',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ),
    ),
  ],
),
  ],
      ),
    );
  }

  Widget buildAttendanceList(BuildContext context, AttendanceController controller) {
    return ListView.builder(
      itemCount: controller.filteredList.length,
      itemBuilder: (context, index) {
        final attendance = controller.filteredList[index];
        return buildAttendanceCard(attendance,context, controller);
      },
    );
  }

  Widget buildAttendanceCard(Attendance attendance, BuildContext context, AttendanceController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getStatusColor(attendance.attendanceStatus),
          child: Text(
            attendance.riderName[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          attendance.riderName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${attendance.phoneNumber}'),
            Text(
              'Session: ${attendance.sessionsCompleted}/${attendance.totalSessions}',
            ),
            Text('Date: ${attendance.sessionDate}'),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            showAttendanceSheet(attendance, context, controller);
          },
          child: Icon(Icons.follow_the_signs),
        ),
        onTap: () => showAttendanceDetails(attendance),
      ),
    );
  }

    void showAttendanceSheet(Attendance attendance,BuildContext context, AttendanceController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AttendanceBottomSheet(
        attendance: attendance,
        onSave: (updatedAttendance) {
          // Handle the saved attendance data
          controller.updateAddress(updatedAttendance);
        },
      ),
    );
  }


  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No attendance records found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Unboard Booking to Maintain Address',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> selectDate(BuildContext context, AttendanceController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.filterByDate(picked);
    }
  }

  void showAttendanceDetails(Attendance attendance) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Attendance Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              buildDetailItem('Rider Name', attendance.riderName),
              buildDetailItem('Phone', attendance.phoneNumber),
              buildDetailItem('Program', attendance.programBooked),
              buildDetailItem('Session Date', attendance.sessionDate),
              buildDetailItem(
                'Session',
                '${attendance.sessionNumber}/${attendance.totalSessions}',
              ),
              buildDetailItem('Status', attendance.attendanceStatus),
              buildDetailItem('Duration', attendance.sessionDuration),
              buildDetailItem('Completion', attendance.sessionCompletion),
              buildDetailItem(
                'Sessions Completed',
                attendance.sessionsCompleted.toString(),
              ),
              buildDetailItem('Full Days', attendance.fullDaysDone.toString()),
              buildDetailItem('Half Days', attendance.halfDaysDone.toString()),
              buildDetailItem(
                'Remaining',
                attendance.sessionsRemaining.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void showAddAttendanceSheet() {
    // You can implement the add attendance form here
    Get.snackbar('Info', 'Add attendance functionality coming soon!');
  }


// Extension method for copying Attendance object
extension AttendanceCopyWith on Attendance {
  Attendance copyWith({
    String? timestamp,
    String? riderName,
    String? phoneNumber,
    String? programBooked,
    String? sessionDate,
    int? sessionNumber,
    int? totalSessions,
    String? attendanceStatus,
    String? sessionDuration,
    String? sessionCompletion,
    int? sessionsCompleted,
    int? fullDaysDone,
    int? halfDaysDone,
    int? sessionsRemaining,
    String? skillsCovered,
    String? notes,
  }) {
    return Attendance(
      timestamp: timestamp ?? this.timestamp,
      riderName: riderName ?? this.riderName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      programBooked: programBooked ?? this.programBooked,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      totalSessions: totalSessions ?? this.totalSessions,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      sessionCompletion: sessionCompletion ?? this.sessionCompletion,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      fullDaysDone: fullDaysDone ?? this.fullDaysDone,
      halfDaysDone: halfDaysDone ?? this.halfDaysDone,
      sessionsRemaining: sessionsRemaining ?? this.sessionsRemaining,
    );
  }
}
