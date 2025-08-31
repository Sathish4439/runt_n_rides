class Lead {
  String timestamp; // Original Sheets timestamp
  DateTime timestampDate; // Converted DateTime
  String fullName;
  int age;
  String whatsapp;
  String programInterest;
  String bikeRental;
  String gearRental;
  String medicalCondition;
  String medicalDetails;
  String contactAvailability;
  String accommodation;
  String column1; // from Column 12
  String status;
  String followUpDate;
  String followUpNotes;

  Lead({
    required this.timestamp,
    required this.timestampDate,
    required this.fullName,
    required this.age,
    required this.whatsapp,
    required this.programInterest,
    required this.bikeRental,
    required this.gearRental,
    required this.medicalCondition,
    required this.medicalDetails,
    required this.contactAvailability,
    required this.accommodation,
    required this.column1,
    this.status = '',
    this.followUpDate = '',
    this.followUpNotes = '',
  });

  /// Convert Google Sheets numeric timestamp to DateTime
  static DateTime parseSheetsTimestamp(String value) {
    double number = double.tryParse(value) ?? 0;
    DateTime epoch = DateTime(1899, 12, 30);
    return epoch.add(
      Duration(
        days: number.floor(),
        milliseconds: ((number - number.floor()) * 24 * 60 * 60 * 1000).round(),
      ),
    );
  }

  /// Create Lead from Google Sheets row
 factory Lead.fromList(List<dynamic> row) {
  String ts = row.isNotEmpty ? row[0].toString() : '';
  String status = row.length > 12 ? row[12].toString().trim() : '';
  if (status.isEmpty) status = 'Lead'; // Default status

  String followUpDate = row.length > 13 ? row[13].toString().trim() : '';
  String followUpNotes = row.length > 14 ? row[14].toString().trim() : '';

  return Lead(
    timestamp: ts,
    timestampDate: ts.isNotEmpty
        ? Lead.parseSheetsTimestamp(ts)
        : DateTime.now(),
    fullName: row.length > 1 ? row[1].toString().trim() : '',
    age: row.length > 2 ? int.tryParse(row[2].toString()) ?? 0 : 0,
    whatsapp: row.length > 3 ? row[3].toString().trim() : '',
    programInterest: row.length > 4 ? row[4].toString().trim() : '',
    bikeRental: row.length > 5 ? row[5].toString().trim() : '',
    gearRental: row.length > 6 ? row[6].toString().trim() : '',
    medicalCondition: row.length > 7 ? row[7].toString().trim() : '',
    medicalDetails: row.length > 8 ? row[8].toString().trim() : '',
    contactAvailability: row.length > 9 ? row[9].toString().trim() : '',
    accommodation: row.length > 10 ? row[10].toString().trim() : '',
    column1: row.length > 11 ? row[11].toString().trim() : '',
    status: status,
    followUpDate: followUpDate,
    followUpNotes: followUpNotes,
  );
}

  /// Create Lead from JSON
  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      timestamp: json['timestamp'] ?? '',
      timestampDate: json['timestampDate'] != null
          ? DateTime.tryParse(json['timestampDate']) ?? DateTime.now()
          : DateTime.now(),
      fullName: json['fullName'] ?? '',
      age: json['age'] ?? 0,
      whatsapp: json['whatsapp'] ?? '',
      programInterest: json['programInterest'] ?? '',
      bikeRental: json['bikeRental'] ?? '',
      gearRental: json['gearRental'] ?? '',
      medicalCondition: json['medicalCondition'] ?? '',
      medicalDetails: json['medicalDetails'] ?? '',
      contactAvailability: json['contactAvailability'] ?? '',
      accommodation: json['accommodation'] ?? '',
      column1: json['column1'] ?? '',
      status: json['status'] ?? 'Lead',
      followUpDate: json['followUpDate'] ?? '',
      followUpNotes: json['followUpNotes'] ?? '',
    );
  }

  /// Convert Lead to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'timestampDate': timestampDate.toIso8601String(),
      'fullName': fullName,
      'age': age,
      'whatsapp': whatsapp,
      'programInterest': programInterest,
      'bikeRental': bikeRental,
      'gearRental': gearRental,
      'medicalCondition': medicalCondition,
      'medicalDetails': medicalDetails,
      'contactAvailability': contactAvailability,
      'accommodation': accommodation,
      'column1': column1,
      'status': status,
      'followUpDate': followUpDate,
      'followUpNotes': followUpNotes,
    };
  }
  
}
