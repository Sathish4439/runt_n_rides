import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/common_wid/widget.dart';
import 'package:rutsnrides_admin/core/services/endpoint.dart';
import 'package:rutsnrides_admin/feature/booking/controller/booking_controller.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';
import 'package:rutsnrides_admin/feature/enquiry/model/lead_model.dart';
import 'package:rutsnrides_admin/feature/enquiry/view/widget/enquity_wid.dart';
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
    id: "",
    timestamp: lead.timestamp, // keep same timestamp
    riderName: lead.fullName,
    phone: lead.whatsapp,
    programBooked: lead.programInterest,
    programDetails: "",
    bookingDate: "",
    height: "",
    weight: "",
    headSize: "",
    pantSize: "",
    shirtSize: "", // can reformat if needed
    preferredSessionDate: "", // if empty → stays empty
    trainingSlot: "",
    sessionType: "",
    bikeRental: lead.bikeRental,
    gearRental: lead.gearRental,
    totalFee: 0.0, // not in Lead → default
    paymentStatus: "",
    amountPaid: 0.0, // not in Lead → default
    paymentMode: '', // not in Lead
    paymentProof: '', // not in Lead
    riderAge: lead.age,
    parentName: '', // not in Lead
    bookingType: "",
    receivedAmount: 0.0, // not in Lead
    bookingStatus: '', // not in Lead
    //trainingStarted: '', // not in Lead
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
    print("✅ Paid Count: $paid");

    final totalRevenue = bookings.fold(0.0, (sum, b) {
      print("💰 Adding Revenue: ${b.receivedAmount} from Booking ID: ${b.id}");
      return sum + b.receivedAmount;
    });
    print("💰 Total Revenue: $totalRevenue");

    final outstanding = bookings.fold(0.0, (sum, b) {
      final due = b.totalFee - b.receivedAmount;
      print(
        "⚠️ Outstanding for Booking ID: ${b.id} = ${b.totalFee} - ${b.receivedAmount} = $due",
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
  final status = booking.bookingStatus.toLowerCase();
  final paymentStatus = booking.paymentStatus.toLowerCase();
  final amountPaid = booking.amountPaid;
  final totalFee = booking.totalFee;

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
  final status = getBookingStatus(booking);
  final outstanding = booking.totalFee - booking.receivedAmount;
  final bookingDate = parseDate(booking.bookingDate);
  final sessionDate = parseDate(booking.preferredSessionDate);

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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.riderName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImagePage(
                              imageUrl:
                                  "${EndPoints.fetch}/${booking.paymentProof}",
                            ),
                          ),
                        );
                      },
                      child: const Text("View Proof"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Visibility(
                visible: booking.bookingStatus.isNotEmpty,
                child: InkWell(
                  onTap: () {},
                  child: Chip(
                    label: Text(
                      booking.bookingStatus.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.green.shade400,
                  ),
                ),
              ),
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
                booking.programDetails,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            const SizedBox(height: 8),
          ],

          // Date and Session Info
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              buildInfoChip(
                Icons.calendar_today,
                controller.dateFormat.format(bookingDate),
              ),
              buildInfoChip(
                Icons.event,
                controller.dateFormat.format(sessionDate),
              ),
              buildInfoChip(Icons.access_time, booking.trainingSlot),
              if (booking.sessionType.isNotEmpty)
                buildInfoChip(Icons.category, booking.sessionType),
            ],
          ),

          const SizedBox(height: 12),

          // Payment Information
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${controller.currencyFormat.format(booking.totalFee)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Paid: ${controller.currencyFormat.format(booking.amountPaid)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Received: ${controller.currencyFormat.format(booking.receivedAmount)}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Due: ${controller.currencyFormat.format(outstanding)}',
                        style: TextStyle(
                          color: outstanding > 0
                              ? Colors.red[700]
                              : Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (booking.paymentStatus.isNotEmpty)
                Text(
                  'Payment Status: ${booking.paymentStatus}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          if (outstanding > 0 && status != 'PAID')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    addPaymentToBooking(booking, context, controller),
                child: const Text('Add Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Rental Information
          if (booking.bikeRental.isNotEmpty || booking.gearRental.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Rental Information:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bike: ${booking.bikeRental}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      'Gear: ${booking.gearRental}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
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
            'Amount Paid: ${controller.currencyFormat.format(booking.receivedAmount)}',
          ),
          Text(
            'Outstanding: ${controller.currencyFormat.format(booking.totalFee - booking.receivedAmount)}',
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
