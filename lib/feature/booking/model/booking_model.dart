class Booking {
  final String timestamp;
  final String riderName;
  final String phone;
  final String programBooked;
  final String programDetails;
  final String bookingDate;
  final String preferredSessionDate;
  final String trainingSlot;
  final String sessionType;
  final String bikeRental;
  final String gearRental;
  final double totalFee;
  final String paymentStatus;
  final double amountPaid;
  final String paymentMode;
  final String paymentProof;
  final int riderAge;
  final String parentName;
  final String bookingType;
  final double receivedAmount;
  final String bookingStatus;
  final String trainingStarted;

  Booking({
    required this.timestamp,
    required this.riderName,
    required this.phone,
    required this.programBooked,
    required this.programDetails,
    required this.bookingDate,
    required this.preferredSessionDate,
    required this.trainingSlot,
    required this.sessionType,
    required this.bikeRental,
    required this.gearRental,
    required this.totalFee,
    required this.paymentStatus,
    required this.amountPaid,
    required this.paymentMode,
    required this.paymentProof,
    required this.riderAge,
    required this.parentName,
    required this.bookingType,
    required this.receivedAmount,
    required this.bookingStatus,
    required this.trainingStarted,
  });

  factory Booking.fromList(List<dynamic> row) {
    final safeRow = List<String>.generate(22, (i) {
      if (i < row.length && row[i] != null) {
        return row[i].toString().trim();
      }
      return '';
    });

    double parseCurrency(String value) {
      final cleaned = value.replaceAll(',', '');
      final matches = RegExp(r'\d+(\.\d+)?').allMatches(cleaned);
      return matches.isNotEmpty
          ? double.tryParse(matches.last.group(0)!) ?? 0.0
          : 0.0;
    }

    int parseInt(String value) => int.tryParse(value) ?? 0;

    return Booking(
      timestamp: safeRow[0],
      riderName: safeRow[1],
      phone: safeRow[2],
      programBooked: safeRow[3],
      programDetails: safeRow[4],
      bookingDate: safeRow[5],
      preferredSessionDate: safeRow[6],
      trainingSlot: safeRow[7],
      sessionType: safeRow[8],
      bikeRental: safeRow[9],
      gearRental: safeRow[10],
      totalFee: parseCurrency(safeRow[11]),
      paymentStatus: safeRow[12],
      amountPaid: parseCurrency(safeRow[13]),
      paymentMode: safeRow[14],
      paymentProof: safeRow[15],
      riderAge: parseInt(safeRow[16]),
      parentName: safeRow[17],
      bookingType: safeRow[18],
      receivedAmount: parseCurrency(safeRow[19]),
      bookingStatus: safeRow[20],
      trainingStarted: safeRow[21],
    );
  }

  List<String> toList() {
    return [
      timestamp,
      riderName,
      phone,
      programBooked,
      programDetails,
      bookingDate,
      preferredSessionDate,
      trainingSlot,
      sessionType,
      bikeRental,
      gearRental,
      totalFee.toString(),
      paymentStatus,
      amountPaid.toString(),
      paymentMode,
      paymentProof,
      riderAge.toString(),
      parentName,
      bookingType,
      receivedAmount.toString(),
      bookingStatus,
      trainingStarted,
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      "Timestamp": timestamp,
      "Full Name of Rider": riderName,
      "Phone Number": phone,
      "Program Booked": programBooked,
      "Program details": programDetails,
      "Booking Date": bookingDate,
      "Session Date (Preferred Date)": preferredSessionDate,
      "Training Slot": trainingSlot,
      "Group or Private Session": sessionType,
      "Bike Rental Required?": bikeRental,
      "Gear Set Rental Required?": gearRental,
      "Total Program Fee (₹)": totalFee,
      "Payment Status": paymentStatus,
      "Amount Paid (₹)": amountPaid,
      "Payment Mode": paymentMode,
      "Proof for the payment": paymentProof,
      "Age of the Rider": riderAge,
      "Parent's Name": parentName,
      "Booking Type": bookingType,
      "Received Amount": receivedAmount,
      "Booking Status": bookingStatus,
      "Training Started": trainingStarted,
    };
  }

  /// Pretty print booking with header → value
  void printBooking() {
    final data = toJson();
    print("------ Booking Details ------");
    data.forEach((key, value) {
      print("$key: $value");
    });
    print("-----------------------------");
  }
}
