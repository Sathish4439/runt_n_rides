import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rutsnrides_admin/core/common_wid/widget.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/endpoint.dart';

import 'package:rutsnrides_admin/core/utils/utils.dart';
import 'package:rutsnrides_admin/feature/enquiry/controller/enquiry_controller.dart';
import 'package:rutsnrides_admin/feature/enquiry/model/lead_model.dart';
import 'package:rutsnrides_admin/feature/enquiry/view/confrim_booking_page.dart';
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
      return Dismissible(
        key: Key(lead.id.toString()), // make sure each lead has a unique id
        direction: DismissDirection.endToStart, // swipe from right to left
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          // Call your delete function
          onDelete(lead);

          // Optional: show a snackbar
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${lead.fullName} deleted')));
        },
        child: buildLeadCard(lead, context),
      );
    },
  );
}

Widget buildLeadCard(Lead lead, BuildContext context) {
  var controller = Get.find<EnquiryController>();
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    color: Colors.white,
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
                            lead.whatsapp,
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
                    const SizedBox(height: 4),
                    Visibility(
                      visible: lead.followUpNotes.isNotEmpty,
                      child: Row(
                        children: [
                          Icon(Icons.remember_me_outlined, size: 14),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
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
                ],
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonButton(
                text: "Book",
                onTap: () async {
                  print(lead.toJson());
                  Get.to(() => ConfirmBookingPage(enquirydata: lead));
                },
              ),

              CommonButton(
                isLoading: controller.followUpLoading.value,
                text: "Follow Up",

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
  );
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
            if (lead.followUpNotes != null && lead.followUpNotes!.isNotEmpty)
              buildDetailRow('Notes', lead.followUpNotes!),
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
  const formUrl = "https://forms.gle/VwS5BDQd7m1khRh78";

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
  var controller = Get.put(EnquiryController());

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Obx(() {
            if (controller.paymentProof.value.isNotEmpty) {
              return Image.network(
                "${EndPoints.fetch}/${controller.paymentProof.value}",
                height: 200,
              );
            } else {
              return Container(
                height: 100,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 100),
              );
            }
          }),
          SizedBox(width: 20),
          CommonButton(
            text: "Pick Image",
            onTap: () async {
              final pickedFile = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                File file = File(pickedFile.path);
                controller.pickAndUpload(file);
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

  const FullScreenImagePage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Image Viewer"),
      ),
      body: Container(
        color: Colors.black,
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3.0,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
