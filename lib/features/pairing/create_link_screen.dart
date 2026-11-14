import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'pairing_provider.dart';

class CreateLinkScreen extends ConsumerStatefulWidget {
  const CreateLinkScreen({super.key});

  @override
  ConsumerState<CreateLinkScreen> createState() => _CreateLinkScreenState();
}

class _CreateLinkScreenState extends ConsumerState<CreateLinkScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pairingNotifierProvider.notifier).createPairingLink();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pairingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Pairing Link'),
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
                size: 80,
                color: Colors.pink,
              ),
              const SizedBox(height: 24),
              Text(
                'Share with your Partner',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Send this link to your partner. Once they open it on their phone, you will be connected!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 32),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.errorMessage != null) ...[
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(pairingNotifierProvider.notifier).createPairingLink();
                  },
                  child: const Text('Try Again'),
                ),
              ] else if (state.createdLink != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: SelectableText(
                    state.createdLink!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'Share Link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Share.share(
                      'Join me on LoveRing! Open this link to pair our phones: ${state.createdLink}',
                      subject: 'LoveRing Pairing Invite',
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy to Clipboard'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: state.createdLink!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
