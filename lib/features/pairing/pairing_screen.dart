import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/deep_link_service.dart';
import 'connected_screen.dart';
import 'create_link_screen.dart';
import 'enter_link_screen.dart';
import 'pairing_provider.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    final deepLinkService = ref.read(deepLinkServiceProvider);
    deepLinkService.initDeepLinks((pairId) {
      if (mounted) {
        ref.read(pairingNotifierProvider.notifier).acceptPairing(pairId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pairingStream = ref.watch(userPairingStreamProvider);

    return pairingStream.when(
      data: (info) {
        if (info.isConnected) {
          return ConnectedScreen(pairingInfo: info);
        }
        return const _NotPairedScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const _NotPairedScreen(),
    );
  }
}

class _NotPairedScreen extends StatelessWidget {
  const _NotPairedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoveRing Pairing'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.favorite_outline_rounded,
                size: 90,
                color: Colors.pink,
              ),
              const SizedBox(height: 24),
              Text(
                'Connect Phones',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pair with your partner to send instant loud pings and full-screen love hearts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.link_rounded),
                label: const Text(
                  'Create Link',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const CreateLinkScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.pink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.move_to_inbox_rounded),
                label: const Text(
                  'Enter Link',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const EnterLinkScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
