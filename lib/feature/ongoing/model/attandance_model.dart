class Attendance {
  final String timestamp;          // Timestamp of booking or session
  final String riderName;          // Rider's full name
  final String phoneNumber;        // Rider phone number
  final String programBooked;      // Program name
  final String sessionDate;        // Date of this session
  final int sessionNumber;         // Session number (1,2,3...)
  final int totalSessions;         // Total sessions assigned
  final String attendanceStatus;   // Present / Absent / Cancelled
  final String sessionDuration;    // Duration of session (optional)
  final String sessionCompletion;  // Completed / Incomplete
  final int sessionsCompleted;     // Count of sessions completed so far
  final int fullDaysDone;          // Count of full days done
  final int halfDaysDone;          // Count of half days done
  final int sessionsRemaining;     // Total remaining sessions

  Attendance({
    required this.timestamp,
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
  });

  /// Convert from Google Sheets row (List<dynamic>) to Attendance object
  factory Attendance.fromList(List<dynamic> row) {
    final safeRow = List<String>.generate(14, (i) {
      if (i < row.length && row[i] != null) {
        return row[i].toString().trim();
      }
      return '';
    });

    int parseInt(String value) => int.tryParse(value) ?? 0;

    return Attendance(
      timestamp: safeRow[0],
      riderName: safeRow[1],
      phoneNumber: safeRow[2],
      programBooked: safeRow[3],
      sessionDate: safeRow[4],
      sessionNumber: parseInt(safeRow[5]),
      totalSessions: parseInt(safeRow[6]),
      attendanceStatus: safeRow[7],
      sessionDuration: safeRow[8],
      sessionCompletion: safeRow[9],
      sessionsCompleted: parseInt(safeRow[10]),
      fullDaysDone: parseInt(safeRow[11]),
      halfDaysDone: parseInt(safeRow[12]),
      sessionsRemaining: parseInt(safeRow[13]),
    );
  }

  /// Convert Attendance object to List for Google Sheets
  List<String> toList() {
    return [
      timestamp,
      riderName,
      phoneNumber,
      programBooked,
      sessionDate,
      sessionNumber.toString(),
      totalSessions.toString(),
      attendanceStatus,
      sessionDuration,
      sessionCompletion,
      sessionsCompleted.toString(),
      fullDaysDone.toString(),
      halfDaysDone.toString(),
      sessionsRemaining.toString(),
    ];
  }

  /// Convert Attendance object to JSON
  Map<String, dynamic> toJson() {
    return {
      "Timestamp": timestamp,
      "Rider Name": riderName,
      "Phone Number": phoneNumber,
      "Program Booked": programBooked,
      "Session Date": sessionDate,
      "Session Number": sessionNumber,
      "Total Sessions": totalSessions,
      "Attendance Status": attendanceStatus,
      "Session Duration": sessionDuration,
      "Session Completion": sessionCompletion,
      "Sessions Completed": sessionsCompleted,
      "Full Days Done": fullDaysDone,
      "Half Days Done": halfDaysDone,
      "Sessions Remaining": sessionsRemaining,
    };
  }
}
