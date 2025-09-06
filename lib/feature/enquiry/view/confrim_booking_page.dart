import 'dart:ffi' hide Size;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';
import 'package:rutsnrides_admin/feature/enquiry/controller/enquiry_controller.dart';
import 'package:rutsnrides_admin/feature/enquiry/model/lead_model.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';

class ConfirmBookingPage extends StatefulWidget {
  final Lead enquirydata;

  const ConfirmBookingPage({super.key, required this.enquirydata});
  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final EnquiryController controller = Get.find<EnquiryController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    controller.setEnquiryData(widget.enquirydata);
    super.initState();
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
                isRequired: true,
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
              _buildTextField(
                "Program Details",
                controller.programDetails,
                maxLines: 3,
              ),

              SizedBox(height: 24),

              // Date & Time Section
              _buildSectionHeader("Schedule"),
              _buildDatePicker("Booking Date", controller.bookingDate, context),
              _buildDatePicker(
                "Preferred Session Date",
                controller.preferredSessionDate,
                context,
              ),
              _buildDropdown(
                "Training Slot",
                controller.trainingSlots,
                controller.trainingSlot,
              ),
              _buildDropdown(
                "Session Type",
                controller.sessionTypes,
                controller.sessionType,
              ),

              SizedBox(height: 24),

              // Rental Options Section
              _buildSectionHeader("Rental Options"),
              _buildRentalOptions(),

              SizedBox(height: 24),

              // Payment Section
              _buildSectionHeader("Payment Information"),
              _buildTextField(
                "Total Fee (₹)",
                controller.totalFee,
                keyboard: TextInputType.number,
              ),
              _buildTextField(
                "Paid Amount (₹)",
                controller.amtPaid,
                keyboard: TextInputType.number,
              ),
              _buildTextField(
                "Received Amount  (₹)",
                controller.receivedAmount,
                keyboard: TextInputType.number,
              ),
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

              //  SizedBox(height: 32),
              _buildSectionHeader("Custome details"),
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

              Center(
                child: Obx(
                  () => ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 56),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // Create booking data and submit
                              final booking = Booking(
                                id: "",
                                paymentProof: controller.paymentProof.value,
                                timestamp: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                riderName: controller.riderName.text,
                                phone: controller.phone.text,
                                programBooked: controller.selectedProgram.value,
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
                                    double.tryParse(controller.totalFee.text) ??
                                    0.0,
                                paymentStatus: controller.paymentStatus.value,
                                amountPaid:
                                    double.tryParse(controller.amtPaid.text) ??
                                    0.0,
                                paymentMode: controller.paymentMode.value,
                                riderAge:
                                    int.tryParse(controller.age.text) ?? 0,
                                parentName: controller.parentName.text,
                                bookingType:
                                    controller.selectedBookingType.value,
                                receivedAmount:
                                    double.tryParse(
                                      controller.receivedAmount.text,
                                    ) ??
                                    0.0,
                                bookingStatus: controller.bookingStatus.value,
                                
                              );

                              final attendance = Attendance(
                                id: "",
                                //trainingStarted: false,
                                createdAt: "",
                                updatedAt: "",
                                riderName: controller.riderName.text,
                                phoneNumber: controller.phone.text,
                                programBooked: controller.selectedProgram.value,
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

                              controller.submitBookingAndAttendance(
                                booking,
                                attendance,
                              );
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
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
                    (program) => RadioListTile<String>(
                      title: Text(program),
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
          value: selected.value.isEmpty ? null : selected.value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => selected.value = val ?? '',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an option';
            }
            return null;
          },
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
