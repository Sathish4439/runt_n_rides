import 'package:RUTSNRIDES/core/common_wid/widget.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';
import 'package:RUTSNRIDES/feature/enquiry/view/widget/enquity_wid.dart';
import 'package:RUTSNRIDES/feature/ongoing/controller/attandance_controller.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/lap_model.dart';
import 'package:RUTSNRIDES/feature/ongoing/widget/ongoing_wid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';

class AttendanceDetailSheet extends StatelessWidget {
  final Attendance attendance;
  final AttendanceController controller;

  const AttendanceDetailSheet({
    Key? key,
    required this.attendance,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Attendance Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildDetailRow('Rider Name', attendance.riderName),
          _buildDetailRow('Phone Number', attendance.phoneNumber),
          _buildDetailRow('Program', attendance.programBooked),
          _buildDetailRow('Session Date', attendance.sessionDate),
          _buildDetailRow(
            'Session Number',
            '${attendance.sessionsCompleted}/${attendance.totalSessions}',
          ),
          _buildDetailRow('Status', attendance.sessionCompletion),
          _buildDetailRow(
            'Completion',
            '${attendance.sessionsCompleted} sessions completed',
          ),

          Text('Payment Proof', style: TextStyle(fontWeight: FontWeight.bold)),

          _buildProffWid(attendance.bookingData!.payment),

          if (attendance.completedDates.isNotEmpty) ...[
            const Text(
              'Completed Dates:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ✅ Horizontal scroll
            SizedBox(
              height: 60, // fixed height for horizontal list
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attendance.completedDates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final completed = attendance.completedDates[index];
                  final parsed = DateTime.tryParse(completed.date);
                  final formatted = parsed != null
                      ? formatDate(parsed)
                      : "Invalid date";

                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatted,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Duration: ${completed.duration}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 20),
          //   _buildActionButtons(),
          if (controller.lapsHistory.isNotEmpty) ...[
            const Text(
              'Laps History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // ✅ Horizontal scroll
            SizedBox(
              // fixed height for horizontal list
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: controller.lapsHistory.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final completed = controller.lapsHistory[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date : ${formatDate(completed.createdAt)}'),
                          SizedBox(width: 30),
                          Text('Total Duration : ${completed.totalDuration}'),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: completed.lapTimes.map((lap) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white, // use same color as Chip
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              lap.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 20),
          //   _buildActionButtons(),
        ],
      ),
    );
  }

  String ListToString(List<String> li) {
    var ans = "";

    for (var i in li) {
      ans += i;
      ans += "\n";
    }

    return ans;
  }

  Widget _buildProffWid(List<PaymentDetails> payments) {
    if (payments.isEmpty) {
      return const Text("No payment proofs found");
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = payments[index];
          return GestureDetector(
            onTap: () {
              Get.to(
                () => FullScreenImagePage(
                  imageUrl: "${EndPoints.fetch}/${p.paymentProof}",
                ),
              );
            },
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CommonCachedImage(
                      imageUrl: "${EndPoints.fetch}/${p.paymentProof}",
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₹${p.receivedAmount}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${p.paymentMode} • ${p.paymentStatus}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          p.createAt != null
                              ? formatDate(DateTime.parse(p.createAt!))
                              : "",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus('Present'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Mark Present', style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus('Absent'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Mark Absent', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void _updateStatus(String status) {
    // This would be handled by the controller
    Get.back();
    Get.snackbar('Status Updated', 'Marked as $status');
  }
}
