import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

class PermissionService {
  static const MethodChannel _audioChannel = MethodChannel('loveRing/audio');

  /// Requests notification permission via FlutterLocalNotificationsPlugin
  Future<bool> requestNotificationPermission() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted =
        await androidImplementation?.requestNotificationsPermission() ?? false;
    return granted;
  }

  /// Checks if Do Not Disturb policy access is granted
  Future<bool> checkDndPermission() async {
    try {
      final bool hasDnd =
          await _audioChannel.invokeMethod('checkDndPermission') ?? false;
      return hasDnd;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens Do Not Disturb policy access settings
  Future<void> requestDndPermission() async {
    try {
      await _audioChannel.invokeMethod('requestDndPermission');
    } on MissingPluginException catch (_) {
      // Channel plugin not registered yet
    } on PlatformException catch (_) {
      // Platform error ignored
    }
  }

  /// Checks if app is ignoring battery optimizations
  Future<bool> checkBatteryOptimizationExemption() async {
    try {
      final bool isIgnoring = await _audioChannel
              .invokeMethod('checkBatteryOptimization') ??
          false;
      return isIgnoring;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Requests battery optimization exemption
  Future<void> requestBatteryOptimizationExemption() async {
    try {
      await _audioChannel.invokeMethod('requestBatteryOptimization');
    } on MissingPluginException catch (_) {
      // Channel plugin not registered yet
    } on PlatformException catch (_) {
      // Platform error ignored
    }
  }

  /// Checks if full-screen intent permission is allowed (Android 14+)
  Future<bool> checkFullScreenIntentPermission() async {
    try {
      final bool allowed =
          await _audioChannel.invokeMethod('checkFullScreenIntent') ?? true;
      return allowed;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  /// Opens full-screen intent permission settings
  Future<void> requestFullScreenIntentPermission() async {
    try {
      await _audioChannel.invokeMethod('requestFullScreenIntent');
    } on MissingPluginException catch (_) {
      // Channel plugin not registered yet
    } on PlatformException catch (_) {
      // Platform error ignored
    }
  }
}
