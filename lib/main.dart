import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/pairing/pairing_screen.dart';
import 'features/permissions/permissions_screen.dart';
import 'features/ping/ping_screen.dart';
import 'features/settings/settings_provider.dart';

import 'services/auth_service.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If google-services.json is not yet provided, app will initialize with default options in Phase 1
  }

  runApp(
    const ProviderScope(
      child: LoveRingApp(),
    ),
  );
}

class LoveRingApp extends ConsumerStatefulWidget {
  const LoveRingApp({super.key});

  @override
  ConsumerState<LoveRingApp> createState() => _LoveRingAppState();
}

class _LoveRingAppState extends ConsumerState<LoveRingApp> {
  bool _showPermissionsScreen = true;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.initializeAnonymousAuth();

      final fcmService = ref.read(fcmServiceProvider);
      await fcmService.initialize((fromName) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (ctx) => PingScreen(fromName: fromName),
          ),
        );
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'LoveRing',
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: settings.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _showPermissionsScreen
          ? PermissionsScreen(
              onPermissionsCompleted: () {
                setState(() {
                  _showPermissionsScreen = false;
                });
              },
            )
          : const PairingScreen(),
    );
  }
}
