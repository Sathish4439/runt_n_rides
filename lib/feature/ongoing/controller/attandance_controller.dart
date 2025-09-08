// attendance_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/api_service.dart';
import 'package:rutsnrides_admin/core/services/endpoint.dart';
import 'package:rutsnrides_admin/core/theme/app_theme.dart';
import 'package:rutsnrides_admin/core/utils/utils.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/lap_model.dart';

class AttendanceController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var attendanceList = <Attendance>[].obs;
  var filteredList = <Attendance>[].obs;
  var selectedDate = DateTime.now().obs;
  var searchQuery = ''.obs;
  var stats = <String, dynamic>{}.obs;
  var showSaveOption = false.obs;

  final api = ApiService();

  // Stopwatch
  var elapsedTime = Duration.zero.obs;
  var isRunning = false.obs;
  Timer? _timer;
  var laps = <String>[].obs;

  void recordLap() {
    final lapNumber = laps.length + 1;
    laps.add("Lap $lapNumber: $formattedTime");
  }

  String get formattedTime {
    String twoDigits(int n, [int pad = 2]) => n.toString().padLeft(pad, '0');

    final hours = twoDigits(elapsedTime.value.inHours);
    final minutes = twoDigits(elapsedTime.value.inMinutes.remainder(60));
    final seconds = twoDigits(elapsedTime.value.inSeconds.remainder(60));
    final milliseconds = twoDigits(
      elapsedTime.value.inMilliseconds.remainder(1000),
      3,
    );
    final microseconds = twoDigits(
      elapsedTime.value.inMicroseconds.remainder(1000),
      3,
    );

    return "${hours}:${minutes}:${seconds}";
  }

  /// Start stopwatch
  void startStopwatch() {
    showSaveOption(false);
    if (isRunning.value) return;
    isRunning.value = true;

    // Safer: tick every millisecond
    _timer = Timer.periodic(const Duration(milliseconds: 1), (_) {
      elapsedTime.value += const Duration(milliseconds: 1);
    });
  }

  /// Pause stopwatch
  void pauseStopwatch() {
    _timer?.cancel();
    isRunning.value = false;
  }

  /// Stop stopwatch
  void stopStopwatch() {
    _timer?.cancel();
    isRunning.value = false;
    showSaveOption(true);
  }

  /// Reset stopwatch
  void resetStopwatch() {
    _timer?.cancel();
    elapsedTime.value = Duration.zero;
    isRunning.value = false;
    showSaveOption(false);
    laps.clear();
  }

  /// Fetch all attendance
  Future<void> fetchAttendance() async {
    try {
      isLoading(true);
      attendanceList.clear();

      final res = await api.get(EndPoints.getAllAttendance);

      if (res.data['success']) {
        var li = (res.data['sessions'] as List)
            .map((e) => Attendance.fromJson(e))
            .toList();

        if (li.isNotEmpty) {
          attendanceList.value = li;
          filteredList.value = li;
        }

        printData("attendanceList ${attendanceList.length}");
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch attendance: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addlaps(String id) async {
    try {
      var bodyJson = {"lapTimes": laps, "totalDuration": formattedTime};

      var res = await api.post(
        "${EndPoints.lapsRoute}/$id/${EndPoints.laps}",
        data: bodyJson,
      );

      if (res.data['success']) {
        showSuccess(res.data['message']);
      } else {
        showError(res.data['message']);
      }
    } catch (e) {
      printData(e);
    } finally {
      fetchLapHistory(id);
    }
  }

  /// Filter by date
  void filterByDate(DateTime date) {
    selectedDate.value = date;
    filteredList.value = attendanceList.where((attendance) {
      final sessionDate = _parseDate(attendance.sessionDate);
      return sessionDate != null &&
          sessionDate.year == date.year &&
          sessionDate.month == date.month &&
          sessionDate.day == date.day;
    }).toList();
    _calculateStats();
  }

  /// Search by rider name or phone
  void searchAttendance(String query) {
    searchQuery.value = query.toLowerCase();
    filteredList.value = attendanceList.where((attendance) {
      return attendance.riderName.toLowerCase().contains(searchQuery.value) ||
          attendance.phoneNumber.contains(searchQuery.value);
    }).toList();
    _calculateStats();
  }

  /// Filter by status
  void filterByStatus(String status) {
    if (status == 'All') {
      filteredList.value = attendanceList;
    } else {
      filteredList.value = attendanceList
          .where((attendance) => attendance.sessionCompletion == status)
          .toList();
    }
    _calculateStats();
  }

  /// Calculate statistics
  Future<void> _calculateStats() async {
    final present = filteredList
        .where((a) => a.attendanceStatus == 'Present')
        .length;
    final absent = filteredList
        .where((a) => a.attendanceStatus == 'Absent')
        .length;
    final cancelled = filteredList
        .where((a) => a.attendanceStatus == 'Cancelled')
        .length;
    final total = filteredList.length;

    stats.value = {
      'total': total,
      'present': present,
      'absent': absent,
      'cancelled': cancelled,
      'attendanceRate': total > 0 ? (present / total * 100) : 0,
    };
  }

  /// Parse dd/mm/yyyy date
  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update attendance
  Future<void> updateAddress(Attendance updatedAttendance) async {
    try {
      final res = await api.put(
        "${EndPoints.attendance}/${updatedAttendance.id}",
        data: updatedAttendance.toJson(),
      );
      printData(res);
    } catch (e) {
      printData(e);
    } finally {
      fetchAttendance();
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await fetchAttendance();
  }

  /// Delete attendance
  Future<void> deleteAttendance(String id) async {
    try {
      final res = await api.delete("${EndPoints.attendance}/$id");
      printData(res);
    } catch (e) {
      printData(e);
    } finally {
      await fetchAttendance();
    }
  }

  var lapsHistory = <Lap>[].obs;
  var loadLapsHistory = false.obs;

  /// Fetch lap history for a specific session
  Future<void> fetchLapHistory(String id) async {
    try {
      loadLapsHistory.value = true;

      var res = await api.get("${EndPoints.lapsRoute}/$id/${EndPoints.laps}");

      if (res.data['success']) {
        var data = (res.data['laps'] as List)
            .map((e) => Lap.fromJson(e))
            .toList();

        if (data.isNotEmpty) {
          setLapsHistory(data);
        }
      }
    } catch (e) {
      printData("Error fetching lap history: $e");
    } finally {
      loadLapsHistory.value = false;
    }
  }

  /// Set laps history and sort by createdAt descending
  void setLapsHistory(List<Lap> data) {
    lapsHistory.value = data; // assign all laps
    lapsHistory.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ); // latest first
  }

  @override
  void onClose() {
    _timer?.cancel();
    isLoading.value = false;

    attendanceList.clear();
    filteredList.clear();
    selectedDate.value = DateTime.now();
    searchQuery.value = '';
    stats.clear();

    super.onClose();
  }
}
