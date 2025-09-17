import 'dart:ffi' hide Size;

import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/program_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/controller/enquiry_controller.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/lead_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/view/widget/enquity_wid.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';

class ConfirmBookingPage extends StatefulWidget {
  final Lead? enquirydata;
  final Booking? bookingData;
  final Attendance? attendance;
  final String from;

  const ConfirmBookingPage({
    super.key,
    this.enquirydata,
    this.bookingData,
    required this.from,
    this.attendance,
  });
  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final EnquiryController controller = Get.put(EnquiryController());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState(); // ✅ always call super first

    try {
      // reset submit state
      controller.loadSubmit(false);

      // handle enquiry or booking data
      if (widget.enquirydata != null) {
        controller.setEnquiryData(widget.enquirydata!);
      } else if (widget.bookingData != null) {
        controller.setBookingData(widget.bookingData!);
      }
    } catch (e, s) {
      debugPrint("❌ initState error: $e\n$s");
    }
  }

  bool validateData() {
    final age = int.tryParse(controller.age.text.trim()) ?? 0;
    final totalFee = int.tryParse(controller.totalFee.text.trim()) ?? 0;
    final amtPaid = int.tryParse(controller.amtPaid.text.trim()) ?? 0;

    printData("$age $totalFee $amtPaid");
    // Common fee validations
    if (totalFee == 0) {
      showError("Total fee is required");
      return false;
    }

    if (amtPaid == 0) {
      showError("Amount paid is required");
      return false;
    }

    // ✅ Extra required fields if age <= 12
    if (age <= 12) {
      if (controller.parentName.text.trim().isEmpty) {
        showError("Parent's name is required for students under 12");
        return false;
      }
      // Add more child-only validations here if needed
    }

    return true; // ✅ Passed all checks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Booking Form",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionHeader("Personal Information"),
              _buildTextField(
                "Rider Name",
                controller.riderName,
                isRequired: true,
              ),
              _buildTextField(
                "Rider Age",
                controller.age,
                keyboard: TextInputType.number,
                isRequired: true,
              ),
              _buildTextField(
                "Parent's Name",
                controller.parentName,
                isRequired:
                    (int.tryParse(controller.age.text.trim()) ?? 0) <= 12
                    ? true
                    : false,
              ),

              _buildTextField(
                "Phone",
                controller.phone,
                keyboard: TextInputType.phone,
                isRequired: true,
              ),

              SizedBox(height: 24),

              // Program Selection Section
              _buildSectionHeader("Program Details"),

              _buildProgramSelection(),
              _buildTextField("Program Details", controller.programDetails),
              _buildSectionHeader("Medical Condition"),
              _buildTextField("", controller.medicalCondition),

              SizedBox(height: 24),

              // Date & Time Section
              _buildSectionHeader("Schedule"),
              _buildDatePicker("Booking Date", controller.bookingDate, context),
              _buildDatePicker(
                "Preferred Session Date",
                controller.preferredSessionDate,
                context,
              ),
              Obx(() {
                final program = controller.selectedProgram.value;
                return _buildDropdown(
                  "Training Slot",
                  program.durations ?? [],
                  controller.trainingSlot,
                );
              }),

              Obx(
                () => _buildDropdown(
                  "Session Type",
                  controller.selectedProgram.value.sessionTypes,
                  controller.sessionType,
                ),
              ),

              SizedBox(height: 24),

              // Rental Options Section
              _buildSectionHeader("Rental Options"),
              _buildRentalOptions(),
              SizedBox(height: 24),

              // Rental Options Section
              SizedBox(height: 24),

              // Payment Section
              _buildSectionHeader("Payment Information"),
              _buildTextField(
                "Total Fee (₹)",
                controller.totalFee,
                keyboard: TextInputType.number,
                isRequired: true,
              ),
              _buildTextField(
                "Advance Paid Amount (₹)",
                controller.amtPaid,
                keyboard: TextInputType.number,
                isRequired: true,
              ),
              // _buildTextField(
              //   "Received Amount  (₹)",
              //   controller.receivedAmount,
              //   keyboard: TextInputType.number,
              //   isRequired: true,
              // ),
              _buildDropdown(
                "Payment Status",
                controller.paymentStatuses,
                controller.paymentStatus,
              ),
              _buildDropdown(
                "Payment Mode",
                controller.paymentMethod,
                controller.paymentMode,
              ),
              _buildDropdown(
                "Booking Type",
                controller.bookingType,
                controller.selectedBookingType,
              ),

              ImagePickerWidget(),
              SizedBox(height: 20),

              _buildSectionHeader("Planned Dates"),

              MultiDatePickerWidget(),
              _buildSectionHeader("Customer details"),
              SizedBox(height: 20),
              _buildTextField(
                "Height",
                controller.height,
                keyboard: TextInputType.number,
              ),
              _buildTextField(
                "Weight",
                controller.weight,
                keyboard: TextInputType.number,
              ),
              _buildTextField(
                "Head Size",
                controller.headSize,
                keyboard: TextInputType.number,
              ),
              _buildTextField(
                "Pant Size",
                controller.pantSize,
                keyboard: TextInputType.number,
              ),
              _buildTextField(
                "Shirt Size",
                controller.shirtSize,
                keyboard: TextInputType.number,
              ),

              Visibility(
                visible: widget.from == "booking",
                child: CommonButton(
                  text: "Update Booking Data",
                  onTap: () async {
                    if (widget.from == "booking" &&
                        widget.bookingData != null) {
                      printData(controller.plannedData);
                      final booking = Booking(
                        id: "",
                        accomdation: controller.accomdation.value == true
                            ? "yes"
                            : "no",
                        plannedDate: controller.plannedData,
                        paymentProof: [controller.paymentProof.value],
                        timestamp: DateTime.now().millisecondsSinceEpoch
                            .toString(),
                        riderName: controller.riderName.text,
                        medicalCondition: controller.medicalCondition.text,
                        phone: controller.phone.text,
                        programBooked: controller.selectedProgram.value.title!,
                        programDetails: controller.programDetails.text,
                        bookingDate: controller.bookingDate.text,
                        preferredSessionDate:
                            controller.preferredSessionDate.text,
                        trainingSlot: controller.trainingSlot.value,
                        sessionType: controller.sessionType.value,
                        headSize: controller.headSize.text,
                        pantSize: controller.pantSize.text,
                        shirtSize: controller.shirtSize.text,
                        height: controller.height.text,
                        weight: controller.weight.text,
                        bikeRental: controller.bikeRental.value ? "Yes" : "No",
                        gearRental: controller.gearRental.value ? "Yes" : "No",
                        totalFee:
                            double.tryParse(controller.totalFee.text) ?? 0.0,
                        paymentStatus: controller.paymentStatus.value,
                        amountPaid:
                            double.tryParse(controller.amtPaid.text) ?? 0.0,
                        paymentMode: controller.paymentMode.value,
                        riderAge: int.tryParse(controller.age.text) ?? 0,
                        parentName: controller.parentName.text,
                        bookingType: controller.selectedBookingType.value,
                        receivedAmount: 0,
                        bookingStatus: controller.bookingStatus.value,
                      );

                      await controller.updateBooking(
                        widget.bookingData!.id,
                        booking,
                      );
                    }
                  },
                ),
              ),
              Visibility(
                visible: widget.from == "attendance",
                child: CommonButton(
                  text: "Complete Booking",
                  onTap: () async {
                    if (validateData()) {
                      if ((_formKey.currentState != null &&
                              _formKey.currentState!.validate()) &&
                          widget.attendance != null &&
                          widget.bookingData != null) {
                        // Create booking data and submit
                        printData(controller.plannedData);
                        final booking = Booking(
                          id: "",
                          accomdation: controller.accomdation.value == true
                              ? "yes"
                              : "no",
                          plannedDate: controller.plannedData,
                          paymentProof: [controller.paymentProof.value],
                          timestamp: DateTime.now().millisecondsSinceEpoch
                              .toString(),
                          riderName: controller.riderName.text,
                          medicalCondition: controller.medicalCondition.text,
                          phone: controller.phone.text,
                          programBooked:
                              controller.selectedProgram.value.title!,
                          programDetails: controller.programDetails.text,
                          bookingDate: controller.bookingDate.text,
                          preferredSessionDate:
                              controller.preferredSessionDate.text,
                          trainingSlot: controller.trainingSlot.value,
                          sessionType: controller.sessionType.value,
                          headSize: controller.headSize.text,
                          pantSize: controller.pantSize.text,
                          shirtSize: controller.shirtSize.text,
                          height: controller.height.text,
                          weight: controller.weight.text,
                          bikeRental: controller.bikeRental.value
                              ? "Yes"
                              : "No",
                          gearRental: controller.gearRental.value
                              ? "Yes"
                              : "No",
                          totalFee:
                              double.tryParse(controller.totalFee.text) ?? 0.0,
                          paymentStatus: controller.paymentStatus.value,
                          amountPaid:
                              double.tryParse(controller.amtPaid.text) ?? 0.0,
                          paymentMode: controller.paymentMode.value,
                          riderAge: int.tryParse(controller.age.text) ?? 0,
                          parentName: controller.parentName.text,
                          bookingType: controller.selectedBookingType.value,
                          receivedAmount: 0,
                          bookingStatus: controller.bookingStatus.value,
                        );

                        await controller.updateBooking(
                          widget.bookingData!.id,
                          booking,
                        );

                        final attendance = Attendance(
                          id: widget.attendance!.id,
                          bookingId: booking.id.toString(),
                          createdAt: widget.attendance!.createdAt,
                          // clone all completed dates instead of reusing reference
                          completedDates: widget.attendance!.completedDates
                              .map(
                                (d) => CompletedDate(
                                  date: d.date,
                                  duration: d.duration,
                                ),
                              )
                              .toList(),
                          updatedAt: DateTime.now().toIso8601String(),
                          riderName: widget.attendance!.riderName,
                          phoneNumber: widget.attendance!.phoneNumber,
                          programBooked: widget.attendance!.programBooked,
                          sessionDate: widget.attendance!.sessionDate,
                          sessionNumber: widget.attendance!.sessionNumber,
                          totalSessions: widget.attendance!.totalSessions,
                          attendanceStatus: widget.attendance!.attendanceStatus,
                          sessionDuration: widget.attendance!.sessionDuration,
                          sessionCompletion: "Completed",
                          sessionsCompleted:
                              widget.attendance!.sessionsCompleted,
                          fullDaysDone: widget.attendance!.fullDaysDone,
                          halfDaysDone: widget.attendance!.halfDaysDone,
                          sessionsRemaining:
                              widget.attendance!.sessionsRemaining,
                        );

                        if (widget.attendance != null &&
                            widget.bookingData != null) {
                          await controller.updateAttendance(
                            widget.attendance!.id,
                            attendance,
                          );
                        }
                      }
                    }
                  },
                ),
              ),

              Visibility(
                visible: widget.from == "lead",
                child: Center(
                  child: Obx(
                    () => ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(double.infinity, 56),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        shadowColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>((
                          Set<MaterialState> states,
                        ) {
                          return Colors.blue[800]!.withOpacity(0.1);
                        }),
                      ),
                      onPressed: controller.loadSubmit.value
                          ? null // Disable button when loading
                          : () async {
                              if (validateData()) {
                                if ((_formKey.currentState != null &&
                                    _formKey.currentState!.validate())) {
                                  // Create booking data and submit
                                  printData(controller.plannedData);
                                  final booking = Booking(
                                    id: "",
                                    accomdation:
                                        controller.accomdation.value == true
                                        ? "yes"
                                        : "no",
                                    plannedDate: controller.plannedData,
                                    paymentProof: [
                                      controller.paymentProof.value,
                                    ],
                                    timestamp: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    riderName: controller.riderName.text,
                                    medicalCondition:
                                        controller.medicalCondition.text,
                                    phone: controller.phone.text,
                                    programBooked:
                                        controller.selectedProgram.value.title!,
                                    programDetails:
                                        controller.programDetails.text,
                                    bookingDate: controller.bookingDate.text,
                                    preferredSessionDate:
                                        controller.preferredSessionDate.text,
                                    trainingSlot: controller.trainingSlot.value,
                                    sessionType: controller.sessionType.value,
                                    headSize: controller.headSize.text,
                                    pantSize: controller.pantSize.text,
                                    shirtSize: controller.shirtSize.text,
                                    height: controller.height.text,
                                    weight: controller.weight.text,
                                    bikeRental: controller.bikeRental.value
                                        ? "Yes"
                                        : "No",
                                    gearRental: controller.gearRental.value
                                        ? "Yes"
                                        : "No",
                                    totalFee:
                                        double.tryParse(
                                          controller.totalFee.text,
                                        ) ??
                                        0.0,
                                    paymentStatus:
                                        controller.paymentStatus.value,
                                    amountPaid:
                                        double.tryParse(
                                          controller.amtPaid.text,
                                        ) ??
                                        0.0,
                                    paymentMode: controller.paymentMode.value,
                                    riderAge:
                                        int.tryParse(controller.age.text) ?? 0,
                                    parentName: controller.parentName.text,
                                    bookingType:
                                        controller.selectedBookingType.value,
                                    receivedAmount: 0,
                                    bookingStatus:
                                        controller.bookingStatus.value,
                                  );

                                  final attendance = Attendance(
                                    id: "",
                                    //trainingStarted: false,
                                    bookingId: booking.id.toString(),
                                    createdAt: "",
                                    completedDates: [],
                                    updatedAt: "",
                                    riderName: controller.riderName.text,
                                    phoneNumber: controller.phone.text,
                                    programBooked:
                                        controller.selectedProgram.value.name,
                                    sessionDate: '',
                                    sessionNumber: 0,
                                    totalSessions: 0,
                                    attendanceStatus: "Absent",
                                    sessionDuration: "Full Day",
                                    sessionCompletion: "Not Started",
                                    sessionsCompleted: 0,
                                    fullDaysDone: 0,
                                    halfDaysDone: 0,
                                    sessionsRemaining: 0,
                                  );

                                  if (widget.enquirydata != null) {
                                    await controller.submitBookingAndAttendance(
                                      booking,
                                      attendance,
                                      widget.enquirydata!.id,
                                    );
                                  } else {
                                    print("test");
                                  }
                                }
                              }
                            },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[700]!, Colors.blue[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 56),
                          alignment: Alignment.center,
                          child: controller.loadSubmit.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Please wait...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.rocket_launch,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Launch Booking',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboard = TextInputType.text,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }

          // Special validation for age field
          if (label == "Rider Age" && value != null && value.isNotEmpty) {
            // Check if it's a valid number
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }

            // Check age requirement
            final age = int.parse(value);
            if (age < 5 || age > 80) {
              return 'Age must be between 5 and 80';
            }
          }

          return null;
        },
      ),
    );
  }

  Widget _buildProgramSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Select Program *",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: controller.programs
                  .map(
                    (program) => RadioListTile<TrainingProgram>(
                      title: Text(program.title ?? ""),
                      value: program,
                      groupValue: controller.selectedProgram.value,
                      onChanged: (val) {
                        if (val != null) {
                          controller.setSelectedProgram(val);

                          printData(val.toJson());
                        }
                      },
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    TextEditingController ctrl,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onTap: () => controller.pickDate(context, ctrl),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, RxString selected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          // ✅ Only set value if it's in the items list
          value: items.contains(selected.value) && selected.value.isNotEmpty
              ? selected.value
              : null,
          items: items
              .toSet() // ✅ Remove duplicates, just in case
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => selected.value = val ?? '',
        ),
      ),
    );
  }

  Widget _buildRentalOptions() {
    return Obx(
      () => Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text("Bike Rental"),
                  value: controller.bikeRental.value,
                  onChanged: (val) => controller.bikeRental.value = val!,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                CheckboxListTile(
                  title: Text("Gear Rental"),
                  value: controller.gearRental.value,
                  onChanged: (val) => controller.gearRental.value = val!,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                CheckboxListTile(
                  title: Text("Accomdation"),
                  value: controller.accomdation.value,
                  onChanged: (val) => controller.accomdation.value = val!,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
