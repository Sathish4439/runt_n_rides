import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/gsheet_services.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';
import 'package:rutsnrides_admin/feature/enquiry/model/lead_model.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';
import 'package:table_calendar/table_calendar.dart';

class EnquiryController extends GetxController {
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
      controller.text = "${picked.day}-${picked.month}-${picked.year}";
    }
  }

  // Submit function

  // Add loading state
  var loadSubmit = false.obs;

  // Your existing code...

  void submitBooking(Booking bookingData, Attendance attandance) async {
    try {
      loadSubmit.value = true; // Start loading

      final googleSheetsService = GoogleSheetsService();
      await googleSheetsService.insertBooking(
        SheetId.bookingSheet,
        "Form responses 1",
        bookingData,
      );

      await googleSheetsService.insertAttendance(
        SheetId.followBack,
        "attandence",
        attandance,
      );

      // Show success message
      Get.snackbar(
        'Success',
        'Booking submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to submit booking: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadSubmit.value = false;
      clearBookingForm();
      // Stop loading
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

  var trainingStarted = "".obs;

  /// Load leads from Google Sheets
  Future<void> loadLeads() async {
    try {
      leadsLoading(true);
      final googleSheets = GoogleSheetsService();
      await googleSheets.init(
        SheetId.enquiryForm,
        leadSheetName: "Form responses 1",
      );
      final fetchedLeads = await googleSheets.fetchLeads();

      leads.assignAll(fetchedLeads);
    } catch (e) {
      print("Error loading leads: $e");
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
      // timestampDate is already DateTime
      final DateTime tsDay = DateTime(
        lead.timestampDate.year,
        lead.timestampDate.month,
        lead.timestampDate.day,
      );

      // Add lead to map by timestampDate
      if (!grouped.containsKey(tsDay)) grouped[tsDay] = [];
      grouped[tsDay]!.add(lead);

      // Parse followUpDate (String) to DateTime
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
        }
      }
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
}
