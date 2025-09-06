import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/api_service.dart';
import 'package:rutsnrides_admin/core/services/endpoint.dart';

import 'package:rutsnrides_admin/core/utils/utils.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';
import 'package:rutsnrides_admin/feature/enquiry/model/lead_model.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';
import 'package:table_calendar/table_calendar.dart';

class EnquiryController extends GetxController {
  final api = ApiService();
  var leads = <Lead>[].obs;
  var leadsLoading = false.obs;
  var followUpLoading = false.obs;

  // Text controllers
  final riderName = TextEditingController();
  final age = TextEditingController();
  final parentName = TextEditingController();
  final phone = TextEditingController();
  var selectedProgram = "".obs;
  final programDetails = TextEditingController();
  var headSize = TextEditingController();
  var pantSize = TextEditingController();
  var height = TextEditingController();
  var weight = TextEditingController();
  var shirtSize = TextEditingController();

  final bookingDate = TextEditingController();
  final preferredSessionDate = TextEditingController();
  final totalFee = TextEditingController();
  final amtPaid = TextEditingController();
  final isLoading = false.obs;

  // Dropdown values
  var trainingSlot = ''.obs;
  var sessionType = ''.obs;
  var paymentStatus = ''.obs;
  var paymentMode = "".obs;
  var selectedBookingType = "".obs;

  // Checkbox values
  var bikeRental = false.obs;
  var gearRental = false.obs;

  void setEnquiryData(Lead lead) {
    // Text fields

    printData(lead.toJson());
    riderName.text = lead.fullName;
    age.text = lead.age.toString();
    parentName.text = ""; // Not in Lead
    phone.text = lead.whatsapp;
    selectedProgram.value = lead.programInterest;
    programDetails.text = "";
    preferredSessionDate.text = "";
    totalFee.text = ""; // Not available in Lead
    amtPaid.text = ""; // Not available in Lead

    // Dropdown values
    trainingSlot.value = ""; // Not in Lead
    sessionType.value = ""; // Not in Lead
    paymentStatus.value = "";
    paymentMode.value = ""; // Not in Lead
    selectedBookingType.value = ""; // Not in Lead

    // Checkboxes
    bikeRental.value = (lead.bikeRental.toLowerCase() == "yes");
    gearRental.value = (lead.gearRental.toLowerCase() == "yes");
  }

  // Dropdown options
  final trainingSlots = [
    "Morning (9AM–12PM)",
    "Afternoon (2PM–5PM)",
    "Full Day",
  ];
  final paymentMethod = ["UPI", "Bank Transfer", "Card", "Cash"];
  final bookingType = ["Online", "Offline"];
  final sessionTypes = ["Private", "Group"];
  final paymentStatuses = ["Pending", "Partially Paid", "Completed"];

  //radio button data
  final programs = [
    'Ruts Start - Rs.7000',
    'Ruts Foundation - Rs.5200',
    'Ruts Dirt Training - Group: Rs.7200 / Private: Rs.9200',
    'Ruts Explore (ADV L1) - Group: Rs.6200 / Private: Rs.8200',
    'Ruts Conquer (ADV L2) - Group: Rs.8200 / Private: Rs.10,500',
    'Ruts Grit (EnduroX L1) - Group: Rs.3800 / Private: Rs.5500',
    'Ruts Enduro Mastery (EnduroX L2) - Group: Rs.5800 / Private: Rs.7500',
    'Ruts Weekend - Rs.14,500',
    'Rally Raid & Roadbook Theory - Rs.2500',
    'Young Ruts - Session: Rs.4500 / Monthly: Rs.32,000',
    'Ruts n Queens - Half: Rs.2500 / Full: Rs.4500 / Weekend: Rs.8999',
    'Adult One-on-One - One Day: Rs.4999 / Monthly: Rs.30,000',
    'Custom Training Plan',
    'open session - Rs.1600/day',
    "Dirt Bike Training - Beginner Level",
  ];

  // Date pickers

