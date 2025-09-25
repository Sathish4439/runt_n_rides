// attendance_screen.dart
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
  CalendarFormat _calendarFormat = CalendarFormat.month;

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

  /// ✅ Collect planned dates for all users with status information
  /// Group planned dates for calendar with attendance status
  Map<DateTime, List<Map<String, dynamic>>> groupPlannedDatesForCalendar() {
    final map = <DateTime, List<Map<String, dynamic>>>{};
    final seen = <String, Set<String>>{};
    // key = dayKey, value = set of bookingData.id already added for that day

    for (var att in controller.attendanceList) {
      final bookingId = att.bookingData?.id;
      if (bookingId == null) continue; // skip null ids

      for (var p in att.bookingData?.plannedDate ?? []) {
        final parsed = DateTime.tryParse(p.date);
        if (parsed == null) continue;

        final dayKey = DateTime(parsed.year, parsed.month, parsed.day);

        // Initialize set for the day
        seen.putIfAbsent(dayKey.toIso8601String(), () => <String>{});

        // Only add if this bookingId hasn't been added for this day yet
        if (!seen[dayKey.toIso8601String()]!.contains(bookingId)) {
          seen[dayKey.toIso8601String()]!.add(bookingId);

          // Add rider info with status to map
          map.update(
            dayKey,
            (list) => [
              ...list,
              {'name': att.riderName, 'status': att.attendanceStatus},
            ],
            ifAbsent: () => [
              {'name': att.riderName, 'status': att.attendanceStatus},
            ],
          );
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
        actions: [],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.attendanceList.isEmpty) {
          return buildEmptyState();
        }

        final plannedEvents = groupPlannedDatesForCalendar();
        final filtered = _selectedDay != null
            ? filterByDate(_selectedDay!)
            : controller.attendanceList;

        return Column(
          children: [
            // Calendar
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                    CalendarFormat.twoWeeks: '2 Weeks',
                    CalendarFormat.week: 'Week',
                  },
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
                    defaultBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade500,
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();

                      // Get the most common status for this day
                      final statusCounts = <String, int>{};
                      for (var event in events) {
                        if (event is Map<String, dynamic>) {
                          final status =
                              event['status'] as String? ?? 'Pending';
                          statusCounts[status] =
                              (statusCounts[status] ?? 0) + 1;
                        }
                      }

                      // Determine the primary color based on status priority
                      String primaryStatus = 'Pending';
                      if (statusCounts.containsKey('Present')) {
                        primaryStatus = 'Present';
                      } else if (statusCounts.containsKey('Absent')) {
                        primaryStatus = 'Absent';
                      } else if (statusCounts.containsKey('Cancelled')) {
                        primaryStatus = 'Cancelled';
                      }

                      return Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.only(right: 3, top: 3),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: getStatusColor(primaryStatus),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              '${events.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // calendarBuilders: CalendarBuilders(
                  //   markerBuilder: (context, date, events) {
                  //     if (events.isNotEmpty) {
                  //       return Wrap(
                  //         alignment: WrapAlignment.center,
                  //         children: events.map((_) {
                  //           return Container(
                  //             margin: const EdgeInsets.symmetric(
                  //               horizontal: 0.5,
                  //             ),
                  //             width: 6,
                  //             height: 6,
                  //             decoration: const BoxDecoration(
                  //               color: Colors.green,
                  //               shape: BoxShape.circle,
                  //             ),
                  //           );
                  //         }).toList(),
                  //       );
                  //     }
                  //     return null;
                  //   },
                  // ),
                ),
              ),
            ),

            // Selected date header
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

            // Attendance List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("No attendances planned"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final attendance = filtered[index];

                        return buildAttendanceCard(
                          attendance,
                          context,
                          controller,
                          _selectedDay ?? DateTime.now(),
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
