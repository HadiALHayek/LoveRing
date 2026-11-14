import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_service.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref.read(audioServiceProvider));
});

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'ping') {
    final fcmService = FcmService(AudioService());
    await fcmService.showPingNotification(
      fromName: message.data['fromName'] ?? 'Your Partner',
    );
    await AudioService().playLoudSound();
  }
}

class FcmService {
  final AudioService _audioService;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FcmService(this._audioService);

  static const String channelId = 'love_ring_pings';
  static const String channelName = 'LoveRing Pings';
  static const String channelDescription =
      'High-priority loud love pings from your partner that bypass silent mode';

  Future<void> initialize(Function(String fromName) onPingReceived) async {
    // Configure FCM background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize local notifications plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        onPingReceived(details.payload ?? 'Your Partner');
      },
    );

    // Create high importance notification channel with alarm usage
    final androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Listen to foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data['type'] == 'ping') {
        final fromName = message.data['fromName'] ?? 'Your Partner';
        await showPingNotification(fromName: fromName);
        await _audioService.playLoudSound();
        onPingReceived(fromName);
      }
    });
  }

  /// Displays full-screen-intent high-priority notification
  Future<void> showPingNotification({required String fromName}) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      styleInformation: BigTextStyleInformation(
        '$fromName sent you a love ping! 💖',
        contentTitle: '💖 Love Ping from $fromName!',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💖 Love Ping from $fromName!',
      '$fromName is thinking of you!',
      notificationDetails,
      payload: fromName,
    );
  }
}
