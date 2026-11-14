import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/pairing/pairing_screen.dart';
import 'features/permissions/permissions_screen.dart';
import 'services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.initializeAnonymousAuth();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoveRing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
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
