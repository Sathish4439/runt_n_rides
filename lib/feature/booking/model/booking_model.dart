import 'package:RUTSNRIDES/feature/ongoing/model/attandance_model.dart';

class PaymentDetails {
  final double receivedAmount; // Amount received for this payment
  final String paymentStatus; // "Pending", "Partially Paid", "Completed"
  final String paymentMode; // "Cash", "UPI", "Card", etc.
  final String paymentProof;
  final String? createAt; // Single proof file or URL

  PaymentDetails({
    required this.receivedAmount,
    required this.paymentStatus,
    required this.paymentMode,
    required this.paymentProof,
    this.createAt,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      receivedAmount: (json["receivedAmount"] ?? 0).toDouble(),
      paymentStatus: json["paymentStatus"] ?? "",
      paymentMode: json["paymentMode"] ?? "",
      createAt: json['createdAt'] ?? "",
      paymentProof: json["paymentProof"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "receivedAmount": receivedAmount,
      "paymentStatus": paymentStatus,
      "paymentMode": paymentMode,
      "paymentProof": paymentProof,
    };
  }

  static final empty = PaymentDetails(
    receivedAmount: 0,
    paymentStatus: "",
    paymentMode: "",
    paymentProof: "",
  );
}

class Booking {
  final String? id;
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
  final int riderAge;
  final String instagramProfile;
  final String parentName;
  final String bookingType;
  final String bookingStatus;
  final List<CompletedDate> plannedDate;
  final String medicalCondition;
  final String accomdation;

  // Root-level totals
  double totalFee; // Total fee for booking
  double totalPaid; // Sum of received amounts

  // Payment list
  List<PaymentDetails> payment;

  Booking({
    this.id,
    required this.timestamp,
    required this.riderName,
    required this.medicalCondition,
    required this.phone,
    required this.programBooked,
    required this.instagramProfile,
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
    required this.riderAge,
    required this.parentName,
    required this.bookingType,
    required this.plannedDate,
    required this.bookingStatus,
    required this.totalFee,
    required this.totalPaid,
    required this.payment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    List<PaymentDetails> paymentList = [];
    if (json["payment"] is List) {
      paymentList = (json["payment"] as List)
          .map((e) => PaymentDetails.fromJson(e))
          .toList();
    }

    double totalFee = (json["totalFee"] ?? 0).toDouble();
    double totalPaid = (json["totalPaid"] ?? 0).toDouble();

    // Calculate totalPaid if not present
    if (totalPaid == 0) {
      totalPaid = paymentList.fold(0, (sum, p) => sum + p.receivedAmount);
    }

    return Booking(
      id: json["_id"]?.toString(),
      timestamp: json["timestamp"]?.toString() ?? "",
      riderName: json["fullNameOfRider"] ?? "",
      medicalCondition: json['medicalCondition'] ?? "",
      phone: json["phoneNumber"] ?? "",
      programBooked: json["programBooked"] ?? "",
      programDetails: json["programDetails"] ?? "",
      accomdation: json['accomdation'] ?? "",
      bookingDate: json["bookingDate"] ?? "",
      preferredSessionDate: json["sessionDate"] ?? "",
      trainingSlot: json["trainingSlot"] ?? "",
      instagramProfile: json['instagramProfile'],
      height: json["height"] ?? "",
      weight: json["weight"] ?? "",
      shirtSize: json["shirtSize"] ?? "",
      pantSize: json["pantSize"] ?? "",
      headSize: json["headSize"] ?? "",
      sessionType: json["sessionType"] ?? "",
      bikeRental: json["bikeRental"] ?? "",
      gearRental: json["gearRental"] ?? "",
      riderAge: json["ageOfRider"] ?? 0,
      parentName: json["parentName"] ?? "",
      bookingType: json["bookingType"] ?? "Online",
      bookingStatus: json["bookingStatus"] ?? "",
      plannedDate:
          (json['plannedDate'] as List?)
              ?.map((e) => CompletedDate.fromJson(e))
              .toList() ??
          [],
      payment: paymentList,
      totalFee: totalFee,
      totalPaid: totalPaid,
    );
  }

  /// ---------------------------
  /// Serialize to JSON
  /// ---------------------------
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "timestamp": timestamp,
      "fullNameOfRider": riderName,
      "medicalCondition": medicalCondition,
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
      "accomdation": accomdation,
      "bikeRental": bikeRental,
      "gearRental": gearRental,
      "ageOfRider": riderAge,
      "parentName": parentName,
      "bookingType": bookingType,
      "bookingStatus": bookingStatus,
      "plannedDate": plannedDate.map((e) => e.toJson()).toList(),
      "payment": payment.map((e) => e.toJson()).toList(),
      "totalFee": totalFee,
      "totalPaid": totalPaid,
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
    riderAge: 0,
    parentName: "",
    bookingType: "",
    plannedDate: [],
    bookingStatus: "",
    payment: [],
    totalFee: 0,
    totalPaid: 0,
    instagramProfile: "",
  );
}
