import 'dart:io';

import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/services/api_service.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/view/confrim_booking_page.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/view/widget/enquity_wid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

  final List<String> _attendanceOptions = ['Present', 'Absent', 'Cancelled'];
  final List<String> _durationOptions = [
    "Morning (9AM–12PM)",
    "Afternoon (2PM–5PM)",
    "Full Day",
  ];
  final List<String> _completionOptions = ['Partial'];

  @override
  void initState() {
    super.initState();
    _editedAttendance = widget.attendance.copyWith();

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

    // Update attendance object and remaining when values change
    _sessionController.addListener(() {
      final value =
          int.tryParse(_sessionController.text) ??
          _editedAttendance.sessionNumber;
      setState(() {
        _editedAttendance = _editedAttendance.copyWith(sessionNumber: value);
        _updateRemaining();
      });
    });

    _totalController.addListener(() {
      final value =
          int.tryParse(_totalController.text) ??
          _editedAttendance.totalSessions;
      setState(() {
        _editedAttendance = _editedAttendance.copyWith(totalSessions: value);
        _updateRemaining(); // <--- Update remaining here
      });
    });

    _completedController.addListener(() {
      final value =
          int.tryParse(_completedController.text) ??
          _editedAttendance.sessionsCompleted;
      setState(() {
        _editedAttendance = _editedAttendance.copyWith(
          sessionsCompleted: value,
        );
        _updateRemaining(); // <--- Update remaining here
      });
    });
  }

  void _updateRemaining() {
    final remaining =
        _editedAttendance.totalSessions - _editedAttendance.sessionsCompleted;
    _editedAttendance = _editedAttendance.copyWith(
      sessionsRemaining: remaining,
    );
    _remainingController.text = remaining.toString();
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
                        title: const Text("Select Session Duration"),
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
                controller.selectedDays.clear();
                controller.fetchAttendance();
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
                  () => TableCalendar(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay.value,

                    // ✅ highlight selected days
                    selectedDayPredicate: (day) {
                      return controller.selectedDays.any(
                        (d) => isSameDay(d, day),
                      );
                    },

                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    daysOfWeekVisible: true,

                    // ✅ toggle multiple days
                    onDaySelected: (selectedDay, focusedDay) {
                      // Convert plannedDate strings from API into DateTime list
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
                          builder: (ctx) {
                            return AlertDialog(
                              title: Text("Update Attendance"),
                              content: StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 10),
                                      _buildDropdown(
                                        'Attendance Status',
                                        _editedAttendance.attendanceStatus,
                                        _attendanceOptions,
                                        (value) => setState(() {
                                          _editedAttendance = _editedAttendance
                                              .copyWith(
                                                attendanceStatus: value!,
                                              );

                                          _editedAttendance = _editedAttendance
                                              .copyWith(
                                                sessionDate: selectedDay
                                                    .toIso8601String(),
                                              );
                                        }),
                                      ),
                                      const SizedBox(height: 15),
                                      _buildDropdown(
                                        'Session Duration',
                                        _editedAttendance.sessionDuration,
                                        _durationOptions,
                                        (value) => setState(() {
                                          _editedAttendance = _editedAttendance
                                              .copyWith(
                                                sessionDuration: value!,
                                              );
                                        }),
                                      ),
                                      const SizedBox(height: 15),
                                      _buildDropdown(
                                        'Session Completion',
                                        _editedAttendance.sessionCompletion,
                                        _completionOptions,
                                        (value) => setState(() {
                                          _editedAttendance = _editedAttendance
                                              .copyWith(
                                                sessionCompletion: value!,
                                              );

                                          if (value == "Completed") {
                                            final booking =
                                                widget.attendance.bookingData!;
                                            if (booking.totalFee !=
                                                booking.amountPaid) {
                                              showError(
                                                "Cannot mark the training as completed. Please verify that the full payment has been received and payment proof has been uploaded before completing the session.",
                                              );
                                            }
                                          }
                                        }),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildActionButtons(),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
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
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        printData(widget.attendance.bookingData!.toJson());
                        final plannedDates =
                            widget.attendance.bookingData?.plannedDate
                                .map((d) => DateTime.tryParse(d.date))
                                .where((d) => d != null)
                                .cast<DateTime>()
                                .toList() ??
                            [];

                        printData("plannedDates $plannedDates");
                        printData(
                          "widget.attendance.bookingData?.plannedDate ${widget.attendance.bookingData?.plannedDate}",
                        );

                        final completedDates =
                            widget.attendance.completedDates ?? [];

                        // Find if this day has a completed entry
                        final completedEntry = completedDates.firstWhere(
                          (d) => isSameDay(DateTime.tryParse(d.date), day),
                          orElse: () => CompletedDate(date: "", duration: ""),
                        );

                        final isCompleted = completedEntry.date.isNotEmpty;

                        final isPlanned = plannedDates.any(
                          (d) => isSameDay(d, day),
                        );
                        final isSelected = controller.selectedDays.any(
                          (d) => isSameDay(d, day),
                        );

                        // 🔹 Wrap with GestureDetector for completed dates
                        if (isCompleted) {
                          return GestureDetector(
                            onTap: () {
                              // 🔹 Show dialog with completed duration info
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Completed Session"),
                                    content: Text(
                                      "${day.day}/${day.month}/${day.year}\nDuration: ${completedEntry.duration}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Text("${day.day}")),
                            ),
                          );
                        }

                        if (isPlanned && isSelected) {
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text("${day.day}")),
                          );
                        } else if (isPlanned && !isCompleted) {
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text("${day.day}")),
                          );
                        } else if (isSelected) {
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text("${day.day}")),
                          );
                        }

                        return null;
                      },
                    ),

                    calendarStyle: CalendarStyle(
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
                      _infoText(
                        "Total Fees",
                        widget.attendance.bookingData!.totalFee?.toString() ??
                            "0",
                      ),
                      _infoText(
                        "Total Amount Paid",
                        widget.attendance.bookingData!.amountPaid?.toString() ??
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

      return Dismissible(
        key: Key(attendance.id ?? index.toString()), // unique key
        direction: DismissDirection.endToStart, // swipe from right to left
        background: Container(
          color: AppTheme.enquirySecondary,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          bool confirm = false;
          await Get.defaultDialog(
            title: 'Confirm Delete',
            middleText: 'Are you sure you want to delete this attendance?',
            textCancel: 'No',
            textConfirm: 'Yes',
            buttonColor: AppTheme.enquiryPrimary,
            onConfirm: () {
              confirm = true;
              Get.back();
            },
            onCancel: () {
              confirm = false;
            },
          );
          return confirm;
        },
        onDismissed: (direction) {
          // Remove from the controller's list
          controller.deleteAttendance(attendance.id!);
          Get.snackbar(
            'Deleted',
            'Attendance for ${attendance.riderName} has been deleted.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: buildAttendanceCard(
          attendance,
          context,
          controller,
          selecteddate,
        ),
      );
    },
  );
}

String GetSessionByDate(DateTime date, List<CompletedDate> li) {
  for (var i in li) {
    // Parse string to DateTime
    final parsed = DateTime.tryParse(i.date);
    if (parsed != null) {
      print("Checking planned date: $parsed"); // ✅ debug print

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
  DateTime selectedDate,
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
                showAttendanceSheet(attendance, context, controller);
              },
              child: Card(
                color: attendance.sessionCompletion == "Completed"
                    ? Colors.blue.shade100
                    : AppTheme.textOnPrimary,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Avatar
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
                      const SizedBox(width: 12),

                      // Rider info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              attendance.riderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Phone: ${attendance.phoneNumber}'),
                            Text(
                              'Session: ${attendance.sessionsCompleted}/${attendance.totalSessions}',
                            ),

                            // ✅ Planned session for selected date
                            Text(
                              'Planned: ${GetSessionByDate(selectedDate, attendance.bookingData!.plannedDate)}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Second Card: Action button
          Expanded(
            flex: 1,
            child: Card(
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => LapsScreen(attendance: attendance));
                },
                child: const Center(child: Icon(Icons.watch_later_outlined)),
              ),
            ),
          ),
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
