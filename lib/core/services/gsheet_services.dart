import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'package:rutsnrides_admin/core/common_wid/widget.dart';
import 'package:rutsnrides_admin/core/constant/const_data.dart';
import 'package:rutsnrides_admin/core/services/cridential_service.dart';
import 'package:rutsnrides_admin/feature/booking/model/booking_model.dart';
import 'package:rutsnrides_admin/feature/enquiry/model/lead_model.dart';
import 'package:rutsnrides_admin/feature/ongoing/model/attandance_model.dart';

class GoogleSheetsService {
  // Singleton instance
  static final GoogleSheetsService _instance = GoogleSheetsService._internal();
  factory GoogleSheetsService() => _instance;
  GoogleSheetsService._internal();

  // Remove this line: final GSheets _gsheets = GSheets(SheetId.credentials);
  GSheets? _gsheets;
  Spreadsheet? _spreadsheet;
  Worksheet? _leadSheet;
  Worksheet? _bookingSheet;
  Worksheet? _attandance;

  bool get isInitialized => _gsheets != null && _spreadsheet != null;

  /// Initialize credentials and connection to Google Sheets
  Future<void> initializeCredentials() async {
    try {
      final credentials = await CredentialsService().getCredentials();
      _gsheets = GSheets(credentials);
      print('✅ Google Sheets credentials initialized successfully');
    } catch (e) {
      print('❌ Error initializing credentials: $e');
      rethrow;
    }
  }

  Future<void> printSheetNames(String spreadsheetId) async {
    try {
      print("🚀 Starting to fetch sheet names for spreadsheet: $spreadsheetId");

      // Step 1: Load credentials
      print("🔑 Fetching credentials...");
      final credentials = await CredentialsService().getCredentials();
      print("✅ Credentials fetched successfully");

      // Step 2: Initialize GSheets
      print("⚙️ Initializing GSheets instance...");
      final gsheets = GSheets(credentials);
      print("✅ GSheets initialized");

      // Step 3: Fetch spreadsheet
      print("📂 Fetching spreadsheet details...");
      final spreadsheet = await gsheets.spreadsheet(spreadsheetId);
      print("✅ Spreadsheet loaded: ${spreadsheet.id}");

      // Step 4: List all sheets
      print("📑 Listing all sheets in spreadsheet...");
      for (var sheet in spreadsheet.sheets) {
        print("   ➡️ Sheet title: ${sheet.title}, Sheet ID: ${sheet.id}");
      }

      print("🎉 Completed fetching all sheet names & IDs!");
    } catch (e) {
      print("❌ Error fetching sheet names: $e");
    }
  }

