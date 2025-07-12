import 'package:flutter_pet_care_and_veterinary_app/data/datasources/local/storage_service.dart';
import 'package:flutter_pet_care_and_veterinary_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  final storage = ref.watch(storageServiceProvider);
  return OnboardingNotifier(storage);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final StorageService _storage;

  OnboardingNotifier(this._storage) : super(false) {
    state = _storage.getOnboardingCompleted();
  }

  void completeOnboarding() {
    state = true;
    _storage.setOnboardingCompleted(true);
  }
}
