import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'api_client.dart';

const String kWidgetProviderName = 'LoveRingWidgetProvider';

/// Top-level background callback entry-point executed when home screen widget is tapped
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  final apiClient = ApiClient();
  try {
    await HomeWidget.saveWidgetData('widget_status', 'Sending...');
    await HomeWidget.updateWidget(name: kWidgetProviderName);

    await apiClient.sendPing(fromName: 'Widget Ping').timeout(
      const Duration(seconds: 5),
    );

    await HomeWidget.saveWidgetData('widget_status', 'Sent ✓');
    await HomeWidget.updateWidget(name: kWidgetProviderName);

    // Reset status after 3 seconds
    Timer(const Duration(seconds: 3), () async {
      await HomeWidget.saveWidgetData('widget_status', 'Tap to Ping 💗');
      await HomeWidget.updateWidget(name: kWidgetProviderName);
    });
  } on TimeoutException {
    await HomeWidget.saveWidgetData('widget_status', 'Timed out');
    await HomeWidget.updateWidget(name: kWidgetProviderName);
    Timer(const Duration(seconds: 3), () async {
      await HomeWidget.saveWidgetData('widget_status', 'Tap to Ping 💗');
      await HomeWidget.updateWidget(name: kWidgetProviderName);
    });
  } catch (e) {
    final String errorText = e is NotPairedException ? 'Open app to pair' : 'Failed';
    await HomeWidget.saveWidgetData('widget_status', errorText);
    await HomeWidget.updateWidget(name: kWidgetProviderName);

    Timer(const Duration(seconds: 3), () async {
      await HomeWidget.saveWidgetData('widget_status', 'Tap to Ping 💗');
      await HomeWidget.updateWidget(name: kWidgetProviderName);
    });
  }
}

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});

class WidgetService {
  /// Initializes home_widget background callback registration
  Future<void> initialize() async {
    await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
  }

  /// Syncs current partner name and connection status to home screen widget
  Future<void> syncWidgetState({
    required bool isConnected,
    String? partnerName,
  }) async {
    if (isConnected) {
      await HomeWidget.saveWidgetData(
        'partner_name',
        partnerName != null && partnerName.isNotEmpty ? partnerName : 'Connected 💕',
      );
      await HomeWidget.saveWidgetData('widget_status', 'Tap to Ping 💗');
    } else {
      await HomeWidget.saveWidgetData('partner_name', 'Not Paired');
      await HomeWidget.saveWidgetData('widget_status', 'Open app to pair');
    }
    await HomeWidget.updateWidget(name: kWidgetProviderName);
  }
}