  Future<void> pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Format as ISO "yyyy-MM-dd"
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      controller.text = formattedDate;
    }
  }

  // Submit function

  Future<void> updateFollowUp(String id, String note, DateTime date) async {
    try {
      followUpLoading(true);
      final response = await api.put(
        "${EndPoints.form}/$id", // replace with your API endpoint
        data: {
          "followUpNotes": note,
          "followUpDate": date.toIso8601String(),
          "status": "Follow Up",
        },
      );

      printData(response);

      if (response.statusCode == 200) {
        printData("✅ Follow-up updated: ${response.data}");
      } else {
        printData(
          "⚠️ Failed: ${response.statusCode} ${response.statusMessage}",
        );
      }
    } catch (e) {
      printData("❌ Error updating follow-up: $e");
    } finally {
      followUpLoading(false);
      loadEnquirey();
    }
  }

  // Add loading state
  var loadSubmit = false.obs;

  // Your existing code...
  Future<void> submitBookingAndAttendance(
    Booking bookingData,
    Attendance attendance,
  ) async {
    try {
      loadSubmit.value = true;

      // Booking body
      var bookingJson = {
        "timestamp": bookingData.timestamp,
        "fullNameOfRider": bookingData.riderName,
        "phoneNumber": bookingData.phone,
        "programBooked": bookingData.programBooked,
        "programDetails": bookingData.programDetails,
        "bookingDate": bookingData.bookingDate,
        "sessionDate": bookingData.preferredSessionDate,
        "trainingSlot": bookingData.trainingSlot,
        "sessionType": bookingData.sessionType,
        "bikeRental": bookingData.bikeRental,
        "gearRental": bookingData.gearRental,
        "totalProgramFee": bookingData.totalFee,
        "paymentStatus": bookingData.paymentStatus,
        "amountPaid": bookingData.amountPaid,
        "paymentMode": bookingData.paymentMode,
        "paymentProof": bookingData.paymentProof,
        "ageOfRider": bookingData.riderAge,
        "parentName": bookingData.parentName,
        "bookingType": bookingData.bookingType,
        "receivedAmount": bookingData.receivedAmount,
        "height": bookingData.height,
        "weight": bookingData.weight,
        "headSize": bookingData.headSize,
        "pantSize": bookingData.pantSize,
        "shirtSize": bookingData.shirtSize,
      };

      // First call booking API
      var bookingRes = await api.post(
        EndPoints.createBooking,
        data: bookingJson,
      );

      if (bookingRes.data['success']) {
        printData("✅ Booking created: ${bookingRes.data}");

        // After booking, create attendance
        await createAttendance(attendance);

        showSuccess("Booking & Attendance created successfully!");
        Get.back();
      } else {
        showError("Booking failed: ${bookingRes.data['message']}");
      }
    } catch (e) {
      showError("❌ Failed to submit: ${e.toString()}");
    } finally {}
  }

  Future<void> createAttendance(Attendance attendance) async {
    try {
      var attendanceJson = {
        "riderName": attendance.riderName,
        "phoneNumber": attendance.phoneNumber,
        "programBooked": attendance.programBooked,
        "sessionDate": attendance.sessionDate,
        "sessionNumber": attendance.sessionNumber ?? 0,
        "totalSessions": attendance.totalSessions ?? 0,
        "attendanceStatus": attendance.attendanceStatus ?? "",
        "sessionDuration": attendance.sessionDuration ?? "",
        "sessionCompletion": attendance.sessionCompletion ?? "",
        "sessionsCompleted": attendance.sessionsCompleted ?? 0,
        "fullDaysDone": attendance.fullDaysDone ?? 0,
        "halfDaysDone": attendance.halfDaysDone ?? 0,
        "sessionsRemaining": attendance.sessionsRemaining ?? 0,
        // "//trainingStarted": attendance.//trainingStarted ?? false,
      };

      var res = await api.post(
        EndPoints.createAttendence,
        data: attendanceJson,
      );

      if (res.data['success']) {
        printData("✅ Attendance created: ${res.data}");
      } else {
        showError("Attendance failed: ${res.data['message']}");
      }
    } catch (e) {
      showError("❌ Attendance error: ${e.toString()}");
    } finally {
      loadSubmit.value = false;
      clearBookingForm();
      Get.back();
    }
  }

  void setSelectedProgram(String value) {
    selectedProgram.value = value;
  }

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  CalendarFormat calendarFormat = CalendarFormat.month;

  var paymentProof = "".obs;

  var receivedAmount = TextEditingController();

  var bookingStatus = "".obs;

  /// Load leads from Google Sheets
  Future<void> loadEnquirey() async {
    try {
      leadsLoading(true);

      var res = await api.get(EndPoints.getAllformEnquiry);

      if (res.data['success']) {
        var li = (res.data['leads'] as List)
            .map((e) => Lead.fromJson(e))
            .toList();

        if (li.isNotEmpty) {
          leads.value = li;
        }
      }
    } catch (e) {
      printData(e);
    } finally {
      leadsLoading(false);
    }
  }

  DateTime? parseFollowUpDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    // Try MM/dd/yyyy HH:mm
    try {
      return DateFormat("M/d/yyyy H:mm").parse(dateStr);
    } catch (_) {}

    // Try ISO format fallback
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}

    // Try Excel serial number (days since 1899-12-30)
    try {
      final double excelDays = double.parse(dateStr);
      return DateTime(1899, 12, 30).add(Duration(days: excelDays.toInt()));
    } catch (_) {}

    print("Cannot parse followUpDate: $dateStr");
    return null;
  }

  Map<DateTime, List<Lead>> groupLeadsByDay() {
    final Map<DateTime, List<Lead>> grouped = {};

    for (var lead in leads) {
      // If lead has a follow-up date, use only that
      if (lead.followUpDate != null && lead.followUpDate.isNotEmpty) {
        final DateTime? fuDate = parseFollowUpDate(lead.followUpDate);
        if (fuDate != null) {
          final DateTime fuDay = DateTime(
            fuDate.year,
            fuDate.month,
            fuDate.day,
          );
          if (!grouped.containsKey(fuDay)) grouped[fuDay] = [];
          grouped[fuDay]!.add(lead);
          continue; // ✅ skip adding timestampDate
        }
      }

      // Otherwise group by timestampDate
      final DateTime tsDay = DateTime(
        lead.timestampDate.year,
        lead.timestampDate.month,
        lead.timestampDate.day,
      );

      if (!grouped.containsKey(tsDay)) grouped[tsDay] = [];
      grouped[tsDay]!.add(lead);
    }

    return grouped;
  }

  // ✅ Clear form data (for reuse)
  void clearBookingForm() {
    // Clear text fields
    riderName.clear();
    age.clear();
    parentName.clear();
    phone.clear();
    programDetails.clear();
    bookingDate.clear();
    preferredSessionDate.clear();
    totalFee.clear();
    amtPaid.clear();

    // Reset dropdown values
    selectedProgram.value = "";
    trainingSlot.value = "";
    sessionType.value = "";
    paymentStatus.value = "";
    paymentMode.value = "";
    selectedBookingType.value = "";

    // Reset checkboxes
    bikeRental.value = false;
    gearRental.value = false;
    receivedAmount.clear();
    // Reset loading
    isLoading.value = false;
    pantSize.clear();
    headSize.clear();
    shirtSize.clear();
    height.clear();
    weight.clear();

    print("✅ Booking form cleared!");
  }

  // ✅ Dispose controllers when widget/controller is destroyed
  @override
  void onClose() {
    // Dispose all TextEditingControllers
    riderName.dispose();
    age.dispose();
    parentName.dispose();
    phone.dispose();
    programDetails.dispose();
    bookingDate.dispose();
    preferredSessionDate.dispose();
    totalFee.dispose();
    amtPaid.dispose();

    // Clear all Rx variables
    selectedProgram.value = '';
    trainingSlot.value = '';
    sessionType.value = '';
    paymentStatus.value = '';
    paymentMode.value = '';
    selectedBookingType.value = '';
    bikeRental.value = false;
    gearRental.value = false;
    isLoading.value = false;

    super.onClose();
  }

  Future<void> deleteLead(String id) async {
    try {
      var res = await api.delete("${EndPoints.form}/$id");

      if (res.data['success']) {
        showSuccess(res.data['message']);
      } else {
        showError(res.data['message']);
      }
    } catch (e) {}
  }
}
