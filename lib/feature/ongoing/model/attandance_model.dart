import 'package:RUTSNRIDES/feature/booking/model/booking_model.dart';

class Attendance {
  final String? id; // MongoDB document _id
  final String bookingId; // only the ID string
  final String riderName;
  final String phoneNumber;
  final String programBooked;
  final String sessionDate;
  final int sessionNumber;
  final int totalSessions;
  final String attendanceStatus;
  final String sessionDuration;
  final String sessionCompletion;
  final int sessionsCompleted;
  final int fullDaysDone;
  final int halfDaysDone;
  final int sessionsRemaining;
  final String? createdAt;
  final String? updatedAt;
  final Booking? bookingData;

  /// ✅ Change from List<String> → List<CompletedDate>
  final List<CompletedDate> completedDates;

  Attendance({
    this.id,
    required this.bookingId,
    required this.riderName,
    required this.phoneNumber,
    required this.programBooked,
    required this.sessionDate,
    required this.sessionNumber,
    required this.totalSessions,
    required this.attendanceStatus,
    required this.sessionDuration,
    required this.sessionCompletion,
    required this.sessionsCompleted,
    required this.fullDaysDone,
    required this.halfDaysDone,
    required this.sessionsRemaining,
    this.createdAt,
    this.updatedAt,
    this.bookingData,
    required this.completedDates,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    final bookingJson = json["bookingId"];

    return Attendance(
      id: json["_id"]?.toString(),
      bookingId: bookingJson is Map<String, dynamic>
          ? bookingJson["_id"] ?? ""
          : bookingJson?.toString() ?? "",
      riderName: json["riderName"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      programBooked: json["programBooked"] ?? "",
      sessionDate: json["sessionDate"] ?? "",
      sessionNumber: json["sessionNumber"] ?? 0,
      totalSessions: json["totalSessions"] ?? 0,
      attendanceStatus: json["attendanceStatus"] ?? "Present",
      sessionDuration: json["sessionDuration"] ?? "Full Day",
      sessionCompletion: json["sessionCompletion"] ?? "Not Started",
      sessionsCompleted: json["sessionsCompleted"] ?? 0,
      fullDaysDone: json["fullDaysDone"] ?? 0,
      halfDaysDone: json["halfDaysDone"] ?? 0,
      sessionsRemaining: json["sessionsRemaining"] ?? 0,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      bookingData: bookingJson is Map<String, dynamic>
          ? Booking.fromJson(bookingJson)
          : null,
      completedDates: (json['completedDates'] as List<dynamic>? ?? [])
          .map((e) => CompletedDate.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "bookingId": bookingId,
      "riderName": riderName,
      "phoneNumber": phoneNumber,
      "programBooked": programBooked,
      "sessionDate": sessionDate,
      "sessionNumber": sessionNumber,
      "totalSessions": totalSessions,
      "attendanceStatus": attendanceStatus,
      "sessionDuration": sessionDuration,
      "sessionCompletion": sessionCompletion,
      "sessionsCompleted": sessionsCompleted,
      "fullDaysDone": fullDaysDone,
      "halfDaysDone": halfDaysDone,
      "sessionsRemaining": sessionsRemaining,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "bookingData": bookingData?.toJson(),
      "completedDates": completedDates.map((e) => e.toJson()).toList(),
    };
  }

  static final defaultData = Attendance(
    bookingId: "",
    riderName: "",
    phoneNumber: "",
    programBooked: "",
    completedDates: [],
    sessionDate: "",
    sessionNumber: 0,
    totalSessions: 0,
    attendanceStatus: "",
    sessionDuration: "",
    sessionCompletion: "",
    sessionsCompleted: 0,
    fullDaysDone: 0,
    halfDaysDone: 0,
    sessionsRemaining: 0,
  );
}

class CompletedDate {
  final String date;
  final String duration;

  CompletedDate({
    required this.date,
    required this.duration,
  });

  factory CompletedDate.fromJson(Map<String, dynamic> json) {
    return CompletedDate(
      date: json["date"] ?? "",
      duration: json["duration"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "duration": duration,
    };
  }
}
