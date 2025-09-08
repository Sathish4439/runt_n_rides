class Lap {
  final int rideNumber;
  final List<String> lapTimes;
  final String totalDuration;
  final DateTime createdAt;

  Lap({
    required this.rideNumber,
    required this.lapTimes,
    required this.totalDuration,
    required this.createdAt,
  });

  factory Lap.fromJson(Map<String, dynamic> json) {
    return Lap(
      rideNumber: json['rideNumber'],
      lapTimes: List<String>.from(json['lapTimes']),
      totalDuration: json['totalDuration'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}