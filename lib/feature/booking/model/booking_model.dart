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
  final List<String> paymentProof;
  final int riderAge;
  final String parentName;
  final String bookingType;
  final double receivedAmount;
  final String bookingStatus;
  final List<String> plannedDate;
  final String medicalCondition;
  final String accomdation;

  Booking({
    this.id,
    required this.timestamp,
    required this.riderName,
    required this.medicalCondition,
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
    required this.accomdation,
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
    required this.plannedDate,
    required this.bookingStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["_id"]?.toString(),
      timestamp: json["timestamp"]?.toString() ?? "",
      riderName: json["fullNameOfRider"] ?? "",
      medicalCondition: json['medicalCondition'] ?? "",
      phone: json["phoneNumber"] ?? "",
      programBooked: json["programBooked"] ?? "",
      programDetails: json["programDetails"] ?? "",
      accomdation: json['accomdation'] ?? "",
      bookingDate: json["bookingDate"] != null
          ? DateTime.parse(json["bookingDate"]).toIso8601String().split("T")[0]
          : "",
      preferredSessionDate: json["sessionDate"] != null
          ? DateTime.parse(json["sessionDate"]).toIso8601String().split("T")[0]
          : "",
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
      paymentProof: (json["paymentProof"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      riderAge: json["ageOfRider"] ?? 0,
      parentName: json["parentName"] ?? "",
      bookingType: json["bookingType"] ?? "Online",
      receivedAmount: (json["receivedAmount"] ?? 0).toDouble(),
      bookingStatus: json["bookingStatus"] ?? "",
      plannedDate: (json["plannedDate"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
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
      "accomdation": accomdation,
      "paymentStatus": paymentStatus,
      "amountPaid": amountPaid,
      "paymentMode": paymentMode,
      "paymentProof": paymentProof,
      "ageOfRider": riderAge,
      "parentName": parentName,
      "bookingType": bookingType,
      "receivedAmount": receivedAmount,
      "bookingStatus": bookingStatus,
      "plannedDate": plannedDate,
    };
  }

  static final nullBookingdata = Booking(
    timestamp: "",
    riderName: "",
    medicalCondition: "",
    phone: "",
    programBooked: "",
    programDetails: "",
    bookingDate: "",
    preferredSessionDate: "",
    trainingSlot: "",
    height: "",
    weight: "",
    shirtSize: "",
    pantSize: "",
    headSize: "",
    sessionType: "",
    accomdation: "",
    bikeRental: "",
    gearRental: "",
    totalFee: 0,
    paymentStatus: "",
    amountPaid: 0,
    paymentMode: "",
    paymentProof:[],
    riderAge: 0,
    parentName: "",
    bookingType: "",
    receivedAmount: 0,
    plannedDate: [],
    bookingStatus: "",
  );
}
