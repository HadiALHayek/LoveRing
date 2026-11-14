import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';
import 'pairing_provider.dart';

class ConnectedScreen extends ConsumerStatefulWidget {
  final UserPairingInfo pairingInfo;

  const ConnectedScreen({
    super.key,
    required this.pairingInfo,
  });

  @override
  ConsumerState<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends ConsumerState<ConnectedScreen> {
  bool _isSending = false;

  Future<void> _sendPing() async {
    setState(() => _isSending = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.sendPing(fromName: 'Your Partner');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ping sent to partner! 💖'),
            backgroundColor: Colors.pink,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send ping.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _confirmUnpair() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unpair Phone?'),
        content: const Text(
          'Are you sure you want to unpair from your partner? You will need to create a new pairing link to re-connect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(pairingNotifierProvider.notifier).unpair();
            },
            child: const Text('Unpair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected 💕'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_off_rounded),
            tooltip: 'Unpair',
            onPressed: _confirmUnpair,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.favorite_rounded,
                size: 100,
                color: Colors.pink,
              ),
              const SizedBox(height: 24),
              Text(
                'Connected with Partner 💕',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your phones are linked! Tap the button below to send a love ping directly to your partner\'s phone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: _isSending
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.favorite, size: 28),
                label: Text(
                  _isSending ? 'Sending Ping...' : 'Send Love Ping 💗',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _isSending ? null : _sendPing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
