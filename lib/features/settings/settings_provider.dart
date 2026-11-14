import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/settings_service.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettingsData>((ref) {
  final service = ref.read(settingsServiceProvider);
  return SettingsNotifier(service);
});

class SettingsNotifier extends StateNotifier<AppSettingsData> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(AppSettingsData()) {
    _init();
  }

  Future<void> _init() async {
    final loaded = await _service.loadSettings();
    state = loaded;
  }

  Future<void> updateSettings(AppSettingsData updated) async {
    state = updated;
    await _service.saveSettings(updated);
  }

  void toggleSound(bool val) => updateSettings(state.copyWith(soundEnabled: val));
  void setVolume(double val) => updateSettings(state.copyWith(volumeLevel: val));
  void toggleVibration(bool val) => updateSettings(state.copyWith(vibrationEnabled: val));
  void toggleQuietHours(bool val) => updateSettings(state.copyWith(quietHoursEnabled: val));
  void setQuietHours(int start, int end) =>
      updateSettings(state.copyWith(quietHoursStart: start, quietHoursEnd: end));
  void toggleDarkMode(bool val) => updateSettings(state.copyWith(darkMode: val));
  void setLanguage(String code) => updateSettings(state.copyWith(languageCode: code));
}
