// attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rutsnrides_admin/feature/ongoing/controller/attandance_controller.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';
import 'package:rutsnrides_admin/feature/ongoing/widget/ongoing_wid.dart';

class AttendanceScreen extends StatefulWidget {
  AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  var controller = Get.put(AttendanceController());

  @override
  void initState() {
    // TODO: implement initState

    controller.fetchAttendance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with Stats
          buildStatsHeader(context, controller),

          // Filter and Search Section
          buildFilterSection(context, controller),

          // Attendance List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredList.isEmpty) {
                return buildEmptyState();
              }

              return buildAttendanceList(context, controller);
            }),
          ),
        ],
      ),
    );
  }
}
