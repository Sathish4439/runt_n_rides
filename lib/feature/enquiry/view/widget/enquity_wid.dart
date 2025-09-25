import 'dart:io';

import 'package:RUTSNRIDES/core/theme/app_theme.dart';
import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';

import 'package:RUTSNRIDES/feature/enquiry/controller/enquiry_controller.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/lead_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/view/confrim_booking_page.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildLeadsForSelectedDay(Map<DateTime, List<Lead>> events) {
  var controller = Get.find<EnquiryController>();
  final dayLeads =
      events[DateTime(
        controller.selectedDay!.year,
        controller.selectedDay!.month,
        controller.selectedDay!.day,
      )] ??
      [];

  if (dayLeads.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No leads on ${DateFormat('MMM dd, yyyy').format(controller.selectedDay!)}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    itemCount: dayLeads.length,
    itemBuilder: (context, index) {
      final lead = dayLeads[index];
      return buildLeadCard(lead, context);
    },
  );
}

Widget buildAllLeadsList(
  Map<DateTime, List<Lead>> events,
  Function(Lead) onDelete,
) {
  final allLeads = events.values.expand((leads) => leads).toList();

  return ListView.builder(
    itemCount: allLeads.length,
    itemBuilder: (context, index) {
      final lead = allLeads[index];
      return buildLeadCard(lead, context);
    },
  );
}

