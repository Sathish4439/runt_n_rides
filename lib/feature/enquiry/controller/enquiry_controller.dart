import 'dart:io';

import 'package:RUTSNRIDES/feature/enquiry/model/program_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:RUTSNRIDES/core/constant/const_data.dart';
import 'package:RUTSNRIDES/core/services/api_service.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';

import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/lead_model.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';
import 'package:table_calendar/table_calendar.dart';

class EnquiryController extends GetxController {
  final api = ApiService();
  var leads = <Lead>[].obs;
  var leadsLoading = false.obs;
  var followUpLoading = false.obs;
  var plannedData = <CompletedDate>[].obs;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  CalendarFormat calendarFormat = CalendarFormat.month;

  var paymentProof = "".obs;

  var receivedAmount = TextEditingController();

  var bookingStatus = "".obs;
  void addDate(DateTime date) {
    final formatted = DateFormat("yyyy-MM-dd").format(date);
    if (!plannedData.contains(formatted)) {
      var date = CompletedDate(date: formatted, duration: trainingSlot.value);
      plannedData.add(date);
    }

    printData(plannedData.toString());
  }

  void removeDate(String date) {
    plannedData.removeWhere((d) => d.date == date);
  }

  // Text controllers
  final riderName = TextEditingController();
  final age = TextEditingController();
  final parentName = TextEditingController();
  final phone = TextEditingController();
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
  final medicalCondition = TextEditingController();
  final isLoading = false.obs; // reactive variable
  final ImagePicker picker = ImagePicker();

  // Dropdown values
  var trainingSlot = ''.obs;
  var sessionType = 'Private'.obs;
  var paymentStatus = ''.obs;
  var paymentMode = "".obs;
  var selectedBookingType = "".obs;

  // Checkbox values
  var bikeRental = false.obs;
  var gearRental = false.obs;
  var accomdation = false.obs;

