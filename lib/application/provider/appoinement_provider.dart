import 'package:flutter_pet_care_and_veterinary_app/data/datasources/local/storage_service.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/appointment.dart';
import 'package:flutter_pet_care_and_veterinary_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, List<Appointment>>((ref) {
      final storage = ref.watch(storageServiceProvider);
      return AppointmentsNotifier(storage);
    });

class AppointmentsNotifier extends StateNotifier<List<Appointment>> {
  final StorageService _storage;

  AppointmentsNotifier(this._storage) : super([]) {
    state = _storage.getAppointments();
  }

  void addAppointment(Appointment appointment) {
    state = [...state, appointment];
    _storage.saveAppointments(state);
  }

  void updateAppointment(Appointment updatedAppointment) {
    state =
        state.map((appointment) {
          return appointment.id == updatedAppointment.id
              ? updatedAppointment
              : appointment;
        }).toList();
    _storage.saveAppointments(state);
  }

  void deleteAppointment(String appointmentId) {
    state =
        state.where((appointment) => appointment.id != appointmentId).toList();
    _storage.saveAppointments(state);
  }
}
