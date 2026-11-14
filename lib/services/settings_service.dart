import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsData {
  final bool soundEnabled;
  final double volumeLevel;
  final bool vibrationEnabled;
  final bool quietHoursEnabled;
  final int quietHoursStart; // 0-23
  final int quietHoursEnd; // 0-23
  final bool darkMode;
  final String languageCode; // 'en' or 'ar'

  AppSettingsData({
    this.soundEnabled = true,
    this.volumeLevel = 1.0,
    this.vibrationEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
    this.darkMode = false,
    this.languageCode = 'en',
  });

  AppSettingsData copyWith({
    bool? soundEnabled,
    double? volumeLevel,
    bool? vibrationEnabled,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
    bool? darkMode,
    String? languageCode,
  }) {
    return AppSettingsData(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volumeLevel: volumeLevel ?? this.volumeLevel,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      darkMode: darkMode ?? this.darkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class SettingsService {
  static const String _keySound = 'setting_sound_enabled';
  static const String _keyVolume = 'setting_volume_level';
  static const String _keyVibration = 'setting_vibration_enabled';
  static const String _keyQuietHours = 'setting_quiet_hours_enabled';
  static const String _keyQuietStart = 'setting_quiet_hours_start';
  static const String _keyQuietEnd = 'setting_quiet_hours_end';
  static const String _keyDarkMode = 'setting_dark_mode';
  static const String _keyLanguage = 'setting_language_code';

  Future<AppSettingsData> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsData(
      soundEnabled: prefs.getBool(_keySound) ?? true,
      volumeLevel: prefs.getDouble(_keyVolume) ?? 1.0,
      vibrationEnabled: prefs.getBool(_keyVibration) ?? true,
      quietHoursEnabled: prefs.getBool(_keyQuietHours) ?? false,
      quietHoursStart: prefs.getInt(_keyQuietStart) ?? 22,
      quietHoursEnd: prefs.getInt(_keyQuietEnd) ?? 7,
      darkMode: prefs.getBool(_keyDarkMode) ?? false,
      languageCode: prefs.getString(_keyLanguage) ?? 'en',
    );
  }

  Future<void> saveSettings(AppSettingsData settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, settings.soundEnabled);
    await prefs.setDouble(_keyVolume, settings.volumeLevel);
    await prefs.setBool(_keyVibration, settings.vibrationEnabled);
    await prefs.setBool(_keyQuietHours, settings.quietHoursEnabled);
    await prefs.setInt(_keyQuietStart, settings.quietHoursStart);
    await prefs.setInt(_keyQuietEnd, settings.quietHoursEnd);
    await prefs.setBool(_keyDarkMode, settings.darkMode);
    await prefs.setString(_keyLanguage, settings.languageCode);
  }
}
