import 'dart:convert';

import 'package:flutter_pet_care_and_veterinary_app/data/models/emergency_contact.dart';

class Reminder {
  final String id;
  final String petId;
  final String petName;
  final String title;
  final String description;
  final DateTime dateTime;
  final ReminderType type;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.petId,
    required this.petName,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    required this.isCompleted,
  });

  Reminder copyWith({
    String? id,
    String? petId,
    String? petName,
    String? title,
    String? description,
    DateTime? dateTime,
    ReminderType? type,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'title': title,
      'description': description,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'type': type.name,
      'isCompleted': isCompleted,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.medication,
      ),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reminder.fromJson(String source) =>
      Reminder.fromMap(json.decode(source));
}
