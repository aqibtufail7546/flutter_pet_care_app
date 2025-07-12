import 'dart:convert';

class Appointment {
  final String id;
  final String petId;
  final String petName;
  final DateTime dateTime;
  final String reason;
  final String veterinarian;
  final String clinic;
  final String notes;

  Appointment({
    required this.id,
    required this.petId,
    required this.petName,
    required this.dateTime,
    required this.reason,
    required this.veterinarian,
    required this.clinic,
    required this.notes,
  });

  Appointment copyWith({
    String? id,
    String? petId,
    String? petName,
    DateTime? dateTime,
    String? reason,
    String? veterinarian,
    String? clinic,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      dateTime: dateTime ?? this.dateTime,
      reason: reason ?? this.reason,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'reason': reason,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      reason: map['reason'] ?? '',
      veterinarian: map['veterinarian'] ?? '',
      clinic: map['clinic'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Appointment.fromJson(String source) =>
      Appointment.fromMap(json.decode(source));
}
