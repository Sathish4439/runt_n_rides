import 'package:RUTSNRIDES/core/services/api_service.dart';
import 'package:RUTSNRIDES/core/services/endpoint.dart';
import 'package:RUTSNRIDES/core/utils/utils.dart';
import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  var loadUserData = false.obs;
  var userDetails = <Attendance>[].obs;
  var selectedAttendance = Attendance.defaultData.obs;
  var filteredList = <Attendance>[].obs;
  var searchQuery = ''.obs;

  final api = ApiService();

  Future<void> fetchUserData() async {
    try {
      loadUserData(true);

      var res = await api.get(EndPoints.attendance);

      if (res.data['success']) {
        var li = (res.data['sessions'] as List)
            .map((e) => Attendance.fromJson(e))
            .where((att) => att.sessionCompletion.toLowerCase() == "completed")
            .toList();

        userDetails.value = li;
        filteredList.value = li;
      }
    } catch (e) {
      printData(e);
    } finally {
      loadUserData(false);
    }
  }

  void filterAttendance(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredList.value = userDetails;
    } else {
      filteredList.value = userDetails.where((attendance) {
        return attendance.riderName.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            attendance.phoneNumber.contains(query) ||
            attendance.programBooked.toLowerCase().contains(
              query.toLowerCase(),
            );
      }).toList();
    }
  }

  void selectAttendance(Attendance attendance) {
    selectedAttendance.value = attendance;
  }
}
