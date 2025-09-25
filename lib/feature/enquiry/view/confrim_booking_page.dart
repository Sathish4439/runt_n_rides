import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/program_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/controller/enquiry_controller.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/lead_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/view/widget/enquity_wid.dart';
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
  void dispose() {
    super.dispose();
    controller.clearBookingForm();
  }

  @override
  void initState() {
    super.initState(); // ✅ always call super first

    try {
      // reset submit state

      // handle enquiry or booking data
      if (widget.enquirydata != null) {
        controller.setEnquiryData(widget.enquirydata!);
      } else if (widget.bookingData != null) {
        controller.setBookingData(widget.bookingData!);

        printData(controller.courseFee.text);
        printData(controller.bikerental.text);
        printData(controller.gearrental.text);
        printData(controller.accomodation.text);
        printData(controller.totalFee.text);
        printData(controller.amtPaid.text);
        printData(controller.paymentStatus.value);
      }
    } catch (e, s) {
      debugPrint("❌ initState error: $e\n$s");
    }
  }

  bool validateData() {
    var age = int.tryParse(controller.age.text.trim()) ?? 0;
    var totalFee = double.tryParse(controller.totalFee.text.trim()) ?? 0.0;

    // Common fee validations
    if (totalFee == 0.0) {
      showError("Total fee is required");
      return false;
    }

    // ✅ Extra required fields if age <= 12
    if (age <= 12) {
      if (controller.parentName.text.trim().isEmpty) {
        showError("Parent's name is required for students under 12");
        return false;
      }
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
              _buildTextField(
                "Additional Phone",
                controller.addPhone,
                keyboard: TextInputType.phone,
              ),
              _buildTextField(
                "Email",
                controller.email,
                keyboard: TextInputType.emailAddress,
              ),

              SizedBox(height: 24),

              // Program Selection Section
              _buildSectionHeader("Program Details"),

              _buildProgramSelection(),
              _buildTextField(
                "Program Details",
                controller.programDetails,
                maxLines: 4,
              ),

              SizedBox(height: 24),

              // Date & Time Section
              _buildSectionHeader("Schedule"),
              _buildTextField(
                "Enquiry Date",
                controller.enquiryDate,
                maxLines: 1,
                readOnly: true,
              ),
              _buildDatePicker("Booking Date", controller.bookingDate, context),

              Obx(() {
                final program = controller.selectedProgram.value;
                return _buildDropdown(
                  "Training Slot",
                  program.durations,
                  controller.trainingSlot,
                );
              }),
              _buildSectionHeader("Planned Dates"),
              MultiDatePickerWidget(),

              Obx(
                () => _buildDropdown(
                  "Session Type",
                  controller.selectedProgram.value.sessionTypes,
                  controller.sessionType,
                ),
              ),

              //  SizedBox(height: 24),

              // Rental Options Section
              _buildSectionHeader("Rental Options"),
              _buildRentalOptions(),
              SizedBox(height: 24),

              // Rental Options Section
              SizedBox(height: 24),

              // Payment Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("Payment Information"),
                  Visibility(
                    visible: widget.bookingData?.payment.isNotEmpty ?? false,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            // Check each field individually and collect empty fields

                            PaymentDetails payment = PaymentDetails(
                              receivedAmount:
                                  double.tryParse(
                                    controller.amtPaid.text.trim(),
                                  ) ??
                                  0.0,
                              paymentStatus: controller.paymentStatus.value,
                              paymentMode: controller.paymentMode.value,
                              paymentProof: controller.paymentProof.value,
                            );

                            if (widget.bookingData != null) {
                              await controller.updatePaymentDetails(
                                widget.bookingData!.id,
                                payment,
                              );
                              Get.back();
                            }
                          },

                          icon: Icon(Icons.done),
                        ),
                        IconButton(
                          onPressed: () {
                            final payments = widget.bookingData?.payment ?? [];

                            Get.bottomSheet(
                              PaymentHistoryBottomSheet(
                                payments: payments,
                                formatDate: (date) =>
                                    "${date.day}-${date.month}-${date.year}",
                                fetchUrl: EndPoints.fetch,
                              ),
                            );
                          },
                          icon: Icon(Icons.history),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  _buildTextField(
                    "Course fee",

                    controller.courseFee,
                    keyboard: TextInputType.number,
                    onEditingComplete: () {
                      controller.totalFee.text =
                          ((double.tryParse(controller.courseFee.text) ?? 0.0) +
                                  (double.tryParse(
                                            controller.bikerental.text,
                                          ) ??
                                          0.0) *
                                      2500 +
                                  (double.tryParse(
                                            controller.gearrental.text,
                                          ) ??
                                          0.0) *
                                      1000 +
                                  (double.tryParse(
                                            controller.accomodation.text,
                                          ) ??
                                          0.0) *
                                      700)
                              .toStringAsFixed(2);
                    },
                  ),
                  Obx(
                    () => Visibility(
                      visible: controller.bikeRental.value || controller.gearRental.value || controller.accomdation.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("Rental"), Text("Days")],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  Obx(
                    () => Visibility(
                      visible: controller.bikeRental.value,
                      child: _buildTextField(
                        "Bike rental  (₹ 2500)",
                        controller.bikerental,
                        keyboard: TextInputType.number,
                        isBooking: true,
                        onEditingComplete: () {
                          // Calculate bike rental total (quantity * 2500)
                          final bikeQuantity =
                              double.tryParse(controller.bikerental.text) ??
                              0.0;
                          final bikeTotal = bikeQuantity * 2500;

                          controller.totalFee.text =
                              ((double.tryParse(controller.courseFee.text) ??
                                          0.0) +
                                      bikeTotal +
                                      (double.tryParse(
                                                controller.gearrental.text,
                                              ) ??
                                              0.0) *
                                          1000 +
                                      (double.tryParse(
                                                controller.accomodation.text,
                                              ) ??
                                              0.0) *
                                          700)
                                  .toStringAsFixed(2);
                        },
                      ),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: controller.gearRental.value,
                      child: _buildTextField(
                        "Gear rental  (₹ 1000)",
                        controller.gearrental,
                        keyboard: TextInputType.number,
                        isBooking: true,
                        onEditingComplete: () {
                          // Calculate gear rental total (quantity * 1000)
                          final gearQuantity =
                              double.tryParse(controller.gearrental.text) ??
                              0.0;
                          final gearTotal = gearQuantity * 1000;

                          controller.totalFee.text =
                              ((double.tryParse(controller.courseFee.text) ??
                                          0.0) +
                                      (double.tryParse(
                                                controller.bikerental.text,
                                              ) ??
                                              0.0) *
                                          2500 +
                                      gearTotal +
                                      (double.tryParse(
                                                controller.accomodation.text,
                                              ) ??
                                              0.0) *
                                          700)
                                  .toStringAsFixed(2);
                        },
                      ),
                    ),
                  ),

                  Obx(
                    () => Visibility(
                      visible: controller.accomdation.value,
                      child: _buildTextField(
                        "Accomodation  (₹ 700)",
                        controller.accomodation,
                        keyboard: TextInputType.number,
                        isBooking: true,
                        onEditingComplete: () {
                          // Calculate accommodation total (quantity * 700)
                          final accommodationQuantity =
                              double.tryParse(controller.accomodation.text) ??
                              0.0;
                          final accommodationTotal =
                              accommodationQuantity * 700;

                          controller.totalFee.text =
                              ((double.tryParse(controller.courseFee.text) ??
                                          0.0) +
                                      (double.tryParse(
                                                controller.bikerental.text,
                                              ) ??
                                              0.0) *
                                          2500 +
                                      (double.tryParse(
                                                controller.gearrental.text,
                                              ) ??
                                              0.0) *
                                          1000 +
                                      accommodationTotal)
                                  .toStringAsFixed(2);
                        },
                      ),
                    ),
                  ),

                  _buildTextField(
                    "Total Fee (₹)",
                    controller.totalFee,

                    keyboard: TextInputType.number,
                    isRequired: true,
                    readOnly: widget.attendance != null ? true : false,
                  ),
                  _buildTextField(
                    widget.bookingData != null
                        ? "Entered Amount (₹)"
                        : "Advance Paid Amount (₹)",

                    controller.amtPaid,
                    keyboard: TextInputType.number,
                  
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
                  Obx(
                    () => Visibility(
                      visible: controller.paymentStatus.value != "Pending",
                      child: Column(
                        children: [
                          _buildDropdown(
                            "Payment Mode",
                            controller.paymentMethod,
                            controller.paymentMode,
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.paymentMode.value != "Cash",
                              child: Column(
                                children: [
                                  ImagePickerWidget(controller: controller),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              _buildDropdown(
                "Booking Type",
                controller.bookingType,
                controller.selectedBookingType,
              ),

              _buildSectionHeader("Customer details"),

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
              _buildTextField("Instagram Profile", controller.instagramProfile),
              _buildSectionHeader("Medical Condition"),
              _buildTextField("", controller.medicalCondition, maxLines: 4),

              Visibility(
                visible: widget.from == "booking",
                child: Obx(
                  () => CommonButton(
                    isLoading: controller.isLoading.value,
                    text: "Update Booking Data",
                    onTap: () async {
                      await _updateBookingData();
                    },
                  ),
                ),
              ),

              Visibility(
                visible: widget.from == "attendance",
                child: Obx(
                  () => CommonButton(
                    isLoading: controller.isLoading.value,
                    text: "Complete Booking",
                    onTap: () async {
                      await _completeBookingWithAttendance();
                    },
                  ),
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
                          return Colors.blue[800]?.withOpacity(0.1) ??
                              Colors.blue.withOpacity(0.1);
                        }),
                      ),
                      onPressed: controller.loadSubmit.value
                          ? null // Disable button when loading
                          : () async {
                              if (validateData()) {
                                if ((_formKey.currentState != null &&
                                    _formKey.currentState!.validate())) {
                                  // Create booking data and submit
                                  final booking = Booking(
                                    instagramProfile:
                                        controller.instagramProfile.text,
                                    courseFee: controller.courseFee.text,
                                    bikeRentalPrice: controller.bikerental.text,
                                    gearRentalPrice: controller.gearrental.text,
                                    accomdationPrice:
                                        controller.accomodation.text,
                                    enquiryDate: controller.enquiryDate.text,
                                    email: controller.email.text,
                                    additionalPhone: controller.addPhone.text,
                                    id: "",
                                    accomdation:
                                        controller.accomdation.value == true
                                        ? "yes"
                                        : "no",
                                    payment: [
                                      PaymentDetails(
                                        receivedAmount:
                                            double.tryParse(
                                              controller.amtPaid.text,
                                            ) ??
                                            0.0,
                                        paymentStatus:
                                            controller.paymentStatus.value,
                                        paymentMode:
                                            controller.paymentMode.value,
                                        paymentProof:
                                            controller.paymentProof.value,
                                      ),
                                    ],
                                    plannedDate: controller.plannedData,

                                    timestamp: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    riderName: controller.riderName.text,
                                    medicalCondition:
                                        controller.medicalCondition.text,
                                    phone: controller.phone.text,
                                    programBooked:
                                        controller
                                            .selectedProgram
                                            .value
                                            .title ??
                                        "",
                                    programDetails:
                                        controller.programDetails.text,
                                    bookingDate: controller.bookingDate.text,

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

                                    totalPaid:
                                        double.tryParse(
                                          controller.amtPaid.text,
                                        ) ??
                                        0.0,

                                    riderAge:
                                        int.tryParse(controller.age.text) ?? 0,
                                    parentName: controller.parentName.text,
                                    bookingType:
                                        controller.selectedBookingType.value,

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
                                    printData(widget.enquirydata!.id);
                                    await controller.submitBookingAndAttendance(
                                      booking,
                                      attendance,
                                      widget.enquirydata!.id,
                                    );

                                    // if (context.mounted) {
                                    //   Navigator.pop(context);
                                    // }
                                  } else {}
                                }
                              }
                            },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue[700] ?? Colors.blue,
                              Colors.blue[500] ?? Colors.blue,
                            ],
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
    bool readOnly = false,
    bool isBooking = false,
    String? hintText,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    // Determine if the field is a phone field
    final isPhoneField = label.toLowerCase().contains("phone");

    final textFormField = TextFormField(
      controller: ctrl,
      readOnly: readOnly,
    
      keyboardType: isPhoneField ? TextInputType.phone : keyboard,
      maxLines: maxLines,
      textAlign: isBooking ? TextAlign.center : TextAlign.start,
      inputFormatters: isPhoneField
          ? [
              FilteringTextInputFormatter.digitsOnly, // Only digits
              LengthLimitingTextInputFormatter(10), // Max 10 digits
            ]
          : [],
      decoration: InputDecoration(
        labelText: isBooking
            ? null
            : '$label${isRequired ? ' *' : ''}', // hide label if booking
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }

        // Age validation
        if (label == "Rider Age" && value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }

          final age = int.parse(value);
          if (age < 5 || age > 80) {
            return 'Age must be between 5 and 80';
          }
        }

        // Phone validation
        if (isPhoneField && value != null && value.isNotEmpty) {
          if (value.length != 10) {
            return 'Phone number must be 10 digits';
          }
        }

        return null;
      },
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isBooking
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$label${isRequired ? ' *' : ''}",
                  style: const TextStyle(fontSize: 16),
                ),

                SizedBox(height: 50, width: 60, child: textFormField),
              ],
            )
          : textFormField,
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
              border: Border.all(color: Colors.grey[300] ?? Colors.grey),
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
              border: Border.all(color: Colors.grey[300] ?? Colors.grey),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text("Bike Rental"),
                  value: controller.bikeRental.value,
                  onChanged: (val) =>
                      controller.bikeRental.value = val ?? false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                CheckboxListTile(
                  title: Text("Gear Rental"),
                  value: controller.gearRental.value,
                  onChanged: (val) =>
                      controller.gearRental.value = val ?? false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                CheckboxListTile(
                  title: Text("Accomdation"),
                  value: controller.accomdation.value,
                  onChanged: (val) =>
                      controller.accomdation.value = val ?? false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Update booking data - handles booking update with proper validation and loading
  Future<void> _updateBookingData() async {
    printData(
      "controller.instagramProfile.text ${controller.instagramProfile.text}",
    );
    try {
      // Validate form data first
      if (!validateData()) {
        showError("Please fill all required fields");
        return;
      }

      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        showError("Please correct the form errors");
        return;
      }

      if (widget.bookingData == null) {
        showError("Missing booking data");
        return;
      }

      // Set loading state
      controller.isLoading.value = true;

      // Create updated booking with correct ID
      final booking = Booking(
        payment: [
          PaymentDetails(
            receivedAmount: double.tryParse(controller.amtPaid.text) ?? 0.0,
            paymentStatus: controller.paymentStatus.value,
            paymentMode: controller.paymentMode.value,
            paymentProof: controller.paymentProof.value,
          ),
        ],
        id: widget.bookingData!.id, // Use existing booking ID
        accomdation: controller.accomdation.value ? "yes" : "no",
        plannedDate: controller.plannedData,
        courseFee: controller.courseFee.text,
        bikeRentalPrice: controller.bikerental.text,
        gearRentalPrice: controller.gearrental.text,
        accomdationPrice: controller.accomodation.text,
        email: controller.email.text,
        additionalPhone: controller.addPhone.text,
        enquiryDate: controller.enquiryDate.text,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        riderName: controller.riderName.text,
        medicalCondition: controller.medicalCondition.text,
        phone: controller.phone.text,
        programBooked: controller.selectedProgram.value.title ?? "",
        programDetails: controller.programDetails.text,
        bookingDate: controller.bookingDate.text,
        trainingSlot: controller.trainingSlot.value,
        sessionType: controller.sessionType.value,
        headSize: controller.headSize.text,
        pantSize: controller.pantSize.text,
        shirtSize: controller.shirtSize.text,
        height: controller.height.text,
        instagramProfile: controller.instagramProfile.text,
        weight: controller.weight.text,
        bikeRental: controller.bikeRental.value ? "Yes" : "No",
        gearRental: controller.gearRental.value ? "Yes" : "No",
        totalFee: double.tryParse(controller.totalFee.text) ?? 0.0,
        totalPaid: double.tryParse(controller.amtPaid.text) ?? 0.0,
        riderAge: int.tryParse(controller.age.text) ?? 0,
        parentName: controller.parentName.text,
        bookingType: controller.selectedBookingType.value,
        bookingStatus: controller.bookingStatus.value,
        isloading: false,
      );

      // Update booking
      await controller.updateBooking(widget.bookingData!.id, booking);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      printData("Error updating booking: $e");
      showError("Failed to update booking: ${e.toString()}");
    } finally {
      // Clear loading state
      controller.isLoading.value = false;
    }
  }

  /// Complete booking with attendance - handles the entire flow properly
  Future<void> _completeBookingWithAttendance() async {
    try {
      // Validate form data first
      if (!validateData()) {
        showError("Please fill all required fields");
        return;
      }

      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        showError("Please correct the form errors");
        return;
      }

      if (widget.attendance == null || widget.bookingData == null) {
        showError("Missing attendance or booking data");
        return;
      }

      // Set loading state
      controller.isLoading.value = true;

      // Create updated booking with correct ID
      final booking = Booking(
        courseFee: controller.courseFee.text,
        bikeRentalPrice: controller.bikerental.text,
        gearRentalPrice: controller.gearrental.text,
        accomdationPrice: controller.accomodation.text,
        email: controller.email.text,
        additionalPhone: controller.addPhone.text,
        enquiryDate: controller.enquiryDate.text,
        id: widget.bookingData!.id, // Use existing booking ID
        accomdation: controller.accomdation.value ? "yes" : "no",
        plannedDate: controller.plannedData,
        payment: [
          PaymentDetails(
            receivedAmount: double.tryParse(controller.amtPaid.text) ?? 0.0,
            paymentStatus: controller.paymentStatus.value,
            paymentMode: controller.paymentMode.value,
            paymentProof: controller.paymentProof.value,
          ),
        ],
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        riderName: controller.riderName.text,
        medicalCondition: controller.medicalCondition.text,
        phone: controller.phone.text,
        programBooked: controller.selectedProgram.value.title ?? "",
        programDetails: controller.programDetails.text,
        bookingDate: controller.bookingDate.text,
        trainingSlot: controller.trainingSlot.value,
        sessionType: controller.sessionType.value,
        headSize: controller.headSize.text,
        pantSize: controller.pantSize.text,
        shirtSize: controller.shirtSize.text,
        height: controller.height.text,
        instagramProfile: controller.instagramProfile.text,
        weight: controller.weight.text,
        bikeRental: controller.bikeRental.value ? "Yes" : "No",
        gearRental: controller.gearRental.value ? "Yes" : "No",
        totalFee: double.tryParse(controller.totalFee.text) ?? 0.0,
        totalPaid: double.tryParse(controller.amtPaid.text) ?? 0.0,
        riderAge: int.tryParse(controller.age.text) ?? 0,
        parentName: controller.parentName.text,
        bookingType: controller.selectedBookingType.value,
        bookingStatus: "Completed", // Mark as completed
        isloading: false,
      );

      printData("Updating booking: ${booking.toJson()}");

      // Update booking first
      await controller.updateBooking(widget.bookingData!.id, booking);

      // Create updated attendance with correct booking ID
      final attendance = Attendance(
        id: widget.attendance!.id,
        bookingId: widget.bookingData!.id ?? "", // Use existing booking ID
        createdAt: widget.attendance!.createdAt,
        completedDates: widget.attendance!.completedDates
            .map((d) => CompletedDate(date: d.date, duration: d.duration))
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
        sessionsCompleted: widget.attendance!.sessionsCompleted,
        fullDaysDone: widget.attendance!.fullDaysDone,
        halfDaysDone: widget.attendance!.halfDaysDone,
        sessionsRemaining: widget.attendance!.sessionsRemaining,
      );

      printData("Updating attendance: ${attendance.toJson()}");

      // Update attendance
      await controller.updateAttendance(widget.attendance!.id, attendance);

      // Show success message

      // Navigate back
      Get.back();
    } catch (e) {
      printData("Error completing booking: $e");
      showError("Failed to complete booking: ${e.toString()}");
    } finally {
      // Clear loading state
      controller.isLoading.value = false;
    }
  }
}
