import 'package:flutter_pet_care_and_veterinary_app/data/models/appointment.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/emergency_contact.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/pet.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _petsKey = 'pets';
  static const String _appointmentsKey = 'appointments';
  static const String _remindersKey = 'reminders';
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Onboarding
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(_onboardingKey, completed);
  }

  bool getOnboardingCompleted() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  // Theme
  Future<bool> setThemeMode(String mode) async {
    return await _prefs.setString(_themeModeKey, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  // Pets
  Future<bool> savePets(List<Pet> pets) async {
    final List<String> petJsonList = pets.map((pet) => pet.toJson()).toList();
    return await _prefs.setStringList(_petsKey, petJsonList);
  }

  List<Pet> getPets() {
    final List<String>? petJsonList = _prefs.getStringList(_petsKey);
    if (petJsonList == null) return [];
    return petJsonList.map((json) => Pet.fromJson(json)).toList();
  }

  // Appointments
  Future<bool> saveAppointments(List<Appointment> appointments) async {
    final List<String> appointmentJsonList =
        appointments.map((appointment) => appointment.toJson()).toList();
    return await _prefs.setStringList(_appointmentsKey, appointmentJsonList);
  }

  List<Appointment> getAppointments() {
    final List<String>? appointmentJsonList = _prefs.getStringList(
      _appointmentsKey,
    );
    if (appointmentJsonList == null) return [];
    return appointmentJsonList
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  // Reminders
  Future<bool> saveReminders(List<Reminder> reminders) async {
    final List<String> reminderJsonList =
        reminders.map((reminder) => reminder.toJson()).toList();
    return await _prefs.setStringList(_remindersKey, reminderJsonList);
  }

  List<Reminder> getReminders() {
    final List<String>? reminderJsonList = _prefs.getStringList(_remindersKey);
    if (reminderJsonList == null) return [];
    return reminderJsonList.map((json) => Reminder.fromJson(json)).toList();
  }

  // Emergency Contacts
  Future<bool> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final List<String> contactJsonList =
        contacts.map((contact) => contact.toJson()).toList();
    return await _prefs.setStringList(_emergencyContactsKey, contactJsonList);
  }

  List<EmergencyContact> getEmergencyContacts() {
    final List<String>? contactJsonList = _prefs.getStringList(
      _emergencyContactsKey,
    );
    if (contactJsonList == null) return [];
    return contactJsonList
        .map((json) => EmergencyContact.fromJson(json))
        .toList();
  }

  // Clear all data
  Future<bool> clearAllData() async {
    await _prefs.remove(_petsKey);
    await _prefs.remove(_appointmentsKey);
    await _prefs.remove(_remindersKey);
    await _prefs.remove(_emergencyContactsKey);
    return true;
  }
}