  /// Initialize connection to Google Sheets
  Future<void> init(
    String spreadsheetId, {
    String? leadSheetName,
    String? bookingSheetName,
    String? attandanceSheetName,
  }) async {
    try {
      print('🚀 Starting init for spreadsheet: $spreadsheetId');
      print('🚀 Starting init for atttant shhet nmae: $attandanceSheetName');
      // printSheetNames(spreadsheetId);

      // Step 1: Initialize credentials
      if (_gsheets == null) {
        print('🔑 Initializing credentials...');
        await initializeCredentials();
        print('✅ Credentials initialized');
      } else {
        print('ℹ️ Credentials already initialized');
      }

      // Step 2: Load spreadsheet
      print('📂 Fetching spreadsheet...');
      _spreadsheet = await _gsheets!.spreadsheet(spreadsheetId);
      print('✅ Spreadsheet loaded: ${_spreadsheet!.id}');

      // Step 3: List worksheets
      print('📑 Worksheets in Spreadsheet $spreadsheetId:');
      for (var ws in _spreadsheet!.sheets) {
        print('   - ${ws.title}');
      }

      // Step 4: Initialize Lead Sheet
      print('🔎 Looking for Lead Sheet...');
      _leadSheet = _findWorksheet(leadSheetName, [
        'form responses',
        'leads',
        'enquiry',
      ]);
      if (_leadSheet == null) {
        print('❌ Lead sheet not found with name: "$leadSheetName" or defaults');
      } else {
        print('✅ Lead sheet initialized: ${_leadSheet!.title}');
      }

      // Step 5: Initialize Booking Sheet
      print('🔎 Looking for Booking Sheet...');
      _bookingSheet = _findWorksheet(bookingSheetName, [
        'bookings',
        'booking',
        'programs',
      ]);
      if (_bookingSheet == null) {
        print('⚠️ Booking sheet not found (name: "$bookingSheetName")');
      } else {
        print('✅ Booking sheet initialized: ${_bookingSheet!.title}');
      }

      // Step 6: Initialize Attendance Sheet
      print('🔎 Looking for Attendance Sheet...');
      _attandance = _findWorksheet(attandanceSheetName, [
        'attendance',
        'attendances',
        'attandance',
      ]);
      if (_attandance == null) {
        print('⚠️ Attendance sheet not found (name: "$attandanceSheetName")');
      } else {
        print('✅ Attendance sheet initialized: ${_attandance!.title}');
      }

      // Step 7: Print headers
      print('📝 Printing headers for all initialized sheets...');
      await _printSheetHeaders();

      print('🎉 Google Sheets init completed successfully!');
    } catch (e) {
      print('❌ Error initializing Google Sheets: $e');
      rethrow;
    }
  }

  /// Helper method to find worksheets with fallback logic
  Worksheet? _findWorksheet(String? sheetName, List<String> partials) {
    if (_spreadsheet == null) {
      print('❌ Spreadsheet not initialized!');
      return null;
    }

    print("_findWorksheet $sheetName");

    // Exact name match
    if (sheetName != null) {
      final exact = _spreadsheet!.worksheetByTitle(sheetName);
      if (exact != null) {
        return exact;
      }
    }

    // Partial match (case-insensitive)
    for (var partial in partials) {
      for (var ws in _spreadsheet!.sheets) {
        if (ws.title.toLowerCase().contains(partial.toLowerCase())) {
          return ws;
        }
      }
    }

    return null;
  }

  /// Fetch all attendance data
  Future<List<Attendance>> fetchAttendanceData(
    String spreadsheetId, {
    String? attendanceSheetName,
  }) async {
    print('🚀 Starting fetchAttendanceData...');

    try {
      // Initialize spreadsheet if not already
      await init(spreadsheetId, attandanceSheetName: attendanceSheetName);

      if (_attandance == null) {
        print('❌ Attendance sheet not initialized');
        await init(spreadsheetId, attandanceSheetName: attendanceSheetName);
      }

      // Fetch all rows from the sheet
      print('📥 Fetching all rows from attendance sheet...');
      final allRows = await _attandance!.values.allRows();
      print('✅ Retrieved ${allRows.length} total rows');

      if (allRows.isEmpty || allRows.length <= 1) {
        print('ℹ️ No attendance data found (only ${allRows.length} rows)');
        return [];
      }

      final attendanceList = <Attendance>[];
      final dataRowCount = allRows.length - 1; // Exclude header row
      print('🔢 Processing $dataRowCount data rows...');

      for (int i = 1; i < allRows.length; i++) {
        final rowNumber = i + 1; // 1-based row number for logging

        try {
          final attendance = Attendance.fromList(allRows[i]);
          attendanceList.add(attendance);
        } catch (e) {
          print('⚠️ Error parsing attendance row $rowNumber: $e');
        }
      }

      print(
        '🎉 Successfully fetched ${attendanceList.length} attendance records',
      );
      return attendanceList;
    } catch (e) {
      print('❌ Error fetching attendance data: $e');
      return [];
    }
  }