Widget buildLeadCard(Lead lead, BuildContext context) {
  var controller = Get.find<EnquiryController>();


  printData("lead.status ${lead.status}");
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    color: lead.status.toLowerCase() == "booked"
        ? Colors.green.shade50
        : lead.status.toLowerCase() == "follow up"
        ? Colors.orange.shade50
        : lead.status.toLowerCase() == "new"
        ? Colors.red.shade50
        : Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Avatar
              CircleAvatar(
                backgroundColor: _getStatusColor(lead.status),
                child: Icon(
                  getStatusIcon(lead.status),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Middle: Name, WhatsApp, Program
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        makePhoneCall(lead.whatsapp);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.call, size: 14),
                          SizedBox(width: 10),
                          Text(
                            "${lead.whatsapp} (${lead.contactAvailability})",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.note_outlined, size: 14),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            lead.programInterest,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Age : " + lead.age.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Visibility(
                      visible: lead.followUpNotes.isNotEmpty,
                      child: Row(
                        children: [
                          Icon(Icons.remember_me_outlined, size: 14),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              maxLines: 20,
                              lead.followUpNotes,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Date + Button
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd').format(parseDate(lead.followUpDate)),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lead.status,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          Visibility(
            visible: lead.status.toLowerCase() != "booked",
            child: Column(
              children: [
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonButton(
                      text: lead.status.toLowerCase() == "booked"
                          ? "Booked"
                          : "Book",
                      color: lead.status.toLowerCase() == "booked"
                          ? AppTheme.bookingSecondary
                          : lead.status.toLowerCase() == "follow up"
                          ? AppTheme.followUpSecondary
                          : AppTheme.enquirySecondary,
                      onTap: () async {
                        Get.to(
                          () => ConfirmBookingPage(
                            enquirydata: lead,
                            from: "lead",
                          ),
                        );
                      },
                    ),

                    CommonButton(
                      isLoading: controller.followUpLoading.value,
                      text: "Follow Up",

                      color: lead.status.toLowerCase() == "booked"
                          ? AppTheme.bookingSecondary
                          : lead.status.toLowerCase() == "follow up"
                          ? AppTheme.followUpSecondary
                          : AppTheme.enquirySecondary,

                      onTap: () {
                        showFollowUpBottomSheet(
                          context: context,
                          onConfirm: (pickedDate, note) async {
                            await controller.updateFollowUp(
                              lead.id,
                              note,
                              pickedDate,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class MultiDatePickerWidget extends StatelessWidget {
  final controller = Get.put(EnquiryController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Picker Button with improved styling
        SizedBox(
          child: ElevatedButton.icon(
            icon: Icon(Icons.calendar_today, size: 20),
            label: Text(
              "SELECT DATE & SLOT",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[700],
              elevation: 1,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              DateTime selectedDate = DateTime.now();
              String? selectedSlot;

              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.date_range, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text(
                          "Select Date & Slot",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    content: Obx(() {
                      final program = controller.selectedProgram.value;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date Picker Section
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selected Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                InkWell(
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: ctx,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.blue[700]!,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      selectedDate = picked;
                                      // Force UI update
                                      (ctx as Element).markNeedsBuild();
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Colors.blue[700],
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        DateFormat(
                                          "MMM dd, yyyy",
                                        ).format(selectedDate),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "Change",
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Slot Dropdown with improved styling
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Time Slot",
                                labelStyle: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                prefixIcon: Icon(
                                  Icons.access_time,
                                  color: Colors.blue[700],
                                ),
                              ),
                              value: selectedSlot,
                              items:
                                  [
                                    "Morning (9AM–12PM)",
                                    "Afternoon (2PM–5PM)",
                                    "Full Day",
                                  ].map((slot) {
                                    return DropdownMenuItem<String>(
                                      value: slot,
                                      child: Text(
                                        slot,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                selectedSlot = val;
                              },
                              style: TextStyle(fontSize: 14),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          if (program.durations.isEmpty) ...[
                            SizedBox(height: 12),
                            Text(
                              "No slots available",
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                    actions: [
                      TextButton(
                        child: Text(
                          "CANCEL",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      ElevatedButton(
                        child: Text("CONFIRM"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                        ),
                        onPressed: () {
                          if (selectedSlot != null &&
                              selectedSlot!.isNotEmpty) {
                            Navigator.pop(ctx, {
                              "date": selectedDate,
                              "slot": selectedSlot,
                            });
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text("Please select a time slot"),
                                backgroundColor: Colors.orange[700],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );

              if (result != null) {
                controller.addDateWithSlot(result["date"], result["slot"]);
              }
            },
          ),
        ),

        const SizedBox(height: 16),

        // Selected Dates Display with improved styling
        Obx(
          () => controller.plannedData.isEmpty
              ? Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[500],
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "No dates selected yet",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Dates:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.plannedData.map((d) {
                        final formatted = DateFormat(
                          "MMM dd, yyyy",
                        ).format(DateTime.parse(d.date));
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.blue[700],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "$formatted - ${d.duration}",
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.removeDate(
                                      DateTime.parse(d.date),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.blue[700],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

void showFollowUpBottomSheet({
  required BuildContext context,
  required Function(DateTime selectedDate, String note) onConfirm,
}) {
  final TextEditingController notesController = TextEditingController();
  final ValueNotifier<DateTime?> selectedDateNotifier = ValueNotifier(null);

  Get.bottomSheet(
    Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Follow Up",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Date Picker Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<DateTime?>(
                  valueListenable: selectedDateNotifier,
                  builder: (context, selectedDate, _) {
                    return Text(
                      selectedDate == null
                          ? "No date chosen"
                          : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: TextStyle(fontSize: 16),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      selectedDateNotifier.value = picked; // ✅ updates UI
                      print("picked $picked");
                    }
                  },
                  child: Text("Pick Date"),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Notes Input
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    final selectedDate = selectedDateNotifier.value;
                    if (selectedDate == null || notesController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please pick a date and enter notes"),
                        ),
                      );
                      return;
                    }
                    onConfirm(selectedDate, notesController.text);
                    Get.back();
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true, // ✅ makes sheet expand fully if needed
  );
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'new':
      return Colors.blue;
    case 'follow up':
      return Colors.orange;
    case 'converted':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'new':
      return Icons.new_releases;
    case 'follow up':
      return Icons.update;
    case 'converted':
      return Icons.check_circle;
    case 'rejected':
      return Icons.cancel;
    default:
      return Icons.person;
  }
}

DateTime parseDate(dynamic dateValue) {
  if (dateValue == null) return DateTime.now();

  try {
    if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String && dateValue.trim().isNotEmpty) {
      // Try parsing with different formats
      try {
        return DateFormat("M/d/yyyy H:mm").parse(dateValue);
      } catch (_) {
        try {
          return DateFormat("M/d/yyyy").parse(dateValue);
        } catch (_) {
          try {
            return DateFormat("yyyy-MM-dd").parse(dateValue);
          } catch (_) {
            return DateTime.now();
          }
        }
      }
    }
  } catch (e) {
    print("❌ Date parsing error: $e, value: $dateValue");
  }

  return DateTime.now();
}

void showLeadDetails(Lead lead, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Lead Details'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            buildDetailRow('Name', lead.fullName),
            buildDetailRow('Phone', lead.whatsapp),
            buildDetailRow('Service', lead.programInterest),
            buildDetailRow('Status', lead.status),
            buildDetailRow(
              'Date',
              DateFormat('MMM dd, yyyy').format(parseDate(lead.followUpDate)),
            ),
            buildDetailRow(
              'Time',
              DateFormat('hh:mm a').format(lead.timestampDate),
            ),
            if (lead.followUpNotes.isNotEmpty)
              buildDetailRow('Notes', lead.followUpNotes),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

void showFilterDialog(BuildContext context) {
  // Implement filter functionality
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Filter Leads'),
      content: const Text('Filter options would appear here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void addNewLead(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add New Lead'),
      content: const Text(
        'New leads should be added by filling the Google Form. Do you want to open it?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final Uri url = Uri.parse("https://forms.gle/VwS5BDQd7m1khRh78");

            try {
              final bool launched = await launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              );
              if (!launched) {
                throw Exception("Could not launch $url");
              }
            } catch (e) {
              debugPrint("Error launching URL: $e");
            }

            Navigator.of(context).pop();
          },
          child: const Text('Open Form'),
        ),
      ],
    ),
  );
}

class ImagePickerWidget extends StatelessWidget {
  final EnquiryController controller;

  ImagePickerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Obx(() {
            final proof = controller.paymentProof.value;

            // ✅ No image uploaded → show placeholder
            if (proof.isEmpty) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50),
              );
            } else {
              return Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: Image.network("${EndPoints.fetch}/$proof"),
              );
            }

            // ✅ Image uploaded → fetch it safely
          }),
          const SizedBox(width: 20),
          CommonButton(
            text: "Pick Image",
            onTap: () async {
              try {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );

                if (pickedFile != null) {
                  File file = File(pickedFile.path);
                  await controller.pickAndUpload(file); // ✅ update state safely
                }
              } catch (e, s) {
                debugPrint("❌ Image picking failed: $e\n$s");
              }
            },
          ),
        ],
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Image Viewer"),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3.0,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