  Future<void> pickAndUpload(File imageFile) async {
    try {
      var response = await api.postFile(
        EndPoints.upload,
        fileKey: "paymentProof",
        filePath: imageFile.path,
      );

      if (response.statusCode == 200) {
        paymentProof.value = response.data['filename'];
        printData("paymentProof.value ${paymentProof.value}");
      } else {
        Get.snackbar("Error", "Upload failed");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      printData(e);
    }
  }

  void findandSet(String findString) {
    printData(findString);
    for (var i in programs) {
      if (i.title == findString) {
        selectedProgram.value = i;
      }
    }
  }

  void setBookingData(Booking booking) {
    findandSet(booking.programBooked);

    printData(booking.toJson());

    printData(booking.plannedDate);
    riderName.text = booking.riderName;
    age.text = booking.riderAge.toString();
    parentName.text = booking.parentName;
    phone.text = booking.phone;

    programDetails.text = booking.programDetails;
    headSize.text = booking.headSize;
    pantSize.text = booking.pantSize;
    height.text = booking.height;
    weight.text = booking.weight;
    shirtSize.text = booking.shirtSize;

    bookingDate.text = booking.bookingDate;
    preferredSessionDate.text = booking.preferredSessionDate;
    totalFee.text = booking.totalFee.toString();
    amtPaid.text = booking.amountPaid.toString();
    medicalCondition.text = booking.medicalCondition; // or adjust field

    trainingSlot.value = booking.trainingSlot;
    sessionType.value = booking.sessionType;
    paymentStatus.value = booking.paymentStatus;
    paymentMode.value = booking.paymentMode;
    selectedBookingType.value = booking.bookingType;
    headSize.text = booking.headSize;

    paymentProof.value = booking.paymentProof.isNotEmpty
        ? booking.paymentProof.first
        : "";
    plannedData.value = booking.plannedDate;

    bikeRental.value = booking.bikeRental.toLowerCase() == 'yes';
    gearRental.value = booking.gearRental.toLowerCase() == 'yes';

    accomdation.value = booking.accomdation.toLowerCase() == "yes";
  }

  void setEnquiryData(Lead lead) {
    // Text fields

    findandSet(lead.programInterest);
    riderName.text = lead.fullName;
    age.text = lead.age.toString();
    parentName.text = ""; // Not in Lead
    phone.text = lead.whatsapp;

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
    accomdation.value = (lead.accommodation.toLowerCase() == 'yes');
    medicalCondition.text = (lead.medicalDetails);
  }

  final paymentMethod = ["UPI", "Bank Transfer", "Card", "Cash"];
  final bookingType = ["Online", "Offline"];

  final paymentStatuses = ["Pending", "Partially Paid", "Completed"];

  var selectedProgram = TrainingProgram.nullTrainingProgram.obs;

  //radio button data
  final programs = [
    TrainingProgram(
      id: 1,
      name: "Ruts Start",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Private"],
      title: "I am a Beginner",
    ),
    TrainingProgram(
      id: 1,
      name: "Ruts Start",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Private"],
      title: "Ruts Start - Rs.7000",
    ),
    TrainingProgram(
      id: 2,
      name: "Ruts Foundation",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Private"],
      title: "Ruts Foundation - Rs.5200",
    ),
    TrainingProgram(
      id: 3,
      name: "Ruts Dirt Training",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Group", "Private"],
      title: "Ruts Dirt Training - Group: Rs.7200 / Private: Rs.9200",
    ),
    TrainingProgram(
      id: 4,
      name: "Ruts Explore (ADV L1)",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Group", "Private"],
      title: "Ruts Explore (ADV L1) - Group: Rs.6200 / Private: Rs.8200",
    ),
    TrainingProgram(
      id: 5,
      name: "Ruts Conquer (ADV L2)",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Group", "Private"],
      title: "Ruts Conquer (ADV L2) - Group: Rs.8200 / Private: Rs.10,500",
    ),
    TrainingProgram(
      id: 6,
      name: "Ruts Grit (EnduroX L1)",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Group", "Private"],
      title: "Ruts Grit (EnduroX L1) - Group: Rs.3800 / Private: Rs.5500",
    ),
    TrainingProgram(
      id: 7,
      name: "Ruts Enduro Mastery (EnduroX L2)",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)", "Full Day"],
      sessionTypes: ["Group", "Private"],
      title:
          "Ruts Enduro Mastery (EnduroX L2) - Group: Rs.5800 / Private: Rs.7500",
    ),
    TrainingProgram(
      id: 8,
      name: "Ruts Weekend",
      durations: ["2 Days (Weekend Special)"],
      sessionTypes: ["Private"],
      title: "Ruts Weekend - Rs.14,500",
    ),
    TrainingProgram(
      id: 9,
      name: "Rally Raid & Roadbook Theory",
      durations: ["Morning (9AM–12PM)", "Afternoon (2PM–5PM)"],
      sessionTypes: ["Private"],
      title: "Rally Raid & Roadbook Theory - Rs.2500",
    ),
    TrainingProgram(
      id: 10,
      name: "Young Ruts",
      durations: [
        "Morning (9AM–12PM)",
        "Afternoon (2PM–5PM)",
        "Full Day",
        "Monthly",
      ],
      sessionTypes: ["Private"],
      title: "Young Ruts - Session: Rs.4500 / Monthly: Rs.32,000",
    ),
    TrainingProgram(
      id: 11,
      name: "Ruts n Queens",
      durations: [
        "Morning (9AM–12PM)",
        "Afternoon (2PM–5PM)",
        "Full Day",
        "Weekend",
      ],
      sessionTypes: ["Private"],
      title: "Ruts n Queens - Half: Rs.2500 / Full: Rs.4500 / Weekend: Rs.8999",
    ),
    TrainingProgram(
      id: 12,
      name: "Adult One-on-One",
      durations: ["Custom (Single Day)", "Monthly"],
      sessionTypes: ["Private"],
      title: "Adult One-on-One - One Day: Rs.4999 / Monthly: Rs.30,000",
    ),
    TrainingProgram(
      id: 13,
      name: "Custom Training Plan",
      durations: ["Custom"],
      sessionTypes: ["Private"],
      title: "Custom Training Plan",
    ),
    TrainingProgram(
      id: 14,
      name: "Open Training - Track Access Only",
      durations: ["Full Day"],
      sessionTypes: ["Private"],
      title: "Open Session - Rs.1600/day",
    ),
    TrainingProgram(
      id: 15,
      name: "Dirt Bike Training - Beginner Level",
      durations: ["Full Day"],
      sessionTypes: ["Private"],
      title: "Dirt Bike Training - Beginner Level",
    ),
  ].obs;

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
    String enquiryId,
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
        "enquiryId": enquiryId,
        "plannedDate": bookingData.plannedDate,
        "medicalCondition": medicalCondition.text,
        "accomdation": accomdation.value == true ? "Yes" : "No",
        "bookingId": bookingData.id,
      };

      printData(bookingJson);

      var bookingRes = await api.post(
        EndPoints.createBooking,
        data: bookingJson,
      );

      if (bookingRes.data['success']) {
        printData("✅ Booking created: ${bookingRes.data}");

        // After booking, create attendance
        await createAttendance(attendance, bookingRes.data['bookingId']);

        showSuccess(bookingRes.data['message']);
        Get.back();
      } else {
        showError(bookingRes.data['message']);
      }
    } catch (e) {
      showError("❌ Failed to submit: ${e.toString()}");
    } finally {
      loadSubmit.value = false;
    }
  }

  Future<void> createAttendance(Attendance attendance, String bookingId) async {
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
        "bookingId": bookingId,
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

  void setSelectedProgram(TrainingProgram value) {
    selectedProgram.value = value;
  }

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
    plannedData.clear();
    parentName.clear();
    phone.clear();
    programDetails.clear();
    bookingDate.clear();
    preferredSessionDate.clear();
    totalFee.clear();
    amtPaid.clear();

    // Reset dropdown values
    selectedProgram.value = TrainingProgram.nullTrainingProgram;
    paymentProof.value = "";
    trainingSlot.value = "";
    sessionType.value = "";
    paymentStatus.value = "";
    paymentMode.value = "";
    selectedBookingType.value = "";

    // Reset checkboxes
    bikeRental.value = false;
    gearRental.value = false;
    receivedAmount.clear();
    paymentProof.close();
    // Reset loading
    isLoading.value = false;
    pantSize.clear();
    headSize.clear();
    shirtSize.clear();
    height.clear();
    weight.clear();
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
    selectedProgram.value = TrainingProgram.nullTrainingProgram;
    trainingSlot.value = '';
    sessionType.value = '';
    paymentStatus.value = '';
    paymentMode.value = '';
    selectedBookingType.value = '';
    bikeRental.value = false;
    gearRental.value = false;
    isLoading.value = false;
    paymentProof.value = "";

    plannedData.clear();
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

  Future<void> updateBooking(String? id, Booking bookingData) async {
    try {
      final data = bookingData.toJson();
      data.remove("_id"); // ✅ prevent ObjectId cast error

      var res = await api.put("${EndPoints.booking}/$id", data: data);

      if (res.data['success']) {
        showSuccess(res.data['message']);
      } else {
        showError(res.data['message']);
      }
    } catch (e) {
      printData(e);
    }
  }

  Future<void> updateAttendance(String? id, Attendance attendance) async {
    try {
      final data = attendance.toJson();
      data.remove("_id"); // ✅ prevent ObjectId cast error

      var res = await api.put("${EndPoints.attendance}/$id", data: data);

      if (res.data['success']) {
        showSuccess(res.data['message']);
      } else {
        showError(res.data['message']);
      }
    } catch (e) {
      printData(e);
    }
  }
}
