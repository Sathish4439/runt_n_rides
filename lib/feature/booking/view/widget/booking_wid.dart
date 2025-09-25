import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:RUTSNRIDES/feature/enquiry/view/confrim_booking_page.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:RUTSNRIDES/feature/booking/controller/booking_controller.dart';
import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/model/lead_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/view/widget/enquity_wid.dart';
// import your Booking model

class BookingBottomSheet extends StatelessWidget {
  final Booking booking;

  const BookingBottomSheet({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = booking.toJson();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row with title + close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Booking Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => Get.back(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Scrollable booking details
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: data.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 6,
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Booking bookingFromLead(Lead lead) {
  return Booking(
    additionalPhone: "",
    enquiryDate: "",
    courseFee: "",
    accomdationPrice: "",
    bikeRentalPrice: "",
    gearRentalPrice: "",
    email: "",

    id: "",
    timestamp: lead.timestamp, // keep same timestamp
    riderName: lead.fullName,
    accomdation: lead.accommodation,
    phone: lead.whatsapp,
    programBooked: lead.programInterest,
    programDetails: "",
    plannedDate: [],
    medicalCondition: lead.medicalDetails,
    bookingDate: "",
    height: "",
    weight: "",
    headSize: "",
    pantSize: "",
    shirtSize: "", // can reformat if needed
    // if empty → stays empty
    trainingSlot: "",
    sessionType: "",
    bikeRental: lead.bikeRental,
    gearRental: lead.gearRental,
    totalPaid: 0,
    totalFee: 0.0, // not in Lead → default
    // not in Lead
    riderAge: lead.age,
    parentName: '', // not in Lead
    bookingType: "",
    // not in Lead
    bookingStatus: '', // not in Lead
    payment: [],
    instagramProfile: "",
  );
}

Widget buildFilterSection(BookingController controller) {
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // View Toggle
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: controller.currentView.value == 'ALL',
                    onSelected: (selected) {
                      if (selected) controller.currentView.value = 'ALL';
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: controller.currentView.value == 'PENDING',
                    onSelected: (selected) {
                      if (selected) controller.currentView.value = 'PENDING';
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Confirmed'),
                    selected: controller.currentView.value == 'CONFIRMED',
                    onSelected: (selected) {
                      if (selected) controller.currentView.value = 'CONFIRMED';
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Paid'),
                    selected: controller.currentView.value == 'PAID',
                    onSelected: (selected) {
                      if (selected) controller.currentView.value = 'PAID';
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, phone, or program...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              controller.searchQuery.value = value.toLowerCase();
            },
          ),
        ],
      ),
    ),
  );
}

Widget buildStatsSummary(BookingController controller) {
  return Obx(() {
    final bookings = controller.listofBooking;
    print("🔹 Total Bookings: ${bookings.length}");

    final pending = bookings.where((b) {
      final status = getBookingStatus(b);
      print("➡️ Booking ID: ${b.id}, Status: $status (Checking for PENDING)");
      return status == 'PENDING';
    }).length;
    print("✅ Pending Count: $pending");

    final confirmed = bookings.where((b) {
      final status = getBookingStatus(b);
      print("➡️ Booking ID: ${b.id}, Status: $status (Checking for CONFIRMED)");
      return status == 'CONFIRMED';
    }).length;
    print("✅ Confirmed Count: $confirmed");

    final paid = bookings.where((b) {
      final status = getBookingStatus(b);
      print("➡️ Booking ID: ${b.id}, Status: $status (Checking for PAID)");
      return status == 'PAID';
    }).length;

    final totalRevenue = bookings.fold(0.0, (sum, b) {
      return sum + b.totalFee;
    });

    final outstanding = bookings.fold(0.0, (sum, b) {
      final due = b.totalFee - b.totalPaid;
      print(
        "⚠️ Outstanding for Booking ID: ${b.id} = ${b.totalFee} - ${b.totalPaid} = $due",
      );
      return sum + due;
    });
    print("⚠️ Total Outstanding: $outstanding");

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem('Total', bookings.length.toString(), Colors.blue),
              const SizedBox(width: 16),
              buildStatItem('Pending', pending.toString(), Colors.orange),
              const SizedBox(width: 16),
              buildStatItem('Confirmed', confirmed.toString(), Colors.green),
              const SizedBox(width: 16),
              buildStatItem('Paid', paid.toString(), Colors.purple),
              const SizedBox(width: 16),
              buildStatItem(
                'Revenue',
                controller.currencyFormat.format(totalRevenue),
                Colors.teal,
              ),
              const SizedBox(width: 16),
              buildStatItem(
                'Due',
                controller.currencyFormat.format(outstanding),
                Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  });
}

Widget buildStatItem(String label, String value, Color color) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

// Improved booking status detection
String getBookingStatus(Booking booking) {
  try {
    final status = booking.bookingStatus.toLowerCase();
    final amountPaid = booking.totalPaid;
    final totalFee = booking.totalFee;

    // Safe access to last payment
    final paymentStatus = booking.payment.isNotEmpty
        ? booking.payment.last.paymentStatus.toLowerCase()
        : '';

    if (status.contains('confirm') || status == 'confirmed') {
      return 'CONFIRMED';
    } else if (paymentStatus.contains('paid') || amountPaid >= totalFee) {
      return 'PAID';
    } else if (paymentStatus.contains('partial') || amountPaid > 0) {
      return 'PENDING';
    } else if (paymentStatus.contains('not paid') || amountPaid == 0) {
      return 'PENDING';
    }

    return status.toUpperCase();
  } catch (e) {
    printData(e);
    return 'UNKNOWN';
  }
}

List<Booking> filterAndSortBookings(
  List<Booking> bookings,
  BookingController controller,
) {
  // Filter
  List<Booking> filtered = bookings.where((booking) {
    final status = getBookingStatus(booking);

    // Status filter
    final matchesStatus =
        controller.currentView == 'ALL' ||
        (controller.currentView == 'PENDING' && status == 'PENDING') ||
        (controller.currentView == 'CONFIRMED' && status == 'CONFIRMED') ||
        (controller.currentView == 'PAID' && status == 'PAID');

    // Search filter
    final matchesSearch =
        controller.searchQuery.isEmpty ||
        booking.riderName.toLowerCase().contains(controller.searchQuery) ||
        booking.phone.toLowerCase().contains(controller.searchQuery) ||
        booking.programBooked.toLowerCase().contains(controller.searchQuery) ||
        booking.programDetails.toLowerCase().contains(controller.searchQuery);

    return matchesStatus && matchesSearch;
  }).toList();

  // Sort
  filtered.sort((a, b) {
    switch (controller.sortBy.value) {
      case 'name':
        return a.riderName.compareTo(b.riderName);
      case 'amount':
        return b.totalFee.compareTo(a.totalFee);
      case 'date':
      default:
        final dateA = parseDate(a.bookingDate);
        final dateB = parseDate(b.bookingDate);
        return dateB.compareTo(dateA);
    }
  });

  return filtered;
}

Widget buildBookingCard(
  Booking booking,
  BuildContext context,
  BookingController controller,
) {
  final bookingDate = parseDate(booking.bookingDate);

  return Card(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    booking.riderName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message:
                        'This person completed all sessions but not paid the full amount',
                    child: Icon(
                      Icons.info,
                      color: Colors.orange.shade400,
                      size: 20,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Visibility(
                    visible: booking.bookingStatus == "Completed",
                    child: Icon(Icons.done),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => FullScreenImagePage(
                  //           imageUrl:
                  //               "${EndPoints.fetch}/${booking.payment.last.paymentProof}",
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   icon: Icon(Icons.image),
                  // ),
                  IconButton(
                    onPressed: () {
                      Get.to(
                        ConfirmBookingPage(
                          bookingData: booking,
                          from: "booking",
                        ),
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),

              // Visibility(
              //   visible: booking.bookingStatus.isNotEmpty,
              //   child: InkWell(
              //     onTap: () {},
              //     child: Chip(
              //       label: Text(
              //         booking.bookingStatus.toUpperCase(),
              //         style: const TextStyle(color: Colors.white, fontSize: 12),
              //       ),
              //       backgroundColor: Colors.green.shade400,
              //     ),
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 8),

          // Phone and Age
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(booking.phone, style: TextStyle(color: Colors.grey[700])),
              if (booking.riderAge > 0) ...[
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Age: ${booking.riderAge}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Program and Details
          if (booking.programBooked.isNotEmpty) ...[
            Text(
              booking.programBooked,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (booking.programDetails.isNotEmpty)
              Text(
                "Program Details: " + booking.programDetails,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            const SizedBox(height: 8),
          ],

          // Date and Session Info
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 4,
          //   children: [
          //     buildInfoChip(
          //       Icons.calendar_today,
          //       controller.dateFormat.format(bookingDate),
          //     ),

          //     buildInfoChip(Icons.access_time, booking.trainingSlot),
          //     if (booking.sessionType.isNotEmpty)
          //       buildInfoChip(Icons.category, booking.sessionType),
          //   ],
          // ),

          // const SizedBox(height: 12),

          // Payment Information
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${controller.currencyFormat.format(booking.totalFee)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Paid: ${controller.currencyFormat.format(booking.totalPaid)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     Text(
              //       'Received: ${controller.currencyFormat.format(booking.receivedAmount)}',
              //       style: TextStyle(
              //         color: Colors.red[700],
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     Text(
              //       'Due: ${controller.currencyFormat.format(outstanding)}',
              //       style: TextStyle(
              //         color: outstanding > 0
              //             ? Colors.red[700]
              //             : Colors.green[700],
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 4),
              // if (booking.payment.isNotEmpty)
              //   Text(
              //     'Payment Status: ${booking.payment.last.paymentStatus}',
              //     style: TextStyle(
              //       fontSize: 12,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.red,
              //       fontStyle: FontStyle.italic,
              //     ),
              //   ),
            ],
          ),

          //   const SizedBox(height: 12),

          // Action Buttons
          // if (outstanding > 0 && status != 'PAID')
          //   SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       onPressed: () =>
          //           addPaymentToBooking(booking, context, controller),
          //       child: const Text('Add Payment'),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.green[700],
          //         foregroundColor: Colors.white,
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 8),

          // Rental Information
          if (booking.bikeRental.isNotEmpty || booking.gearRental.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Rental Information:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRentalItem(
                      'Bike Rental',
                      booking.bikeRental,
                      booking.bikeRentalPrice,
                      2500,
                    ),
                    const SizedBox(height: 4),
                    _buildRentalItem(
                      'Gear Rental',
                      booking.gearRental,
                      booking.gearRentalPrice,
                      1000,
                    ),
                    const SizedBox(height: 4),
                    _buildRentalItem(
                      'Accommodation',
                      booking.accomdation,
                      booking.accomdationPrice,
                      700,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Attendance Information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Training Progress:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //  _buildAttendanceInfo(booking.attendanceDetails),
                  ],
                ),
                const SizedBox(height: 10),

                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Visibility(
                      visible:
                          booking.bookingStatus.toLowerCase() != "completed",
                      child: CommonButton(
                        isLoading: controller.isBookingLoading(booking.id!),
                        text: "complete",
                        onTap: () async {
                          await controller.markCompleted(booking.id!);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

Widget buildInfoChip(IconData icon, String text) {
  return Chip(
    label: Text(
      text,
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
    ),
    avatar: Icon(icon, size: 16),
    backgroundColor: Colors.grey[100],
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

void addPayment(BuildContext context) {
  // Implement payment addition logic
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add New Payment'),
      content: const Text('Payment form would appear here'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save payment
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void addPaymentToBooking(
  Booking booking,
  BuildContext context,
  BookingController controller,
) {
  // Implement specific payment addition for a booking
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add Payment for ${booking.riderName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Fee: ${controller.currencyFormat.format(booking.totalFee)}',
          ),
          Text(
            'Amount Paid: ${controller.currencyFormat.format(booking.totalPaid)}',
          ),
          Text(
            'Outstanding: ${controller.currencyFormat.format(booking.totalFee - booking.totalPaid)}',
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Payment Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: 'Payment Mode',
              border: OutlineInputBorder(),
            ),
            items: ['Cash', 'Online', 'Bank Transfer', 'UPI']
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: (value) {},
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Process payment
            Navigator.of(context).pop();
          },
          child: const Text('Process Payment'),
        ),
      ],
    ),
  );
}

void exportData(BookingController controller) {
  // Implement export functionality
  final filteredBookings = filterAndSortBookings(
    controller.listofBooking,
    controller,
  );

  // This would typically export to CSV/Excel
  Get.snackbar(
    'Export Ready',
    '${filteredBookings.length} bookings ready for export',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green[700],
    colorText: Colors.white,
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

double _calculateRemainingAmount(Booking booking) {
  final totalFee = double.tryParse(booking.totalFee.toString()) ?? 0;
  final amtPaid = double.tryParse(booking.totalPaid.toString()) ?? 0;
  return totalFee - amtPaid;
}

Widget _buildProgressItem(String label, String value, Color color) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
    ],
  );
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'partial':
      return Colors.orange;
    case 'not started':
      return Colors.grey;
    default:
      return Colors.blue;
  }
}

Widget _buildRentalItem(
  String title,
  String status,
  String days,
  int pricePerDay,
) {
  final isEnabled = status.toLowerCase() == 'yes';
  final daysCount = double.tryParse(days) ?? 0;
  final totalPrice = daysCount * pricePerDay;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: isEnabled ? Colors.green[50] : Colors.grey[100],
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: isEnabled ? Colors.green[200]! : Colors.grey[300]!,
        width: 1,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: isEnabled ? Colors.green[700] : Colors.grey[600],
                ),
              ),
              if (isEnabled)
                Text(
                  '$days days',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        if (isEnabled)
          Text(
            '₹${totalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.green[700],
            ),
          )
        else
          Text(
            'Not Selected',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    ),
  );
}
