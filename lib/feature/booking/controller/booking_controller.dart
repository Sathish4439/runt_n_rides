import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/gsheet_services.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';

class BookingController extends GetxController {
  var loadBooking = false.obs;
  var listofBooking = <Booking>[].obs;
  final dateFormat = DateFormat('MMM dd, yyyy');
  final currencyFormat = NumberFormat.currency(symbol: '₹');
  var currentView = 'ALL'.obs; // 'ALL', 'PENDING', 'CONFIRMED', 'PAID'
  var searchQuery = ''.obs;
  var sortBy = 'date'.obs;

  Future<void> loadLeads() async {
    try {
      loadBooking(true);
      final googleSheets = GoogleSheetsService();
      await googleSheets.init(
        SheetId.bookingSheet,
        bookingSheetName: "Form responses 1",
      );
      final fetchedLeads = await googleSheets.fetchBookings();

      listofBooking.assignAll(fetchedLeads);

      print("listofBooking ${listofBooking.length}");
    } catch (e) {
      print("Error loading leads: $e");
    } finally {
      loadBooking(false);
    }
  }
}
