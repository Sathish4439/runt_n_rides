import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:RUTSNRIDES/core/services/api_service.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';

class BookingController extends GetxController {
  var loadBooking = false.obs;
  var listofBooking = <Booking>[].obs;
  final dateFormat = DateFormat('MMM dd, yyyy');
  final currencyFormat = NumberFormat.currency(symbol: '₹');
  var currentView = 'ALL'.obs; // 'ALL', 'PENDING', 'CONFIRMED', 'PAID'
  var searchQuery = ''.obs;
  var sortBy = 'date'.obs;
  var api = ApiService();
  var loadmarkCompleted = false.obs;

  // Map to track loading states for individual bookings
  var bookingLoadingStates = <String, bool>{}.obs;

  Future<void> loadLeads() async {
    try {
      loadBooking(true);

      listofBooking.clear();
      var res = await api.get(EndPoints.getAllBooking);
      printData(res);

      if (res.data['success']) {
        var li = (res.data['bookings'] as List)
            .map((e) => Booking.fromJson(e))
            .toList();

        if (li.isNotEmpty) {
          listofBooking.value = li;
        }

        printData("listofBooking ${listofBooking.length}");
      }
    } catch (e) {
      print("Error loading leads: $e");
    } finally {
      loadBooking(false);
    }
  }

  Future<void> deleteBooking(String s) async {
    try {
      loadmarkCompleted(true);
      var res = await api.delete("${EndPoints.booking}/$s");
      printData(res);
    } catch (e) {
      printData(e);
    } finally {
      loadLeads();
      loadmarkCompleted(false);
    }
  }

  Future<void> markCompleted(String bookingId) async {
    try {
      // Set loading state for this specific booking
      bookingLoadingStates[bookingId] = true;

      var res = await api.put("${EndPoints.mark_completed}/$bookingId");
      printData(res);

      if (res.data['success']) {
        showSuccess(res.data['message']);
      } else {
        showError(res.data['message']);
      }
    } catch (e) {
      printData(e);
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Clear loading state for this specific booking
      bookingLoadingStates[bookingId] = false;
      loadLeads();
    }
  }

  // Helper method to check if a specific booking is loading
  bool isBookingLoading(String bookingId) {
    return bookingLoadingStates[bookingId] ?? false;
  }
}
