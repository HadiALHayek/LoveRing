import 'package:flutter/material.dart';

class PingScreen extends StatelessWidget {
  const PingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ping Heart Screen'),
      ),
      body: const Center(
        child: Text('Ping heart screen will be implemented in Phase 5'),
      ),
    );
  }
}
