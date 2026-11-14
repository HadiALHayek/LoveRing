import 'package:flutter/material.dart';

class PingScreen extends StatelessWidget {
  final String fromName;

  const PingScreen({
    super.key,
    this.fromName = 'Your Partner',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ping from $fromName'),
      ),
      body: Center(
        child: Text('Ping heart screen for $fromName will be fully styled in Phase 5'),
      ),
    );
  }
}
