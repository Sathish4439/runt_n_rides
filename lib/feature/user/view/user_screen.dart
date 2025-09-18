import 'package:RUTSNRIDES/feature/ongoing/controller/attandance_controller.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';
import 'package:RUTSNRIDES/feature/user/controller/user_controller.dart';
import 'package:RUTSNRIDES/feature/user/view/widget/attendance_card_wid.dart';
import 'package:RUTSNRIDES/feature/user/view/widget/attendence_details_wid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserScreen extends StatefulWidget {
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  var controller = Get.put(UserController());
  var attendanceController = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();

    controller.fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.loadUserData.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.filteredList.isEmpty) {
                return Center(
                  child: Text(
                    controller.searchQuery.isEmpty
                        ? 'No attendance records found'
                        : 'No results found for "${controller.searchQuery}"',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchUserData(),
                child: ListView.builder(
                  itemCount: controller.filteredList.length,
                  itemBuilder: (context, index) {
                    final attendance = controller.filteredList[index];
                    return AttendanceCard(
                      attendance: attendance,
                      onTap: () async {
                        await attendanceController.fetchLapHistory(
                          attendance.id ?? "",
                        );
                        _showAttendanceDetails(attendance);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.fetchUserData(),
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name, phone, or program...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) => controller.filterAttendance(value),
      ),
    );
  }

  void _showAttendanceDetails(Attendance attendance) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => AttendanceDetailSheet(
        attendance: attendance,
        controller: attendanceController,
      ),
    );
  }
}
