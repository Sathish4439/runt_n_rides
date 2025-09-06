class Booking {
  final String? id; // MongoDB document _id
  final String timestamp;
  final String riderName;
  final String phone;
  final String programBooked;
  final String programDetails;
  final String bookingDate;
  final String preferredSessionDate;
  final String trainingSlot;
  final String height;
  final String weight;
  final String shirtSize;
  final String pantSize;
  final String headSize;
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

  Booking({
    this.id,
    required this.timestamp,
    required this.riderName,
    required this.phone,
    required this.programBooked,
    required this.programDetails,
    required this.bookingDate,
    required this.preferredSessionDate,
    required this.trainingSlot,
    required this.height,
    required this.weight,
    required this.shirtSize,
    required this.pantSize,
    required this.headSize,
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
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["_id"]?.toString(),
      timestamp: json["timestamp"] ?? "",
      riderName: json["fullNameOfRider"] ?? "",
      phone: json["phoneNumber"] ?? "",
      programBooked: json["programBooked"] ?? "",
      programDetails: json["programDetails"] ?? "",
      bookingDate: json["bookingDate"] ?? "",
      preferredSessionDate: json["sessionDate"] ?? "",
      trainingSlot: json["trainingSlot"] ?? "",
      height: json["height"] ?? "",
      weight: json["weight"] ?? "",
      shirtSize: json["shirtSize"] ?? "",
      pantSize: json["pantSize"] ?? "",
      headSize: json["headSize"] ?? "",
      sessionType: json["sessionType"] ?? "",
      bikeRental: json["bikeRental"] ?? "",
      gearRental: json["gearRental"] ?? "",
      totalFee: (json["totalProgramFee"] ?? 0).toDouble(),
      paymentStatus: json["paymentStatus"] ?? "",
      amountPaid: (json["amountPaid"] ?? 0).toDouble(),
      paymentMode: json["paymentMode"] ?? "",
      paymentProof: json["paymentProof"] ?? "",
      riderAge: json["ageOfRider"] ?? 0,
      parentName: json["parentName"] ?? "",
      bookingType: json["bookingType"] ?? "",
      receivedAmount: (json["receivedAmount"] ?? 0).toDouble(),
      bookingStatus: json["bookingStatus"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp,
      "fullNameOfRider": riderName,
      "phoneNumber": phone,
      "programBooked": programBooked,
      "programDetails": programDetails,
      "bookingDate": bookingDate,
      "sessionDate": preferredSessionDate,
      "trainingSlot": trainingSlot,
      "height": height,
      "weight": weight,
      "shirtSize": shirtSize,
      "pantSize": pantSize,
      "headSize": headSize,
      "sessionType": sessionType,
      "bikeRental": bikeRental,
      "gearRental": gearRental,
      "totalProgramFee": totalFee,
      "paymentStatus": paymentStatus,
      "amountPaid": amountPaid,
      "paymentMode": paymentMode,
      "paymentProof": paymentProof,
      "ageOfRider": riderAge,
      "parentName": parentName,
      "bookingType": bookingType,
      "receivedAmount": receivedAmount,
      "bookingStatus": bookingStatus,
    };
  }
}
