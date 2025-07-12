// import 'package:flutter_pet_care_and_veterinary_app/data/datasources/local/storage_service.dart';
// import 'package:flutter_pet_care_and_veterinary_app/data/models/emergency_contact.dart';
// import 'package:flutter_pet_care_and_veterinary_app/main.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// final emergencyContactsProvider =
//     StateNotifierProvider<EmergencyContactsNotifier, List<EmergencyContact>>((
//       ref,
//     ) {
//       final storage = ref.watch(storageServiceProvider);
//       return EmergencyContactsNotifier(storage);
//     });

// class EmergencyContactsNotifier extends StateNotifier<List<EmergencyContact>> {
//   final StorageService _storage;

//   EmergencyContactsNotifier(this._storage) : super([]) {
//     state = _storage.getEmergencyContacts();
//   }

//   void addEmergencyContact(EmergencyContact contact) {
//     state = [...state, contact];
//     _storage.saveEmergencyContacts(state);
//   }

//   void updateEmergencyContact(EmergencyContact updatedContact) {
//     state =
//         state.map((contact) {
//           return contact.id == updatedContact.id ? updatedContact : contact;
//         }).toList();
//     _storage.saveEmergencyContacts(state);
//   }

//   void deleteEmergencyContact(String contactId) {
//     state = state.where((contact) => contact.id != contactId).toList();
//     _storage.saveEmergencyContacts(state);
//   }

//   void setDefaultContact(String contactId) {
//     state =
//         state.map((contact) {
//           return contact.copyWith(isDefault: contact.id == contactId);
//         }).toList();
//     _storage.saveEmergencyContacts(state);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/emergency_contact.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/first_aid_guide.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/veterinary_clinic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final emergencyContactsProvider = Provider<List<EmergencyContact>>((ref) {
  return [
    EmergencyContact(
      id: "1",
      name: "Pet Emergency Hotline",
      phone: "1-800-PET-HELP",
      address: "National Emergency Service",
      email: "emergency@pethelp.com",
      isDefault: true,
    ),
    EmergencyContact(
      id: "2",
      name: "Animal Poison Control",
      phone: "1-888-426-4435",
      address: "ASPCA Poison Control Center",
      email: "poison@aspca.org",
      isDefault: true,
    ),
    EmergencyContact(
      id: "3",
      name: "Dr. Sarah Johnson",
      phone: "555-0123",
      address: "123 Veterinary Lane, City Center",
      email: "dr.johnson@vetclinic.com",
      isDefault: false,
    ),
    EmergencyContact(
      id: "4",
      name: "Emergency Vet Clinic",
      phone: "555-0456",
      address: "456 Emergency Blvd, Downtown",
      email: "info@emergencyvet.com",
      isDefault: true,
    ),
    EmergencyContact(
      id: "5",
      name: "24/7 Pet Hospital",
      phone: "555-0789",
      address: "789 Medical Center Dr, Uptown",
      email: "contact@24pethosp.com",
      isDefault: false,
    ),
  ];
});

final nearbyClinicsProvider = Provider<List<VeterinaryClinic>>((ref) {
  return [
    VeterinaryClinic(
      name: "City Emergency Veterinary Hospital",
      address: "123 Main St, Downtown",
      phone: "555-0789",
      distance: 0.8,
      isOpen: true,
      rating: 4.8,
    ),
    VeterinaryClinic(
      name: "Animal Care Center",
      address: "456 Oak Ave, Midtown",
      phone: "555-0321",
      distance: 1.2,
      isOpen: true,
      rating: 4.6,
    ),
    VeterinaryClinic(
      name: "Pet Medical Center",
      address: "789 Pine Rd, Uptown",
      phone: "555-0654",
      distance: 2.1,
      isOpen: false,
      rating: 4.7,
    ),
  ];
});

final firstAidGuidesProvider = Provider<List<FirstAidGuide>>((ref) {
  return [
    FirstAidGuide(
      title: "Choking",
      description: "Pet is unable to breathe or making choking sounds",
      icon: Icons.warning_amber,
      steps: [
        "Stay calm and restrain your pet safely",
        "Open the mouth and look for visible objects",
        "Use tweezers to remove visible objects carefully",
        "For small pets: Hold upside down and pat back firmly",
        "For large pets: Lift hind legs, push firmly behind last rib",
        "Check mouth again and remove any dislodged objects",
        "Get to vet immediately even if object is removed",
      ],
    ),
    FirstAidGuide(
      title: "Bleeding",
      description: "Heavy bleeding from cuts or wounds",
      icon: Icons.bloodtype,
      steps: [
        "Apply direct pressure with clean cloth",
        "Elevate the wound above heart level if possible",
        "Do not remove embedded objects",
        "Wrap with bandage, don't wrap too tightly",
        "Apply pressure above and below wound if bleeding continues",
        "Get to vet immediately for severe bleeding",
      ],
    ),
    FirstAidGuide(
      title: "Poisoning",
      description: "Pet has ingested toxic substances",
      icon: Icons.local_hospital,
      steps: [
        "Remove pet from source of poison",
        "Do NOT induce vomiting unless instructed by vet",
        "Collect poison container/substance for vet",
        "Call poison control hotline immediately",
        "Follow their specific instructions",
        "Get to vet immediately with poison information",
      ],
    ),
    FirstAidGuide(
      title: "Heatstroke",
      description: "Pet is overheated and showing distress",
      icon: Icons.device_thermostat,
      steps: [
        "Move pet to cool, shaded area immediately",
        "Apply cool (not cold) water to paw pads and belly",
        "Offer small amounts of cool water to drink",
        "Use fan to increase air circulation",
        "Place cool wet towels on neck and armpits",
        "Monitor temperature and get to vet quickly",
      ],
    ),
  ];
});
