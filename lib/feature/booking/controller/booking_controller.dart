import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/api_service.dart';
import 'package:rutsnrides_admin/core/services/endpoint.dart';
import 'package:rutsnrides_admin/core/utils/utils.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';

class BookingController extends GetxController {
  var loadBooking = false.obs;
  var listofBooking = <Booking>[].obs;
  final dateFormat = DateFormat('MMM dd, yyyy');
  final currencyFormat = NumberFormat.currency(symbol: '₹');
  var currentView = 'ALL'.obs; // 'ALL', 'PENDING', 'CONFIRMED', 'PAID'
  var searchQuery = ''.obs;
  var sortBy = 'date'.obs;
  var api = ApiService();

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
      var res = await api.delete("${EndPoints.booking}/$s");
      printData(res);
    } catch (e) {
      printData(e);
    } finally {
      loadLeads();
    }
  }
}
