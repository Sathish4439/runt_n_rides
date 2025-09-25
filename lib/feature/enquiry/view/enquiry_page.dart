import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/constant/const_data.dart';

import 'package:RUTSNRIDES/feature/enquiry/controller/enquiry_controller.dart';
import 'package:RUTSNRIDES/feature/enquiry/view/widget/enquity_wid.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/lead_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EnquiryPage extends StatefulWidget {
  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  var controller = Get.put(EnquiryController());

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  void _loadLeads() async {
    await controller.loadEnquirey();
    controller.loadSubmit.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enquiry Management"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_list),
          //   onPressed: () {
          //     showFilterDialog(context);
          //   },
          //   tooltip: 'Filter Leads',
          // ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeads,
            tooltip: 'Refresh Leads',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.leadsLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading leads...'),
              ],
            ),
          );
        }

        if (controller.leads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No leads found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add new leads or check your connection',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadLeads,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final events = controller.groupLeadsByDay();

        return Column(
          children: [
            // Calendar Section
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar<Lead>(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: controller.focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(controller.selectedDay, day),
                  eventLoader: (day) =>
                      events[DateTime(day.year, day.month, day.day)] ?? [],
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      controller.selectedDay = selectedDay;
                      controller.focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      controller.focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: controller.calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      controller.calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.rectangle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue),
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.blue),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                    weekendStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),

                  // ✅ Correct markerBuilder with type casting
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      // ✅ Add border around each date cell
                      return Container(
                      
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 0.8,
                          ),
                         // borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return const SizedBox();

                      final dayLeads = events.cast<Lead>();

                      // Count leads by status
                      Map<String, int> statusCount = {};
                      for (var lead in dayLeads) {
                        final key = lead.status.trim().toLowerCase();
                        statusCount[key] = (statusCount[key] ?? 0) + 1;
                      }

                      return Align(
                        alignment: Alignment
                            .topRight, // ✅ Position counts below the date
                        child: Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: statusCount.entries.map((entry) {
                            // Assign colors
                            Color markerColor;
                            switch (entry.key) {
                              case 'follow up':
                                markerColor = Colors.orange.shade100;
                                break;
                              case 'completed':
                                markerColor = Colors.black;
                                break;
                              case 'booked':
                                markerColor = Colors.green.shade100;
                                break;
                              case 'new':
                                markerColor = Colors.red.shade100;
                                break;
                              default:
                                markerColor = Colors.blue.shade100;
                            }

                            return Container(
                              margin: const EdgeInsets.only(right: 3, top: 3),
                              width: 16, // ✅ Smaller circle
                              height: 16,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: markerColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${entry.value}', // Count
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10, // ✅ Smaller font
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Selected Date Header
            if (controller.selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Leads for ${DateFormat('MMM dd, yyyy').format(controller.selectedDay!)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(
                        '${events[DateTime(controller.selectedDay!.year, controller.selectedDay!.month, controller.selectedDay!.day)]?.length ?? 0}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue[700],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Leads List
            Expanded(
              child: controller.selectedDay != null
                  ? buildLeadsForSelectedDay(events)
                  : buildAllLeadsList(events, (lead) async {
                      await controller.deleteLead(lead.id);
                    }),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewLead(context);
        },
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
