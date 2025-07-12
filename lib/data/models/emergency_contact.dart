import 'dart:convert';

enum ReminderType {
  medication,
  vaccination,
  grooming,
  checkup,
  feeding,
  appointment,
  exercise,
  other,
  veterinary,
}

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final bool isDefault;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.isDefault,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    bool? isDefault,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'isDefault': isDefault,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmergencyContact.fromJson(String source) =>
      EmergencyContact.fromMap(json.decode(source));
}
