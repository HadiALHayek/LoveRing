import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/permission_service.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  final VoidCallback onPermissionsCompleted;

  const PermissionsScreen({
    super.key,
    required this.onPermissionsCompleted,
  });

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _notificationGranted = false;
  bool _batteryExemptGranted = false;
  bool _dndAccessGranted = false;
  bool _fullScreenIntentGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final service = ref.read(permissionServiceProvider);
    final dnd = await service.checkDndPermission();
    final battery = await service.checkBatteryOptimizationExemption();
    final fullScreen = await service.checkFullScreenIntentPermission();

    if (mounted) {
      setState(() {
        _dndAccessGranted = dnd;
        _batteryExemptGranted = battery;
        _fullScreenIntentGranted = fullScreen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(permissionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Required Permissions'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 64,
              color: Colors.pink,
            ),
            const SizedBox(height: 16),
            Text(
              'LoveRing Setup',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'To ensure your love pings reach your partner instantly and bypass silent mode, please grant the following permissions:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 24),

            // 1. Notifications
            _PermissionTile(
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              description:
                  'Required to receive real-time ping alerts from your partner.',
              isGranted: _notificationGranted,
              onRequest: () async {
                final granted =
                    await service.requestNotificationPermission();
                setState(() => _notificationGranted = granted);
              },
            ),
            const Divider(),

            // 2. Battery Optimization Exemption
            _PermissionTile(
              icon: Icons.battery_saver,
              title: 'Battery Optimization Exemption',
              description:
                  'Prevents Android from putting LoveRing to sleep in the background.',
              isGranted: _batteryExemptGranted,
              onRequest: () async {
                await service.requestBatteryOptimizationExemption();
                await _checkPermissions();
              },
            ),
            const Divider(),

            // 3. Do Not Disturb Access
            _PermissionTile(
              icon: Icons.do_not_disturb_on,
              title: 'Do Not Disturb (DND) Access',
              description:
                  'Allows LoveRing to ring loudly on Stream Alarm even in Silent or DND mode.',
              isGranted: _dndAccessGranted,
              onRequest: () async {
                await service.requestDndPermission();
                await _checkPermissions();
              },
            ),
            const Divider(),

            // 4. Full-Screen Intent
            _PermissionTile(
              icon: Icons.screen_lock_portrait,
              title: 'Full-Screen Intent',
              description:
                  'Displays the animated heart screen over the lock screen when a ping arrives.',
              isGranted: _fullScreenIntentGranted,
              onRequest: () async {
                await service.requestFullScreenIntentPermission();
                await _checkPermissions();
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onPermissionsCompleted,
              child: const Text(
                'Continue to LoveRing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isGranted ? Colors.green[100] : Colors.pink[50],
            child: Icon(
              icon,
              color: isGranted ? Colors.green : Colors.pink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRequest,
            child: Text(
              isGranted ? 'Granted ✓' : 'Grant',
              style: TextStyle(
                color: isGranted ? Colors.green : Colors.pink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
