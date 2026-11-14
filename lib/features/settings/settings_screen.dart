// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final strings = AppStrings(settings.languageCode);

    return Directionality(
      textDirection: settings.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.get('settings')),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Sound & Volume Section
            _SectionHeader(title: strings.get('sound')),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded, color: Colors.pink),
              title: Text(strings.get('sound')),
              subtitle: Text(strings.get('sound_desc')),
              value: settings.soundEnabled,
              activeColor: Colors.pink,
              onChanged: notifier.toggleSound,
            ),
            if (settings.soundEnabled) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(strings.get('volume')),
                    Expanded(
                      child: Slider(
                        value: settings.volumeLevel,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.pink,
                        onChanged: notifier.setVolume,
                      ),
                    ),
                    Text('${(settings.volumeLevel * 100).toInt()}%'),
                  ],
                ),
              ),
            ],
            const Divider(),

            // Vibration Section
            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded, color: Colors.pink),
              title: Text(strings.get('vibration')),
              subtitle: Text(strings.get('vibration_desc')),
              value: settings.vibrationEnabled,
              activeColor: Colors.pink,
              onChanged: notifier.toggleVibration,
            ),
            const Divider(),

            // Quiet Hours Section
            _SectionHeader(title: strings.get('quiet_hours')),
            SwitchListTile(
              secondary: const Icon(Icons.bedtime_rounded, color: Colors.pink),
              title: Text(strings.get('quiet_hours')),
              subtitle: Text(
                settings.quietHoursEnabled
                    ? 'Active: ${settings.quietHoursStart}:00 - ${settings.quietHoursEnd}:00'
                    : strings.get('quiet_hours_desc'),
              ),
              value: settings.quietHoursEnabled,
              activeColor: Colors.pink,
              onChanged: notifier.toggleQuietHours,
            ),
            const Divider(),

            // Appearance & Theme Section
            _SectionHeader(title: 'Appearance'),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded, color: Colors.pink),
              title: Text(strings.get('dark_mode')),
              value: settings.darkMode,
              activeColor: Colors.pink,
              onChanged: notifier.toggleDarkMode,
            ),
            const Divider(),

            // Language & RTL Section
            _SectionHeader(title: strings.get('language')),
            RadioListTile<String>(
              secondary: const Icon(Icons.language_rounded, color: Colors.pink),
              title: Text(strings.get('english')),
              value: 'en',
              groupValue: settings.languageCode,
              activeColor: Colors.pink,
              onChanged: (val) {
                if (val != null) notifier.setLanguage(val);
              },
            ),
            RadioListTile<String>(
              secondary: const Icon(Icons.translate_rounded, color: Colors.pink),
              title: Text(strings.get('arabic')),
              value: 'ar',
              groupValue: settings.languageCode,
              activeColor: Colors.pink,
              onChanged: (val) {
                if (val != null) notifier.setLanguage(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.pink.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
