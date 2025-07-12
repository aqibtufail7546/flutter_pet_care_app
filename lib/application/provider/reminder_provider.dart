import 'package:flutter_pet_care_and_veterinary_app/data/datasources/local/storage_service.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/reminder.dart';
import 'package:flutter_pet_care_and_veterinary_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
      final storage = ref.watch(storageServiceProvider);
      return RemindersNotifier(storage);
    });

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  final StorageService _storage;

  RemindersNotifier(this._storage) : super([]) {
    state = _storage.getReminders();
  }

  void addReminder(Reminder reminder) {
    state = [...state, reminder];
    _storage.saveReminders(state);
  }

  void updateReminder(Reminder updatedReminder) {
    state =
        state.map((reminder) {
          return reminder.id == updatedReminder.id ? updatedReminder : reminder;
        }).toList();
    _storage.saveReminders(state);
  }

  void deleteReminder(String reminderId) {
    state = state.where((reminder) => reminder.id != reminderId).toList();
    _storage.saveReminders(state);
  }

  void toggleReminderCompleted(String reminderId) {
    state =
        state.map((reminder) {
          if (reminder.id == reminderId) {
            return reminder.copyWith(isCompleted: !reminder.isCompleted);
          }
          return reminder;
        }).toList();
    _storage.saveReminders(state);
  }
}
