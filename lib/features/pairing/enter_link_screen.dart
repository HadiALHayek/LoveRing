import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pairing_provider.dart';

class EnterLinkScreen extends ConsumerStatefulWidget {
  const EnterLinkScreen({super.key});

  @override
  ConsumerState<EnterLinkScreen> createState() => _EnterLinkScreenState();
}

class _EnterLinkScreenState extends ConsumerState<EnterLinkScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a link or code')),
      );
      return;
    }

    final success = await ref
        .read(pairingNotifierProvider.notifier)
        .acceptPairing(text);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pairingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Partner Link'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.link_rounded,
                size: 80,
                color: Colors.pink,
              ),
              const SizedBox(height: 24),
              Text(
                'Connect to Your Partner',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Paste the link or pair code your partner sent you below:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'https://.../pair/abcd1234efgh or code',
                  prefixIcon: const Icon(Icons.paste_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pink, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (state.errorMessage != null) ...[
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Connect 💕',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
