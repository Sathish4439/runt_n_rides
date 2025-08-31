import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/common_wid/widget.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/gsheet_services.dart';
import 'package:rutsnrides_admin/feature/enquiry/controller/enquiry_controller.dart';
import 'package:rutsnrides_admin/feature/enquiry/view/widget/enquity_wid.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rutsnrides_admin/feature/enquiry/model/lead_model.dart';
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
    await controller.loadLeads();
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
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
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
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return const SizedBox();

                      // Cast dynamic list into List<Lead>
                      final dayLeads = events.cast<Lead>();

                      return Wrap(
                        spacing: 2,
                        runSpacing: 2,
                        children: dayLeads.map((lead) {
                          // Assign colors based on lead status
                          Color markerColor;
                          switch (lead.status.trim().toLowerCase()) {
                            case 'follow up':
                              markerColor = Colors.green;
                              break;
                            case 'lead':
                              markerColor = Colors.red;
                              break;
                            case 'completed':
                              markerColor = Colors.grey;
                              break;
                            default:
                              markerColor = Colors.blue;
                          }

                          return Column(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                // child: Text(lead.status),
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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
                  : buildAllLeadsList(events),
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
