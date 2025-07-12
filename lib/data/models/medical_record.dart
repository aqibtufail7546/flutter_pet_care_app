import 'dart:convert';

class MedicalRecord {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String veterinarian;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.veterinarian,
  });

  MedicalRecord copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? veterinarian,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      veterinarian: veterinarian ?? this.veterinarian,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'veterinarian': veterinarian,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      veterinarian: map['veterinarian'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicalRecord.fromJson(String source) =>
      MedicalRecord.fromMap(json.decode(source));
}
