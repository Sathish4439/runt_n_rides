// attendance_screen.dart
import 'package:RUTSNRIDES/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:RUTSNRIDES/feature/ongoing/controller/attandance_controller.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';
import 'package:RUTSNRIDES/feature/ongoing/widget/ongoing_wid.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final controller = Get.put(AttendanceController());

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    controller.fetchAttendance();
  }

  List<Attendance> filterByDate(DateTime date) {
    final dayKey = DateTime(date.year, date.month, date.day);
    return controller.attendanceList.where((att) {
      final plannedDates = att.bookingData?.plannedDate ?? [];
      return plannedDates.any((p) {
        final parsed = DateTime.tryParse(p.date);
        if (parsed == null) return false;
        final plannedDay = DateTime(parsed.year, parsed.month, parsed.day);
        return plannedDay == dayKey;
      });
    }).toList();
  }

  /// ✅ Collect planned dates for all users
  Map<DateTime, List<String>> groupPlannedDates() {
    final map = <DateTime, List<String>>{};
    for (var att in controller.attendanceList) {
      for (var p in att.bookingData?.plannedDate ?? []) {
        final parsed = DateTime.tryParse(p.date);
        if (parsed != null) {
          final dayKey = DateTime(parsed.year, parsed.month, parsed.day);
          map.putIfAbsent(dayKey, () => []).add(att.riderName ?? "Unknown");
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.attendanceList.isEmpty) {
          return buildEmptyState();
        }

        final plannedEvents = groupPlannedDates();
        final filtered = _selectedDay != null
            ? filterByDate(_selectedDay!)
            : controller.attendanceList;

        return Column(
          children: [
            // ✅ Calendar with green dots
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) =>
                      plannedEvents[DateTime(day.year, day.month, day.day)] ??
                      [],
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Wrap(
                          alignment: WrapAlignment.center,
                          children: events.map((_) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0.5,
                              ),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green, // ✅ Planned date marker
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Selected Date Header
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Planned on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // ✅ Attendance List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("No attendances planned"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final attendance = filtered[index];

                        return Dismissible(
                          key: Key(
                            attendance.id ?? index.toString(),
                          ), // unique key
                          direction: DismissDirection
                              .endToStart, // swipe from right to left
                          background: Container(
                            color: AppTheme.enquirySecondary,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            bool confirm = false;
                            await Get.defaultDialog(
                              title: 'Confirm Delete',
                              middleText:
                                  'Are you sure you want to delete this attendance?',
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
                            _selectedDay ?? DateTime.now(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
