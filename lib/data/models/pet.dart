import 'dart:convert';

import 'package:flutter_pet_care_and_veterinary_app/data/models/medical_record.dart';

class Pet {
  final String id;
  final String name;
  final int age;
  final String breed;
  final String gender;
  final String? photoPath;
  final List<MedicalRecord> medicalHistory;

  Pet({
    required this.id,
    required this.name,
    required this.age,
    required this.breed,
    required this.gender,
    this.photoPath,
    required this.medicalHistory,
  });

  Pet copyWith({
    String? id,
    String? name,
    int? age,
    String? breed,
    String? gender,
    String? photoPath,
    List<MedicalRecord>? medicalHistory,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      photoPath: photoPath ?? this.photoPath,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'breed': breed,
      'gender': gender,
      'photoPath': photoPath,
      'medicalHistory': medicalHistory.map((x) => x.toMap()).toList(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      photoPath: map['photoPath'],
      medicalHistory: List<MedicalRecord>.from(
        map['medicalHistory']?.map((x) => MedicalRecord.fromMap(x)) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pet.fromJson(String source) => Pet.fromMap(json.decode(source));
}
