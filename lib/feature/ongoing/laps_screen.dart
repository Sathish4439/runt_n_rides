import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/theme/app_theme.dart';
import 'package:rutsnrides_admin/feature/ongoing/controller/attandance_controller.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';

class LapsScreen extends StatefulWidget {
  final Attendance attendance;
  const LapsScreen({super.key, required this.attendance});

  @override
  State<LapsScreen> createState() => _LapsScreenState();
}

class _LapsScreenState extends State<LapsScreen> {
  final controller = Get.put(AttendanceController());

  @override
  void initState() {
    controller.fetchLapHistory(widget.attendance.id ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              showLapsBottomSheet(context, controller);
            },
            icon: Icon(Icons.history),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Circular Timer Display
            _buildCircularTimer(),

            const SizedBox(height: 40),

            // Control Buttons
            _buildControlButtons(),

            const SizedBox(height: 20),

            // Lap Times
            _buildLapTimes(),

            Obx(
              () => Visibility(
                visible: controller.showSaveOption.value,
                child: _saveAndCancel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTimer() {
    return Obx(() {
      final totalSeconds = 60.0; // total seconds for progress (customizable)
      final elapsedSeconds = controller.elapsedTime.value.inSeconds.toDouble();
      final progress = (elapsedSeconds % totalSeconds) / totalSeconds;

      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              color: Colors.blue,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          Text(
            controller.formattedTime,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildControlButtons() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset
          ElevatedButton(
            onPressed: controller.resetStopwatch,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),

          // Start / Pause
          ElevatedButton(
            onPressed: () {
              controller.isRunning.value
                  ? controller.pauseStopwatch()
                  : controller.startStopwatch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isRunning.value
                  ? Colors.orange
                  : Colors.green,
            ),
            child: Text(controller.isRunning.value ? 'Pause' : 'Start'),
          ),

          // Lap
          ElevatedButton(
            onPressed: controller.isRunning.value ? controller.recordLap : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Lap'),
          ),

          // Stop
          ElevatedButton(
            onPressed: controller.isRunning.value
                ? controller.stopStopwatch
                : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  Widget _saveAndCancel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            height: Get.height * 0.050,
            width: Get.width * 0.40,
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AppTheme.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () async {
            await controller.addlaps(widget.attendance.id ?? "");
          },
          child: Container(
            height: Get.height * 0.050,
            width: Get.width * 0.40,
            decoration: BoxDecoration(
              color: AppTheme.bookingSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Save",
                style: TextStyle(
                  color: AppTheme.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLapTimes() {
    return Expanded(
      child: Obx(() {
        // Reverse the list so last lap is first
        final reversedLaps = controller.laps.reversed.toList();

        return ListView.builder(
          itemCount: reversedLaps.length,
          itemBuilder: (context, index) {
            final isLatest = index == 0; // Most recent lap
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(
                  reversedLaps[index],
                  style: TextStyle(
                    fontSize: isLatest ? 22 : 16, // Bigger for latest
                    fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                    color: isLatest ? Colors.black : Colors.black87,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void showLapsBottomSheet(
    BuildContext context,
    AttendanceController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Obx(() {
          if (controller.lapsHistory.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No laps found"),
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              itemCount: controller.lapsHistory.length,
              itemBuilder: (context, index) {
                final ride = controller.lapsHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ride ${ride.rideNumber} • ${ride.createdAt.toLocal().toString().split('.')[0]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...ride.lapTimes.map(
                          (lap) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              lap,
                              style: TextStyle(
                                fontSize: 16,
                                color: lap == ride.lapTimes.last
                                    ? Colors
                                          .orange // latest lap highlighted
                                    : Colors.black87,
                                fontWeight: lap == ride.lapTimes.last
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total Duration: ${ride.totalDuration}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }
}
