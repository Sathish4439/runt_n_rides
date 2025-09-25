import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/services/api_service.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:RUTSNRIDES/feature/enquiry/view/confrim_booking_page.dart';
import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/core/theme/app_theme.dart';
import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:RUTSNRIDES/feature/ongoing/controller/attandance_controller.dart';
import 'package:RUTSNRIDES/feature/ongoing/laps_screen.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';
import 'package:table_calendar/table_calendar.dart';

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

  late TextEditingController _sessionController;
  late TextEditingController _totalController;
  late TextEditingController _completedController;
  late TextEditingController _remainingController;

  final List<String> _attendanceOptions = [
    'Present',
    'Absent',
    'Cancelled',
    'Pending',
  ];
  final List<String> _durationOptions = [
    "Morning (9AM–12PM)",
    "Afternoon (2PM–5PM)",
    "Full Day",
  ];

  @override
  void initState() {
    super.initState();

    // Clear any existing selected days when entering the screen
    controller.selectedDays.clear();

    // Reset calendar to current month
    controller.focusedDay.value = DateTime.now();

    // Initialize attendance data properly
    _editedAttendance = widget.attendance.copyWith();

    // Initialize controllers with proper data
    _sessionController = TextEditingController(
      text: _editedAttendance.sessionNumber.toString(),
    );
    _totalController = TextEditingController(
      text: _editedAttendance.totalSessions.toString(),
    );
    _completedController = TextEditingController(
      text: _editedAttendance.sessionsCompleted.toString(),
    );
    _remainingController = TextEditingController(
      text: _editedAttendance.sessionsRemaining.toString(),
    );

    // Add listeners for real-time updates
    _sessionController.addListener(_onSessionChanged);
    _totalController.addListener(_onTotalChanged);
    _completedController.addListener(_onCompletedChanged);
  }

  /// Reset form data to initial state
  void _resetForm() {
    if (mounted) {
      setState(() {
        _editedAttendance = widget.attendance.copyWith();
        _sessionController.text = _editedAttendance.sessionNumber.toString();
        _totalController.text = _editedAttendance.totalSessions.toString();
        _completedController.text = _editedAttendance.sessionsCompleted
            .toString();
        _remainingController.text = _editedAttendance.sessionsRemaining
            .toString();
      });
    }
  }

  void _onSessionChanged() {
    final value =
        int.tryParse(_sessionController.text) ??
        _editedAttendance.sessionNumber;
    if (mounted) {
      setState(() {
        _editedAttendance = _editedAttendance.copyWith(sessionNumber: value);
        _updateRemaining();
      });
    }
  }

  void _onTotalChanged() {
    final value =
        int.tryParse(_totalController.text) ?? _editedAttendance.totalSessions;
    if (mounted) {
      setState(() {
        _editedAttendance = _editedAttendance.copyWith(totalSessions: value);
        _updateRemaining();
      });
    }
  }

  void _onCompletedChanged() {
    final value =
        int.tryParse(_completedController.text) ??
        _editedAttendance.sessionsCompleted;
    if (mounted) {
      setState(() {
        _editedAttendance = _editedAttendance.copyWith(
          sessionsCompleted: value,
        );
        _updateRemaining();
      });
    }
  }

  void _updateRemaining() {
    final remaining =
        _editedAttendance.totalSessions - _editedAttendance.sessionsCompleted;
    if (mounted) {
      setState(() {
        _editedAttendance = _editedAttendance.copyWith(
          sessionsRemaining: remaining,
        );
      });
      _remainingController.text = remaining.toString();
    }
  }

  @override
  void dispose() {
    _sessionController.dispose();
    _totalController.dispose();
    _completedController.dispose();
    _remainingController.dispose();
    super.dispose();
  }

  var controller = Get.put(AttendanceController());

  final api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(
        () => Visibility(
          visible: controller.selectedDays.isNotEmpty,
          child: GestureDetector(
            onTap: () async {
              String? selectedDuration;

              // ✅ Show dialog with dropdown
              String? duration = await showDialog<String>(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Select Session Duration"),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Selected Days:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ...controller.selectedDays
                                    .map(
                                      (day) => Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          bottom: 1,
                                        ),
                                        child: Text(
                                          "• ${formatDate(day)}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ],
                        ),
                        content: DropdownButtonFormField<String>(
                          value: selectedDuration,
                          items: const [
                            DropdownMenuItem(
                              value: "Full Day",
                              child: Text("Full Day"),
                            ),
                            DropdownMenuItem(
                              value: "Morning (9AM–12PM)",
                              child: Text("Morning (9AM–12PM)"),
                            ),
                            DropdownMenuItem(
                              value: "Afternoon (2PM–5PM)",
                              child: Text("Afternoon (2PM–5PM)"),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              selectedDuration = val;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Choose Duration",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedDuration != null) {
                                Navigator.pop(context, selectedDuration);
                              }
                            },
                            child: const Text("Confirm"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );

              if (duration == null) return; // user cancelled ❌

              try {
                var bodyJson = {
                  "plannedDate": controller.selectedDays
                      .map(
                        (d) => {
                          "date": d.toIso8601String().split("T")[0],
                          "duration": duration, // ✅ Use chosen duration
                        },
                      )
                      .toList(),
                };

                var res = await api.put(
                  "${EndPoints.booking}/${widget.attendance.bookingId}/${EndPoints.planned_date}",
                  data: bodyJson,
                );

                if (res.data['success']) {
                  showSuccess(res.data['message']);
                } else {
                  showError(res.data['message']);
                }
              } catch (e) {
                printData(e);
              } finally {
                // Clear selections and refresh data
                controller.selectedDays.clear();
                controller.fetchAttendance();

                // Show success message
                if (context.mounted) {
                  showSuccess("Planned dates updated successfully!");
                }
              }
            },

            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.enquiryPrimary,
              ),
              child: Icon(Icons.done, color: Colors.white),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2023, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: controller.focusedDay.value,

                        // ✅ highlight selected days
                        selectedDayPredicate: (day) => controller.selectedDays
                            .any((d) => isSameDay(d, day)),

                        // ✅ reactive calendar format
                        calendarFormat: controller.calendarFormat.value,
                        onFormatChanged: (format) {
                          controller.calendarFormat.value = format;
                        },

                        // ✅ allow user to switch between month, 2 weeks, week
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                          CalendarFormat.twoWeeks: '2 Weeks',
                          CalendarFormat.week: 'Week',
                        },

                        startingDayOfWeek: StartingDayOfWeek.monday,
                        daysOfWeekVisible: true,

                        // ✅ toggle multiple days
                        onDaySelected: (selectedDay, focusedDay) {
                          final plannedDates =
                              widget.attendance.bookingData?.plannedDate
                                  .map((d) => DateTime.parse(d.date))
                                  .toList() ??
                              [];

                          final isPlanned = plannedDates.any(
                            (d) => isSameDay(d, selectedDay),
                          );
                          final isSelected = controller.selectedDays.any(
                            (d) => isSameDay(d, selectedDay),
                          );

                          if (isPlanned) {
                            // ✅ Show dialog if user taps on already planned date
                            setState(() {
                              _editedAttendance = _editedAttendance.copyWith(
                                sessionDate: selectedDay.toIso8601String(),
                              );
                            });

                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Update Attendance"),
                                content: StatefulBuilder(
                                  builder: (context, setState) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("${formatDate(selectedDay)}"),
                                      const SizedBox(height: 10),

                                      _buildDropdown(
                                        'Attendance Status',
                                        _editedAttendance.attendanceStatus,
                                        _attendanceOptions,
                                        (value) {
                                          if (value != null) {
                                            setState(() {
                                              _editedAttendance =
                                                  _editedAttendance.copyWith(
                                                    attendanceStatus: value,
                                                    sessionDate: selectedDay
                                                        .toIso8601String(),
                                                  );
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _buildDropdown(
                                        'Session Duration',
                                        _editedAttendance.sessionDuration,
                                        _durationOptions,
                                        (value) {
                                          if (value != null) {
                                            setState(() {
                                              _editedAttendance =
                                                  _editedAttendance.copyWith(
                                                    sessionDuration: value,
                                                  );
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      _buildActionButtons(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (isSelected) {
                            // Remove from user’s selections
                            controller.selectedDays.removeWhere(
                              (d) => isSameDay(d, selectedDay),
                            );
                          } else {
                            // Add new selection
                            controller.selectedDays.add(selectedDay);
                          }

                          controller.focusedDay.value = focusedDay;
                        },

                        // ✅ custom builders for different states
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final plannedDates =
                                widget.attendance.bookingData?.plannedDate
                                    .map((d) => DateTime.tryParse(d.date))
                                    .where((d) => d != null)
                                    .cast<DateTime>()
                                    .toList() ??
                                [];

                            final completedDates =
                                widget.attendance.completedDates ?? [];

                            final completedEntry = completedDates.firstWhere(
                              (d) => isSameDay(DateTime.tryParse(d.date), day),
                              orElse: () =>
                                  CompletedDate(date: "", duration: ""),
                            );

                            final isCompleted = completedEntry.date.isNotEmpty;
                            final isPlanned = plannedDates.any(
                              (d) => isSameDay(d, day),
                            );
                            final isSelected = controller.selectedDays.any(
                              (d) => isSameDay(d, day),
                            );

                            // 🔹 Completed date (red)
                            if (isCompleted) {
                              return GestureDetector(
                                onTap: () {
                                  _showEditCompletedDateDialog(
                                    context,
                                    day,
                                    completedEntry,
                                    widget.attendance,
                                    controller,
                                  );
                                },
                                child: _buildDayCell(
                                  day.day,
                                  Colors.red.withOpacity(0.5),
                                ),
                              );
                            }

                            // 🔹 Planned + Selected (dark red)
                            if (isPlanned && isSelected) {
                              return _buildDayCell(
                                day.day,
                                Colors.red.withOpacity(0.7),
                              );
                            }

                            // 🔹 Planned only (green)
                            if (isPlanned) {
                              return _buildDayCell(
                                day.day,
                                Colors.green.withOpacity(0.5),
                              );
                            }

                            // 🔹 Selected only (orange)
                            if (isSelected) {
                              return _buildDayCell(day.day, Colors.orange);
                            }

                            return null; // default rendering
                          },
                        ),

                        // ✅ styles
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// Helper for rendering day cells

                // _buildRiderInfo(),
                // const SizedBox(height: 20),
                _buildSessionInfo(),
                const SizedBox(height: 20),

                _infoText("Ride Name", _editedAttendance.riderName),
                _infoText("Phone", _editedAttendance.phoneNumber),
                _infoText(
                  "Program Interested",
                  _editedAttendance.programBooked,
                ),

                _infoText(
                  "Total Number of Full days attened",
                  widget.attendance.fullDaysDone.toString(),
                ),

                _infoText(
                  "Total Number of half days attened",
                  widget.attendance.halfDaysDone.toString(),
                ),

                Divider(),

                if (widget.attendance.bookingData != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.attendance.bookingData != null) ...[
                        _infoText(
                          "Total Fees",
                          widget.attendance.bookingData!.totalFee?.toString() ??
                              "0",
                        ),
                        _infoText(
                          "Total Amount Paid",
                          widget.attendance.bookingData!.totalPaid
                                  ?.toString() ??
                              "0",
                        ),
                        const Divider(),
                        _infoText(
                          "Medical Condition",
                          widget.attendance.bookingData!.medicalCondition
                                  ?.toString() ??
                              "0",
                        ),
                        _infoText(
                          "program details",
                          widget.attendance.bookingData!.programDetails
                                  ?.toString() ??
                              "0",
                        ),
                        const Divider(),
                        _infoText(
                          "Head Size",
                          "${widget.attendance.bookingData!.headSize ?? "-"} CM",
                        ),
                        _infoText(
                          "Pant Size",
                          "${widget.attendance.bookingData!.pantSize ?? "-"} CM",
                        ),
                        _infoText(
                          "Height",
                          "${widget.attendance.bookingData!.height ?? "-"} CM",
                        ),
                        _infoText(
                          "Weight",
                          "${widget.attendance.bookingData!.weight ?? "-"} KG",
                        ),
                        _infoText(
                          "Shirt Size",
                          widget.attendance.bookingData!.shirtSize ?? "-",
                        ),
                        _infoText(
                          "Remaining Amount",
                          _calculateRemainingAmount(
                            widget.attendance.bookingData!,
                          ),
                        ),
                      ] else ...[
                        _infoText("Booking Data", "Not available"),
                      ],
                    ],
                  ),
                const SizedBox(height: 10),

                Center(
                  child: SizedBox(
                    width: Get.width * 0.40,
                    child: CommonButton(
                      text: "Complete",
                      onTap: () async {
                        // final pickedFile = await ImagePicker().pickImage(
                        //   source: ImageSource.gallery,
                        // );
                        // if (pickedFile != null) {
                        //   File file = File(pickedFile.path);
                        //   await controller.pickAndUploadPaymentProof(
                        //     file,
                        //     widget.attendance.bookingData!.id!,
                        //   );
                        // }

                        Get.to(
                          () => ConfirmBookingPage(
                            from: "attendance",
                            bookingData: widget.attendance.bookingData,
                            attendance: widget.attendance,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     SizedBox(
                //       height: 50,
                //       width: Get.width * 0.50,
                //       child: ListView.separated(
                //         scrollDirection: Axis.horizontal,
                //         shrinkWrap: true,
                //         itemBuilder: (context, index) {
                //           final filename = widget
                //               .attendance
                //               .bookingData
                //               ?.paymentProof?[index];
                //           if (filename == null) return const SizedBox.shrink();

                //           return GestureDetector(
                //             onTap: () {
                //               Navigator.push(
                //                 context,
                //                 MaterialPageRoute(
                //                   builder: (_) => FullScreenImagePage(
                //                     imageUrl: "${EndPoints.fetch}/$filename",
                //                   ),
                //                 ),
                //               );
                //             },
                //             child: Image.network(
                //               "${EndPoints.fetch}/$filename",
                //               fit: BoxFit.cover,
                //             ),
                //           );
                //         },
                //         separatorBuilder: (context, index) =>
                //             const SizedBox(width: 5),
                //         itemCount:
                //             widget
                //                 .attendance
                //                 .bookingData
                //                 ?.paymentProof
                //                 ?.length ??
                //             0,
                //       ),
                //     ),

                //
                //   ],
                // ),
              ],
            ),
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

  Widget _buildDayCell(int day, Color color) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),

        shape: BoxShape.rectangle,
      ),
      child: Center(child: Text("$day")),
    );
  }

  Widget _buildSessionInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // _buildInfoBox('Session', controller: _sessionController),
        _buildInfoBox('Total', controller: _totalController),
        SizedBox(width: 10),
        _buildInfoBox('Completed', controller: _completedController),
        SizedBox(width: 10),
        _buildInfoBox(
          'Remaining',
          controller: _remainingController,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildInfoBox(
    String title, {
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: readOnly ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: !readOnly
                  ? Border.all(color: Colors.grey.shade300)
                  : null,
            ),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String info, String value) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${info} : ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
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
            value: validValue,
            items: items
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
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
      widget.onSave(_editedAttendance);
      Navigator.pop(context);
    }
  }

  /// Calculate remaining amount from booking data
  String _calculateRemainingAmount(Booking bookingData) {
    try {
      final totalFee = bookingData.totalFee ?? 0;
      final totalPaid = bookingData.totalPaid ?? 0;
      final remaining = totalFee - totalPaid;

      if (remaining <= 0) {
        return "₹0 (Fully Paid)";
      } else {
        return "₹$remaining";
      }
    } catch (e) {
      return "N/A";
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

Widget buildFilterSection(
  BuildContext context,
  AttendanceController controller,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by name or phone...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          onChanged: controller.searchAttendance,
        ),
        const SizedBox(height: 12),

        // Filter Row
        Row(
          children: [
            // Attendance Status Dropdown

            // Session Completion Dropdown
            Expanded(
              child: SizedBox(
                height: 50,
                child: DropdownButtonFormField<String>(
                  value: 'All',
                  items: ['All', 'Not Started', "Partial", 'Completed'].map((
                    String value,
                  ) {
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Date Picker Button
            Expanded(
              child: SizedBox(
                height: 50,
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

Widget buildAttendanceList(
  BuildContext context,
  AttendanceController controller,
  DateTime selecteddate,
) {
  return ListView.builder(
    itemCount: controller.filteredList.length,
    itemBuilder: (context, index) {
      final attendance = controller.filteredList[index];

      return buildAttendanceCard(attendance, context, controller, selecteddate);
    },
  );
}

String GetSessionByDate(DateTime date, List<CompletedDate> li) {
  for (var i in li) {
    // Parse string to DateTime
    final parsed = DateTime.tryParse(i.date);
    if (parsed != null) {
      // ✅ debug print

      if (parsed.year == date.year &&
          parsed.month == date.month &&
          parsed.day == date.day) {
        return i.duration;
      }
    }
  }
  return "No Session"; // default if not found
}

Widget buildAttendanceCard(
  Attendance attendance,
  BuildContext context,
  AttendanceController controller,
  DateTime? selectedDate, // ✅ nullable now
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ equal height
        children: [
          // First Card: Attendance info
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                // if (attendance.sessionCompletion == "Completed") {
                //   _showEditOptionsPopup(attendance, context, controller);
                // } else {
                showAttendanceSheet(attendance, context, controller);
                // }
              },
              child: Card(
                // color: getStatusBackgroundColor(attendance.attendanceStatus),
                elevation: 2,

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Avatar with status indicator
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: getStatusColor(
                              attendance.attendanceStatus,
                            ),
                            child: Text(
                              attendance.riderName[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Status indicator dot
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                // color: getStatusColor(
                                //   attendance.attendanceStatus,
                                // ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Rider info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attendance.riderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              attendance.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 8,
                                //     vertical: 2,
                                //   ),
                                //   // decoration: BoxDecoration(
                                //   //   color: getStatusColor(
                                //   //     attendance.attendanceStatus,
                                //   //   ),
                                //   //   borderRadius: BorderRadius.circular(12),
                                //   // ),
                                //   child: Text(
                                //     attendance.attendanceStatus,
                                //     style: const TextStyle(
                                //       color: Colors.white,
                                //       fontSize: 12,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(width: 8),
                                Text(
                                  'Session ${attendance.sessionNumber}/${attendance.totalSessions}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                // if (attendance.sessionCompletion ==
                                //     "Completed") ...[
                                //   const SizedBox(width: 8),
                                //   Container(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 6,
                                //       vertical: 2,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: Colors.green,
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //     child: const Text(
                                //       '✓ Completed',
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontSize: 10,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ],
                              ],
                            ),
                            // Add remaining amount if booking data is available
                            // if (attendance.bookingData != null) ...[
                            //   const SizedBox(height: 4),
                            //   Text(
                            //     _calculateRemainingAmountForCard(
                            //       attendance.bookingData!,
                            //     ),
                            //     style: TextStyle(
                            //       color: _getRemainingAmountColor(
                            //         attendance.bookingData!,
                            //       ),
                            //       fontSize: 12,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ],
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Get.to(() => LapsScreen(attendance: attendance));
                        },
                        child: const Center(
                          child: Icon(Icons.watch_later_outlined),
                        ),
                      ),
                      const SizedBox(width: 8),
                        ],
                  ),
                ),
              ),
            ),
          ),

          // Second Card: Action button
        ],
      ),
    ),
  );
}

void showAttendanceSheet(
  Attendance attendance,
  BuildContext context,
  AttendanceController controller,
) {
  Get.to(
    () => AttendanceBottomSheet(
      attendance: attendance,

      onSave: (updatedAttendance) {
        if (updatedAttendance.sessionDate.isNotEmpty &&
            updatedAttendance.totalSessions != 0) {
          controller.updateAddress(updatedAttendance);
        } else {
          showError("select date to put attendance or enter the total session");
        }
      },
    ),
  );
}

/// Show edit dialog for completed date details
void _showEditCompletedDateDialog(
  BuildContext context,
  DateTime day,
  CompletedDate completedEntry,
  Attendance attendance,
  AttendanceController controller,
) {
  showDialog(
    context: context,
    builder: (context) => EditCompletedDateDialog(
      day: day,
      completedEntry: completedEntry,
      attendance: attendance,
      onSave: (updatedEntry) {
        controller.updateCompletedDate(attendance, day, updatedEntry);
      },
    ),
  );
}

/// Show edit options popup for completed sessions

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
    case 'Pending':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Color getStatusBackgroundColor(String status) {
  switch (status) {
    case 'Present':
      return Colors.green.withOpacity(0.1);
    case 'Absent':
      return Colors.red.withOpacity(0.1);
    case 'Cancelled':
      return Colors.orange.withOpacity(0.1);
    case 'Pending':
      return Colors.blue.withOpacity(0.1);
    default:
      return Colors.grey.withOpacity(0.1);
  }
}

Color getStatusBorderColor(String status) {
  switch (status) {
    case 'Present':
      return Colors.green.withOpacity(0.3);
    case 'Absent':
      return Colors.red.withOpacity(0.3);
    case 'Cancelled':
      return Colors.orange.withOpacity(0.3);
    case 'Pending':
      return Colors.blue.withOpacity(0.3);
    default:
      return Colors.grey.withOpacity(0.3);
  }
}

Widget _buildLegendItem(String status, Color color) {
  return Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(status, style: const TextStyle(fontSize: 12)),
    ],
  );
}

/// Session Details Update Form
class SessionDetailsForm extends StatefulWidget {
  final Attendance attendance;
  final Function(Attendance) onSave;

  const SessionDetailsForm({
    Key? key,
    required this.attendance,
    required this.onSave,
  }) : super(key: key);

  @override
  _SessionDetailsFormState createState() => _SessionDetailsFormState();
}

class _SessionDetailsFormState extends State<SessionDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late Attendance _editedAttendance;

  late TextEditingController _sessionNumberController;
  late TextEditingController _totalSessionsController;
  late TextEditingController _sessionsCompletedController;
  late TextEditingController _fullDaysController;
  late TextEditingController _halfDaysController;

  final List<String> _attendanceOptions = [
    'Present',
    'Absent',
    'Cancelled',
    'Pending',
  ];
  final List<String> _durationOptions = [
    "Morning (9AM–12PM)",
    "Afternoon (2PM–5PM)",
    "Full Day",
  ];
  final List<String> _completionOptions = [
    'Not Started',
    'Partial',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _editedAttendance = widget.attendance;

    _sessionNumberController = TextEditingController(
      text: _editedAttendance.sessionNumber.toString(),
    );
    _totalSessionsController = TextEditingController(
      text: _editedAttendance.totalSessions.toString(),
    );
    _sessionsCompletedController = TextEditingController(
      text: _editedAttendance.sessionsCompleted.toString(),
    );
    _fullDaysController = TextEditingController(
      text: _editedAttendance.fullDaysDone.toString(),
    );
    _halfDaysController = TextEditingController(
      text: _editedAttendance.halfDaysDone.toString(),
    );
  }

  @override
  void dispose() {
    _sessionNumberController.dispose();
    _totalSessionsController.dispose();
    _sessionsCompletedController.dispose();
    _fullDaysController.dispose();
    _halfDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var expanded = Expanded(
      child: _buildDropdown(
        'Completion',
        _editedAttendance.sessionCompletion,
        _completionOptions,
        (value) {
          if (value != null) {
            setState(() {
              _editedAttendance = _editedAttendance.copyWith(
                sessionCompletion: value,
              );
            });
          }
        },
      ),
    );
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Update Session Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Session Information
              _buildSectionTitle('Session Information'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Session Number',
                      _sessionNumberController,
                      (value) {
                        _editedAttendance = _editedAttendance.copyWith(
                          sessionNumber: int.tryParse(value) ?? 0,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      'Total Sessions',
                      _totalSessionsController,
                      (value) {
                        _editedAttendance = _editedAttendance.copyWith(
                          totalSessions: int.tryParse(value) ?? 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Attendance Status
              _buildSectionTitle('Attendance Status'),
              const SizedBox(height: 10),
              _buildDropdown(
                'Status',
                _editedAttendance.attendanceStatus,
                _attendanceOptions,
                (value) {
                  if (value != null) {
                    setState(() {
                      _editedAttendance = _editedAttendance.copyWith(
                        attendanceStatus: value,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 15),

              // Session Details
              _buildSectionTitle('Session Details'),
              const SizedBox(height: 10),

              Column(
                children: [
                  _buildDropdown(
                    'Duration',
                    _editedAttendance.sessionDuration,
                    _durationOptions,
                    (value) {
                      if (value != null) {
                        setState(() {
                          _editedAttendance = _editedAttendance.copyWith(
                            sessionDuration: value,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  expanded,
                ],
              ),
              const SizedBox(height: 15),

              // Progress Tracking
              _buildSectionTitle('Progress Tracking'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Sessions Completed',
                      _sessionsCompletedController,
                      (value) {
                        _editedAttendance = _editedAttendance.copyWith(
                          sessionsCompleted: int.tryParse(value) ?? 0,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      'Sessions Remaining',
                      TextEditingController(
                        text:
                            (_editedAttendance.totalSessions -
                                    _editedAttendance.sessionsCompleted)
                                .toString(),
                      ),
                      null, // Read-only
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Full Days Done',
                      _fullDaysController,
                      (value) {
                        _editedAttendance = _editedAttendance.copyWith(
                          fullDaysDone: int.tryParse(value) ?? 0,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      'Half Days Done',
                      _halfDaysController,
                      (value) {
                        _editedAttendance = _editedAttendance.copyWith(
                          halfDaysDone: int.tryParse(value) ?? 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Action Buttons
              Row(
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
                      onPressed: _saveSessionDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Function(String)? onChanged,
  ) {
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
          enabled: onChanged != null,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: onChanged,
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
            value: validValue,
            items: items
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
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

  void _saveSessionDetails() {
    if (_formKey.currentState!.validate()) {
      // Calculate sessions remaining
      final sessionsRemaining =
          _editedAttendance.totalSessions - _editedAttendance.sessionsCompleted;
      _editedAttendance = _editedAttendance.copyWith(
        sessionsRemaining: sessionsRemaining,
      );

      widget.onSave(_editedAttendance);
      Navigator.pop(context);
    }
  }
}

/// Dialog for editing completed date details
class EditCompletedDateDialog extends StatefulWidget {
  final DateTime day;
  final CompletedDate completedEntry;
  final Attendance attendance;
  final Function(CompletedDate) onSave;

  const EditCompletedDateDialog({
    Key? key,
    required this.day,
    required this.completedEntry,
    required this.attendance,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditCompletedDateDialogState createState() =>
      _EditCompletedDateDialogState();
}

class _EditCompletedDateDialogState extends State<EditCompletedDateDialog> {
  final _formKey = GlobalKey<FormState>();
  late CompletedDate _editedEntry;
  var controller = Get.find<AttendanceController>();
  final List<String> _durationOptions = [
    "Morning (9AM–12PM)",
    "Afternoon (2PM–5PM)",
    "Full Day",
  ];
  final List<String> _statusOptions = [
    'Present',
    'Absent',
    'Cancelled',
    'Pending',
  ];

  @override
  void initState() {
    super.initState();
    _editedEntry = widget.completedEntry;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Completed Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.day.day}/${widget.day.month}/${widget.day.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.enableEdit.value = false;
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Session Details'),

                  CommonButton(
                    text: "Edit",
                    onTap: () {
                      controller.enableEdit.value =
                          !controller.enableEdit.value;
                    },
                  ),
                ],
              ),

              // Session Details
              Obx(
                () => Visibility(
                  visible: !controller.enableEdit.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_editedEntry.duration}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${_editedEntry.status}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: controller.enableEdit.value,
                  child: Column(
                    children: [
                      _buildDropdown(
                        'Duration',
                        _editedEntry.duration,
                        _durationOptions,
                        (value) {
                          if (value != null) {
                            setState(() {
                              _editedEntry = CompletedDate(
                                date: _editedEntry.date,
                                duration: value,
                                status: _editedEntry.status,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildDropdown(
                        'Status',
                        _editedEntry.status ?? 'Pending',
                        _statusOptions,
                        (value) {
                          if (value != null) {
                            setState(() {
                              _editedEntry = CompletedDate(
                                date: _editedEntry.date,
                                duration: _editedEntry.duration,
                                status: value,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                               onPressed: () {
                      Navigator.pop(context);
                      controller.enableEdit.value = false;
                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
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
            value: validValue,
            items: items
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_editedEntry);
      Navigator.pop(context);
      controller.enableEdit.value = false;
    }
  }
}

String formatDate(DateTime date) {
  printData(date);
  try {
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    print("Error formatting date: $e");
    return '';
  }
}

Future<void> selectDate(
  BuildContext context,
  AttendanceController controller,
) async {
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
    String? id,
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
    String? updatedAt,
    String? createdAt,
    String? bookingId,
    List<CompletedDate>? completedDates,
  }) {
    return Attendance(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}

/// Calculate remaining amount for attendance card display
String _calculateRemainingAmountForCard(Booking bookingData) {
  try {
    final totalFee = bookingData.totalFee ?? 0;
    final totalPaid = bookingData.totalPaid ?? 0;
    final remaining = totalFee - totalPaid;

    if (remaining <= 0) {
      return "Fully Paid";
    } else {
      return "Remaining: ₹$remaining";
    }
  } catch (e) {
    return "Payment: N/A";
  }
}

/// Get color for remaining amount display
Color _getRemainingAmountColor(Booking bookingData) {
  try {
    final totalFee = bookingData.totalFee ?? 0;
    final totalPaid = bookingData.totalPaid ?? 0;
    final remaining = totalFee - totalPaid;

    if (remaining <= 0) {
      return Colors.green; // Fully paid - green
    } else {
      return Colors.orange; // Amount remaining - orange
    }
  } catch (e) {
    return Colors.grey; // Error - grey
  }
}
