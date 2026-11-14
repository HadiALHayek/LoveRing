import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/widget_service.dart';

class WidgetScreen extends ConsumerWidget {
  const WidgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen Widget'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.widgets_rounded,
                size: 80,
                color: Colors.pink,
              ),
              const SizedBox(height: 24),
              Text(
                'Instant Widget Pings',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add the LoveRing widget to your phone\'s home screen to send instant love pings with a single tap, without even opening the app!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
              ),
              const SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to add the widget:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.pink,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text('1. Go to your phone\'s Home Screen.'),
                      SizedBox(height: 6),
                      Text('2. Touch and hold any empty space until the menu appears.'),
                      SizedBox(height: 6),
                      Text('3. Tap Widgets and search for LoveRing.'),
                      SizedBox(height: 6),
                      Text('4. Drag and drop the LoveRing widget onto your home screen.'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.sync_rounded),
                label: const Text(
                  'Sync Widget Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final service = ref.read(widgetServiceProvider);
                  await service.syncWidgetState(
                    isConnected: true,
                    partnerName: 'Your Love 💕',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Widget synced! Check your home screen.'),
                        backgroundColor: Colors.pink,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
