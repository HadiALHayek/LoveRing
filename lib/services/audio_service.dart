import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  static const MethodChannel _audioChannel = MethodChannel('loveRing/audio');

  /// Plays a loud sound on STREAM_ALARM, temporarily raising volume and overriding DND mode.
  Future<bool> playLoudSound() async {
    try {
      final bool res = await _audioChannel.invokeMethod('playLoudSound') ?? false;
      return res;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Stops the loud sound and restores previous ringer mode and volume levels.
  Future<bool> stopLoudSound() async {
    try {
      final bool res = await _audioChannel.invokeMethod('stopLoudSound') ?? false;
      return res;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
