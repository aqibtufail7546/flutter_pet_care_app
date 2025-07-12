import 'package:flutter_pet_care_and_veterinary_app/data/datasources/local/storage_service.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/medical_record.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/pet.dart';
import 'package:flutter_pet_care_and_veterinary_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final petsProvider = StateNotifierProvider<PetsNotifier, List<Pet>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PetsNotifier(storage);
});

class PetsNotifier extends StateNotifier<List<Pet>> {
  final StorageService _storage;

  PetsNotifier(this._storage) : super([]) {
    state = _storage.getPets();
  }

  void addPet(Pet pet) {
    state = [...state, pet];
    _storage.savePets(state);
  }

  void updatePet(Pet updatedPet) {
    state =
        state.map((pet) {
          return pet.id == updatedPet.id ? updatedPet : pet;
        }).toList();
    _storage.savePets(state);
  }

  void deletePet(String petId) {
    state = state.where((pet) => pet.id != petId).toList();
    _storage.savePets(state);
  }

  void addMedicalRecord(String petId, MedicalRecord record) {
    state =
        state.map((pet) {
          if (pet.id == petId) {
            return pet.copyWith(
              medicalHistory: [...pet.medicalHistory, record],
            );
          }
          return pet;
        }).toList();
    _storage.savePets(state);
  }

  void updateMedicalRecord(String petId, MedicalRecord updatedRecord) {
    state =
        state.map((pet) {
          if (pet.id == petId) {
            final updatedHistory =
                pet.medicalHistory.map((record) {
                  return record.id == updatedRecord.id ? updatedRecord : record;
                }).toList();
            return pet.copyWith(medicalHistory: updatedHistory);
          }
          return pet;
        }).toList();
    _storage.savePets(state);
  }

  void deleteMedicalRecord(String petId, String recordId) {
    state =
        state.map((pet) {
          if (pet.id == petId) {
            final updatedHistory =
                pet.medicalHistory
                    .where((record) => record.id != recordId)
                    .toList();
            return pet.copyWith(medicalHistory: updatedHistory);
          }
          return pet;
        }).toList();
    _storage.savePets(state);
  }
}
