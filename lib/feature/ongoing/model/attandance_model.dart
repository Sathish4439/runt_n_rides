class Attendance {
  final String? id; // MongoDB document _id
  final String riderName; // Rider's full name
  final String phoneNumber; // Rider phone number
  final String programBooked; // Program name
  final String sessionDate; // Date of this session (ISO String)
  final int sessionNumber; // Session number (1,2,3...)
  final int totalSessions; // Total sessions assigned
  final String attendanceStatus; // Present / Absent / Late / Cancelled
  final String sessionDuration; // Full Day / Half Day
  final String sessionCompletion; // Completed / Partial / Not Started
  final int sessionsCompleted; // Count of sessions completed so far
  final int fullDaysDone; // Count of full days done
  final int halfDaysDone; // Count of half days done
  final int sessionsRemaining; // Total remaining sessions
  final String? createdAt; // Auto timestamp from Mongo
  final String? updatedAt; // Auto timestamp from Mongo

  Attendance({
    this.id,
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
  });

  /// Convert JSON (from Mongo API) to Attendance object
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json["_id"] ?? "",
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
    );
  }

  /// Convert Attendance object to JSON (for POST/PUT requests)
  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  static final defaultData = Attendance(
    riderName: "",
    phoneNumber: "",
    programBooked: "",
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
