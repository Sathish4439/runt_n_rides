// attendance_controller.dart
import 'dart:ui';

import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/gsheet_services.dart';
import 'package:rutsnrides_admin/core/theme/app_theme.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';

class AttendanceController extends GetxController {
  final GoogleSheetsService _sheetsService = GoogleSheetsService();

  // Observables
  var isLoading = false.obs;
  var attendanceList = <Attendance>[].obs;
  var filteredList = <Attendance>[].obs;
  var selectedDate = DateTime.now().obs;
  var searchQuery = ''.obs;
  var stats = <String, dynamic>{}.obs;

  // Fetch all attendance
  Future<void> fetchAttendance() async {
    try {
      isLoading(true);
      final data = await _sheetsService.fetchAttendanceData(
        SheetId.followBack,
        attendanceSheetName: "attandence",
      );
      attendanceList.assignAll(data);
      filteredList.assignAll(data);
      await _calculateStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch attendance: $e');
    } finally {
      isLoading(false);
    }
  }

  // Filter by date
  void filterByDate(DateTime date) {
    selectedDate.value = date;
    filteredList.value = attendanceList.where((attendance) {
      final sessionDate = _parseDate(attendance.sessionDate);
      return sessionDate != null &&
          sessionDate.year == date.year &&
          sessionDate.month == date.month &&
          sessionDate.day == date.day;
    }).toList();
    _calculateStats();
  }

  // Search by rider name or phone
  void searchAttendance(String query) {
    searchQuery.value = query.toLowerCase();
    filteredList.value = attendanceList.where((attendance) {
      return attendance.riderName.toLowerCase().contains(searchQuery.value) ||
          attendance.phoneNumber.contains(searchQuery.value);
    }).toList();
    _calculateStats();
  }

  // Filter by status
  void filterByStatus(String status) {
    if (status == 'All') {
      filteredList.value = attendanceList;
    } else {
      filteredList.value = attendanceList
          .where((attendance) => attendance.attendanceStatus == status)
          .toList();
    }
    _calculateStats();
  }

  // Calculate statistics
  Future<void> _calculateStats() async {
    final present = filteredList
        .where((a) => a.attendanceStatus == 'Present')
        .length;
    final absent = filteredList
        .where((a) => a.attendanceStatus == 'Absent')
        .length;
    final cancelled = filteredList
        .where((a) => a.attendanceStatus == 'Cancelled')
        .length;
    final total = filteredList.length;

    stats.value = {
      'total': total,
      'present': present,
      'absent': absent,
      'cancelled': cancelled,
      'attendanceRate': total > 0 ? (present / total * 100) : 0,
    };
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateAddress(Attendance updatedAttendance) async {
    try {
      var res = await GoogleSheetsService().updateAttendanceDetails(
        updatedAttendance,
      );

      if (res) {
        Get.snackbar(
          "Success",
          "Attendance updated for ${updatedAttendance.riderName}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFC8E6C9),
          colorText: AppTheme.bookingPrimary,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Update Failed",
        "",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFCDD2),
        colorText: const Color(0xFFB71C1C),
      );
    } finally {
      fetchAttendance();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchAttendance();
  }

  @override
  void onClose() {
    // Dispose all TextEditingControllers

    // Clear all Rx variables

    isLoading.value = false;

    // Clear attendance and other related Rx variables
    attendanceList.clear();
    filteredList.clear();
    selectedDate.value = DateTime.now();
    searchQuery.value = '';
    stats.clear();

    super.onClose();
  }
}
