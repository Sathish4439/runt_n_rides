import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';

import 'package:rutsnrides_admin/core/theme/app_theme.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';
import 'package:rutsnrides_admin/feature/booking/controller/booking_controller.dart';
import 'package:intl/intl.dart';
import 'package:rutsnrides_admin/feature/booking/view/widget/booking_wid.dart';

class BookingPage extends StatefulWidget {
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingController controller = Get.put(BookingController());
  // 'date', 'name', 'amount'

  @override
  void initState() {
    super.initState();
    controller.loadLeads();
  }

  // Helper method to parse date strings safely
  DateTime parseDate(String dateString) {
    try {
      // Try parsing with the format "M/d/yyyy HH:mm:ss"
      if (dateString.contains('/')) {
        final parts = dateString.split(' ');
        final dateParts = parts[0].split('/');

        // Handle different date formats
        if (dateParts.length >= 3) {
          return DateTime(
            int.parse(dateParts[2]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[0]), // day
          );
        }
      }

      // Try standard DateTime parsing
      return DateTime.parse(dateString);
    } catch (e) {
      // If parsing fails, return current date as fallback
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Management'),
        backgroundColor: AppTheme.bookingPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadLeads(),
            tooltip: 'Refresh Bookings',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              exportData(controller);
            },
            tooltip: 'Export Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.sortBy.value = value;
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(
                value: 'amount',
                child: Text('Sort by Amount'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Search Section
          buildFilterSection(controller),

          // Statistics Summary
          buildStatsSummary(controller),

          // Bookings List
          Expanded(
            child: Obx(() {
              if (controller.loadBooking.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredBookings = filterAndSortBookings(
                controller.listofBooking,
                controller,
              );

              if (filteredBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.isEmpty
                            ? 'No ${controller.currentView.toLowerCase()} bookings'
                            : 'No results for "${controller.searchQuery}"',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = filteredBookings[index];

                  return Dismissible(
                    key: Key(booking.id ?? index.toString()), // unique key
                    direction:
                        DismissDirection.endToStart, // swipe from right to left
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      bool confirm = false;
                      await Get.defaultDialog(
                        title: 'Confirm Delete',
                        middleText:
                            'Are you sure you want to delete this booking?',
                        textCancel: 'No',
                        textConfirm: 'Yes',
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
                    onDismissed: (direction) async {
                      // Remove from controller's booking list
                      controller.deleteBooking(booking.id!);
                      Get.snackbar(
                        'Deleted',
                        'Booking for ${booking.riderName} has been deleted.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: buildBookingCard(booking, context, controller),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