  /// Fetch all leads from the lead sheet
  Future<List<Lead>> fetchLeads() async {
    if (_leadSheet == null) {
      print('❌ Lead sheet not initialized');
      return [];
    }

    try {
      final rows = await _leadSheet!.values.allRows();
      if (rows.isEmpty || rows.length <= 1) return [];

      final leads = <Lead>[];
      for (int i = 1; i < rows.length; i++) {
        try {
          final lead = Lead.fromList(rows[i]);
          leads.add(lead);
        } catch (e) {
          print('⚠️ Error parsing lead row ${i + 1}: $e');
        }
      }
      return leads;
    } catch (e) {
      print('Error fetching leads: $e');
      return [];
    }
  }

  /// Fetch all bookings from the booking sheet
  Future<List<Booking>> fetchBookings() async {
    if (_bookingSheet == null) {
      print('❌ Booking sheet not initialized');
      return [];
    }

    try {
      final rows = await _bookingSheet!.values.allRows();
      if (rows.isEmpty || rows.length <= 1) return [];

      final bookings = <Booking>[];
      for (int i = 1; i < rows.length; i++) {
        try {
          final booking = Booking.fromList(rows[i]);
          bookings.add(booking);
        } catch (e) {
          print('⚠️ Error parsing booking row ${i + 1}: $e');
        }
      }
      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  /// Print headers for debugging
  Future<void> _printSheetHeaders() async {
    if (_leadSheet != null) {
      try {
        final headers = await _leadSheet!.values.row(1);
        print('--- Lead Sheet Columns (${headers.length}) ---');
        for (int i = 0; i < headers.length; i++) {
          print('${i + 1}. "${headers[i]}"');
        }
      } catch (e) {
        print('Error reading lead sheet headers: $e');
      }
    }

    if (_bookingSheet != null) {
      try {
        final headers = await _bookingSheet!.values.row(1);
        print('--- Booking Sheet Columns (${headers.length}) ---');
        for (int i = 0; i < headers.length; i++) {
          print('${i + 1}. "${headers[i]}"');
        }
      } catch (e) {
        print('Error reading booking sheet headers: $e');
      }
    }
  }

  /// Update lead follow-up information
  Future<bool> updateLeadFollowUp({
    required String leadName,
    required String status,
    required DateTime followUpDate,
    required String notes,
  }) async {
    if (_leadSheet == null) {
      print('❌ Lead sheet not initialized');
      return false;
    }

    try {
      final rowIndex = await _findRowIndex('Full Name', leadName, _leadSheet!);
      if (rowIndex == null) {
        print('❌ Lead "$leadName" not found');
        return false;
      }

      // ✅ Find Status column
      final statusCol = await _findColumnIndex('Status', _leadSheet!);
      if (statusCol == null) {
        print('❌ Status column not found');
        return false;
      }

      // ✅ Update Status
      print("📌 Updating row $rowIndex, col $statusCol with status: $status");
      await _leadSheet!.values.insertValue(
        status,
        column: statusCol,
        row: rowIndex,
      );

      // ✅ Find Follow Up Date column
      final dateCol = await _findColumnIndex('Follow Up Date', _leadSheet!);
      if (dateCol != null) {
        final formattedDate =
            '${followUpDate.month}/${followUpDate.day}/${followUpDate.year} '
            '${followUpDate.hour}:${followUpDate.minute.toString().padLeft(2, '0')}';

        print(
          "📌 Updating row $rowIndex, col $dateCol with date: $formattedDate",
        );
        await _leadSheet!.values.insertValue(
          formattedDate,
          column: dateCol,
          row: rowIndex,
        );
      } else {
        print("⚠️ 'Follow Up Date' column not found");
      }

      // ✅ Find Follow Up Notes column
      final notesCol = await _findColumnIndex('Follow Up Notes', _leadSheet!);
      if (notesCol != null) {
        print("📌 Updating row $rowIndex, col $notesCol with notes: $notes");
        await _leadSheet!.values.insertValue(
          notes,
          column: notesCol,
          row: rowIndex,
          // important so it doesn’t insert new row
        );
      } else {
        print("⚠️ 'Follow Up Notes' column not found");
      }

      print('✅ Successfully updated lead: $leadName');
      return true;
    } catch (e) {
      print('❌ Error updating lead: $e');
      return false;
    }
  }

  /// Find column index by name
  Future<int?> _findColumnIndex(String columnName, Worksheet worksheet) async {
    try {
      final headerRow = await worksheet.values.row(1);
      for (int i = 0; i < headerRow.length; i++) {
        if (headerRow[i]?.toString().trim().equalsIgnoreCase(columnName) ??
            false) {
          return i + 1;
        }
      }
      print('Column "$columnName" not found');
      return null;
    } catch (e) {
      print('Error finding column index: $e');
      return null;
    }
  }

  /// Find row index by search value
  Future<int?> _findRowIndex(
    String columnName,
    String searchValue,
    Worksheet worksheet,
  ) async {
    try {
      final allRows = await worksheet.values.allRows();
      if (allRows.isEmpty) return null;

      final colIndex = allRows[0].indexWhere(
        (cell) => cell?.toString().trim().equalsIgnoreCase(columnName) ?? false,
      );

      if (colIndex == -1) return null;

      for (int i = 1; i < allRows.length; i++) {
        if (allRows[i].length > colIndex) {
          final cellValue = allRows[i][colIndex]?.toString().trim() ?? '';
          if (cellValue.equalsIgnoreCase(searchValue)) {
            return i + 1;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error finding row index: $e');
      return null;
    }
  }

  /// Insert new booking
  Future<void> insertBooking(
    String sheetId,
    String worksheetName,
    Booking booking,
  ) async {
    try {
      final ss = await _gsheets!.spreadsheet(sheetId);

      // Get the specified worksheet
      final bookingSheet = await ss.worksheetByTitle(worksheetName);

      if (bookingSheet == null) {
        throw Exception(
          'Worksheet "$worksheetName" not found in the spreadsheet',
        );
      }

      // Validate required fields
      final missingFields = [
        if (booking.riderName.trim().isEmpty) 'riderName',
        if (booking.phone.trim().isEmpty) 'phone',
        if (booking.programBooked.trim().isEmpty) 'programBooked',
        if (booking.bookingDate.trim().isEmpty) 'bookingDate',
      ];

      if (missingFields.isNotEmpty) {
        throw Exception('Missing required fields: ${missingFields.join(', ')}');
      }
      final dateFormatter = DateFormat("yyyy-MM-dd");

      final row = [
        dateFormatter.format(DateTime.now()),
        booking.riderName,
        booking.phone,
        booking.programBooked,
        booking.programDetails,
        booking.bookingDate,
        booking.preferredSessionDate,
        booking.trainingSlot,
        booking.sessionType,
        booking.bikeRental,
        booking.gearRental,
        booking.totalFee?.toString() ?? '',
        booking.paymentStatus,
        booking.amountPaid?.toString() ?? '',
        booking.paymentMode,
        booking.paymentProof,
        booking.riderAge?.toString() ?? '',
        booking.parentName,
        booking.bookingType,
        booking.receivedAmount?.toString() ?? '',
        booking.bookingStatus,
        booking.trainingStarted,
      ];

      await bookingSheet.values.appendRow(row);
      print(
        '✅ Booking for ${booking.riderName} inserted successfully in worksheet "$worksheetName"',
      );
    } catch (e) {
      print('❌ Error inserting booking: $e');
      rethrow;
    }
  }

  Future<void> insertAttendance(
    String spreadsheetId,
    String attendanceSheetName,
    Attendance attendance,
  ) async {
    try {
      // Auto initialize if attendance sheet is null
      if (_attandance == null) {
        print('⚠️ Attendance sheet not initialized, trying to init...');
        // await init(spreadsheetId, attandanceSheetName: attendanceSheetName);
        await init(
          '1OLdGHGbhzvKlUxGhE-8m2kNpuSBSGuhi3oMClzbKyEE',
          leadSheetName:
              'form responses', // or whatever your lead sheet is called
          attandanceSheetName: 'attandence', // matches your log
        );
        if (_attandance == null) {
          throw Exception(
            '❌ Attendance sheet still not found after init. Please check your sheet.',
          );
        }
      }

      // --- Fetch headers ---
      final headers = await _attandance!.values.row(1);

      if (headers.isEmpty) {
        throw Exception(
          "❌ No headers found in Attendance sheet. Please add headers first.",
        );
      }

      print("📌 Headers found in Attendance Sheet:");
      for (var h in headers) {
        print(" - $h");
      }

      // --- Check for duplicates by Phone Number ---
      final allRows = await _attandance!.values.allRows();
      final phoneIndex = headers.indexOf("Phone Number");

      if (phoneIndex != -1) {
        final duplicate = allRows
            .skip(1)
            .any(
              (row) =>
                  row.length > phoneIndex &&
                  row[phoneIndex].trim() == attendance.phoneNumber.trim(),
            );

        if (duplicate) {
          print(
            "⚠️ Duplicate entry found for phone number: ${attendance.phoneNumber}. Skipping insert.",
          );
          return;
        }
      } else {
        print(
          "⚠️ 'Phone Number' column not found in headers. Skipping duplicate check.",
        );
      }

      // --- Map Attendance fields to header values ---
      final Map<String, dynamic> attendanceMap = {
        "Timestamp": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        "Rider Name": attendance.riderName,
        "Phone Number": attendance.phoneNumber,
        "Program Booked": attendance.programBooked,
        "Session Date": attendance.sessionDate.isEmpty
            ? DateFormat("yyyy-MM-dd").format(DateTime.now())
            : attendance.sessionDate,
        "Session Number": attendance.sessionNumber.toString(),
        "Total Sessions": attendance.totalSessions.toString(),
        "Attendance Status": attendance.attendanceStatus,
        "Session Duration": attendance.sessionDuration,
        "Session Completion": attendance.sessionCompletion,
        "Sessions Completed": attendance.sessionsCompleted.toString(),
        "Full Days Done": attendance.fullDaysDone.toString(),
        "Half Days Done": attendance.halfDaysDone.toString(),
        "Sessions Remaining": attendance.sessionsRemaining.toString(),
      };

      // --- Build row aligned with headers ---
      final row = headers.map((h) => attendanceMap[h] ?? "").toList();

      print("📝 Row to insert (aligned with headers):");
      for (int i = 0; i < headers.length; i++) {
        print("  ${headers[i]} : ${row[i]}");
      }

      // --- Insert row ---
      await _attandance!.values.appendRow(row);

      print('✅ Attendance for ${attendance.riderName} inserted successfully');
    } catch (e) {
      print('❌ Error inserting attendance: $e');
      rethrow;
    }
  }

  /// Insert attendance record - only if attendance sheet exists
  // Future<void> insertAttendance(
  //   String spreadsheetId,
  //   String attendanceSheetName,
  //   Attendance attendance,
  // ) async {
  //   try {
  //     // Auto initialize if attendance sheet is null
  //     if (_attandance == null) {
  //       print('⚠️ Attendance sheet not initialized, trying to init...');
  //       await init(spreadsheetId, attandanceSheetName: attendanceSheetName);

  //       if (_attandance == null) {
  //         throw Exception(
  //           '❌ Attendance sheet still not found after init. Please check your sheet.',
  //         );
  //       }
  //     }

  //     // --- Fetch headers ---
  //     final headers = await _attandance!.values.row(1);

  //     if (headers.isEmpty) {
  //       throw Exception(
  //         "❌ No headers found in Attendance sheet. Please add headers first.",
  //       );
  //     }

  //     print("📌 Headers found in Attendance Sheet:");
  //     for (var h in headers) {
  //       print(" - $h");
  //     }

  //     // --- Map Attendance fields to header values ---
  //     final Map<String, dynamic> attendanceMap = {
  //       "Timestamp": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
  //       "Rider Name": attendance.riderName,
  //       "Phone Number": attendance.phoneNumber,
  //       "Program Booked": attendance.programBooked,
  //       "Session Date": attendance.sessionDate.isEmpty
  //           ? DateFormat("yyyy-MM-dd").format(DateTime.now())
  //           : attendance.sessionDate,
  //       "Session Number": attendance.sessionNumber.toString(),
  //       "Total Sessions": attendance.totalSessions.toString(),
  //       "Attendance Status": attendance.attendanceStatus,
  //       "Session Duration": attendance.sessionDuration,
  //       "Session Completion": attendance.sessionCompletion,
  //       "Sessions Completed": attendance.sessionsCompleted.toString(),
  //       "Full Days Done": attendance.fullDaysDone.toString(),
  //       "Half Days Done": attendance.halfDaysDone.toString(),
  //       "Sessions Remaining": attendance.sessionsRemaining.toString(),
  //     };

  //     // --- Build row aligned with headers ---
  //     final row = headers.map((h) => attendanceMap[h] ?? "").toList();

  //     print("📝 Row to insert (aligned with headers):");
  //     for (int i = 0; i < headers.length; i++) {
  //       print("  ${headers[i]} : ${row[i]}");
  //     }

  //     // --- Insert row ---
  //     await _attandance!.values.appendRow(row);

  //     print('✅ Attendance for ${attendance.riderName} inserted successfully');

  //     // --- Re-fetch headers after insert (to confirm still intact) ---
  //     final newHeaders = await _attandance!.values.row(1);
  //     print("📌 Headers after insert:");
  //     for (var h in newHeaders) {
  //       print(" - $h");
  //     }
  //   } catch (e) {
  //     print('❌ Error inserting attendance: $e');
  //     rethrow;
  //   }
  // }

  /// Simplified initSheets method
  Future<bool> initSheets(String sheetId, String type) async {
    try {
      await init(sheetId);
      return true;
    } catch (e) {
      print('❌ Error initializing sheets: $e');
      return false;
    }
  }

  /// Update attendance record using Attendance model
  Future<bool> updateAttendanceDetails(Attendance updatedAttendance) async {
    print('🚀 Starting updateAttendanceDetails...');

    try {
      // Ensure spreadsheet is initialized
      if (_spreadsheet == null) {
        print('❌ Spreadsheet not initialized');
        return false;
      }

      // Find the attendance sheet
      if (_attandance == null) {
        print('❌ Attendance sheet not found');
        return false;
      }

      print('✅ Using attendance sheet: ${_attandance!.title}');

      // Find the row to update
      print('🔍 Searching for attendance record...');
      final rowIndex = await _findAttendanceRowIndex(
        updatedAttendance.phoneNumber,
        updatedAttendance.riderName,
        _attandance!,
      );

      if (rowIndex == null) {
        print('❌ Attendance record not found for update');
        return false;
      }

      print('✅ Found record at row: $rowIndex');

      // Calculate updates based on session duration and attendance status
      final now = DateTime.now();
      final currentDate = '${now.day}/${now.month}/${now.year}';

      int newFullDaysDone = updatedAttendance.fullDaysDone;
      int newHalfDaysDone = updatedAttendance.halfDaysDone;
      int newSessionsCompleted = updatedAttendance.sessionsCompleted;
      int newSessionsRemaining = updatedAttendance.sessionsRemaining;
      String newSessionDates = updatedAttendance.sessionDate;

      // Only update counters if attendance is Present
      if (updatedAttendance.attendanceStatus == 'Present') {
        if (updatedAttendance.sessionDuration == 'Full Day') {
          newFullDaysDone += 1;
          newSessionsCompleted += 1;
          print('➕ Incremented Full Days Done: $newFullDaysDone');
        } else if (updatedAttendance.sessionDuration == 'Half Day') {
          newHalfDaysDone += 1;
          newSessionsCompleted += 1;
          print('➕ Incremented Half Days Done: $newHalfDaysDone');
        }

        // Calculate remaining sessions
        newSessionsRemaining =
            updatedAttendance.totalSessions - newSessionsCompleted;
        print(
          '📊 Sessions Completed: $newSessionsCompleted, Remaining: $newSessionsRemaining',
        );

        // Add current date to session dates (comma separated) if not already present
        if (!newSessionDates.contains(currentDate)) {
          newSessionDates = newSessionDates.isEmpty
              ? currentDate
              : '$newSessionDates, $currentDate';
          print('📅 Updated session dates: $newSessionDates');
        }
      } else {
        print(
          'ℹ️ Attendance status is ${updatedAttendance.attendanceStatus}, skipping counter updates',
        );
      }

      // Prepare updated row data
      final updatedRow = [
         DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        updatedAttendance.riderName,
        updatedAttendance.phoneNumber,
        updatedAttendance.programBooked,
        newSessionDates, // Updated session dates
        newSessionsCompleted.toString(),
        updatedAttendance.totalSessions.toString(),
        updatedAttendance.attendanceStatus,
        updatedAttendance.sessionDuration,
        updatedAttendance.sessionCompletion,
        newSessionsCompleted.toString(),
        newFullDaysDone.toString(),
        newHalfDaysDone.toString(),
        newSessionsRemaining.toString(),
      ].map((e) => e?.toString() ?? '').toList();

      print('📝 Updated row data: $updatedRow');

      // Update the row in Google Sheets
      await _attandance!.values.insertRow(rowIndex, updatedRow);

      print(
        '✅ Successfully updated attendance for ${updatedAttendance.riderName}',
      );
      return true;
    } catch (e) {
      print('❌ Error updating attendance details: $e');
      return false;
    }
  }

  /// Helper method to find specific attendance row index
  Future<int?> _findAttendanceRowIndex(
    String phoneNumber,
    String riderName,
    Worksheet attendanceSheet,
  ) async {
    try {
      final allRows = await attendanceSheet.values.allRows();
      if (allRows.isEmpty) {
        print('   ❌ No rows found in attendance sheet');
        return null;
      }

      print('   📊 Total rows in sheet: ${allRows.length}');

      // Find column indexes
      final phoneCol = await _findColumnIndex('Phone Number', attendanceSheet);
      final nameCol = await _findColumnIndex('Rider Name', attendanceSheet);

      if (phoneCol == null || nameCol == null) {
        print('   ❌ Required columns not found');
        return null;
      }

      print('   📍 Column indexes - Phone: $phoneCol, Name: $nameCol');

      // Search through data rows (skip header row)
      for (int rowIndex = 1; rowIndex < allRows.length; rowIndex++) {
        final row = allRows[rowIndex];

        if (row.length > (phoneCol > nameCol ? phoneCol : nameCol)) {
          final currentPhone = row[phoneCol - 1]?.toString().trim() ?? '';
          final currentName = row[nameCol - 1]?.toString().trim() ?? '';

          if (currentPhone == phoneNumber && currentName == riderName) {
            print('   ✅ Matching record found at row: ${rowIndex + 1}');
            return rowIndex + 1; // +1 because sheets are 1-indexed
          }
        }
      }

      print('   ❌ No matching record found');
      return null;
    } catch (e) {
      print('   ❌ Error finding attendance row: $e');
      return null;
    }
  }
}

/// Extension for case-insensitive string comparison
extension StringExtensions on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
