class TrainingProgram {
  final int id;
  final String name;
  final String? title;
  final List<String> durations; // multiple duration options
  final List<String> sessionTypes; // e.g. ["Group", "Private"]

  TrainingProgram({
    required this.id,
    required this.name,
    required this.durations,
    required this.sessionTypes,
    this.title
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      durations: List<String>.from(json['durations'] ?? []),
      sessionTypes: List<String>.from(json['sessionTypes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "durations": durations,
      "sessionTypes": sessionTypes,
      "title":title 
    };
  }

  static final nullTrainingProgram = TrainingProgram(
    id: 0,
    name: "NA",
    durations: [],
    sessionTypes: [],
    title: ""

  );
}
