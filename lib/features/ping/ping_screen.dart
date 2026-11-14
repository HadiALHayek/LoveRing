import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../services/api_client.dart';
import '../../services/audio_service.dart';

class PingScreen extends ConsumerStatefulWidget {
  final String fromName;

  const PingScreen({
    super.key,
    this.fromName = 'Your Partner',
  });

  @override
  ConsumerState<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends ConsumerState<PingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _floatingController;

  final List<_FloatingHeart> _floatingHearts = [];
  final Random _random = Random();
  Timer? _autoDismissTimer;
  bool _isSendingReply = false;

  @override
  void initState() {
    super.initState();

    // Pulsing heart animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Floating hearts animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    for (int i = 0; i < 15; i++) {
      _floatingHearts.add(_FloatingHeart.random(_random));
    }

    // Trigger vibration pattern
    _startVibration();

    // Auto-stop sound/vibration & dismiss screen after 15 seconds
    _autoDismissTimer = Timer(const Duration(seconds: 15), () {
      _stopSoundAndVibration();
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _startVibration() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000, 500, 1000],
        intensities: [128, 255, 128, 255, 128, 255],
      );
    }
  }

  void _stopSoundAndVibration() {
    _autoDismissTimer?.cancel();
    Vibration.cancel();
    ref.read(audioServiceProvider).stopLoudSound();
  }

  void _dismiss() {
    _stopSoundAndVibration();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _sendOneBack() async {
    setState(() => _isSendingReply = true);
    _stopSoundAndVibration();

    try {
      final client = ref.read(apiClientProvider);
      await client.sendPing(fromName: 'Your Love');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sent one back! 💗'),
            backgroundColor: Colors.pink,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
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
            content: Text('Failed to send ping back.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingReply = false);
      }
    }
  }

  @override
  void dispose() {
    _stopSoundAndVibration();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A00E0),
                  Color(0xFF8E2DE2),
                  Color(0xFFF000FF),
                  Color(0xFFFF007F),
                ],
              ),
            ),
          ),

          // Floating Mini Hearts Particle Canvas
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return CustomPaint(
                painter: _FloatingHeartsPainter(
                  hearts: _floatingHearts,
                  progress: _floatingController.value,
                ),
                child: Container(),
              );
            },
          ),

          // Foreground Animated Pulse Heart & Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Partner Header
                  Column(
                    children: [
                      const Text(
                        'LOVE RING PING',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.fromName} is thinking of you!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black38,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Center Pulsing Heart
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent,
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 160,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Action Buttons (Dismiss & Send One Back)
                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.pink.shade700,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        icon: _isSendingReply
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.pink.shade700,
                                ),
                              )
                            : const Icon(Icons.favorite, size: 28),
                        label: Text(
                          _isSendingReply ? 'Sending...' : 'Send one back 💗',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _isSendingReply ? null : _sendOneBack,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                        ),
                        onPressed: _dismiss,
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingHeart {
  final double xRatio; // 0.0 to 1.0 relative screen width
  final double speed;
  final double size;
  final double opacity;

  _FloatingHeart({
    required this.xRatio,
    required this.speed,
    required this.size,
    required this.opacity,
  });

  factory _FloatingHeart.random(Random random) {
    return _FloatingHeart(
      xRatio: random.nextDouble(),
      speed: 0.5 + random.nextDouble() * 0.8,
      size: 16.0 + random.nextDouble() * 24.0,
      opacity: 0.3 + random.nextDouble() * 0.5,
    );
  }
}

class _FloatingHeartsPainter extends CustomPainter {
  final List<_FloatingHeart> hearts;
  final double progress;

  _FloatingHeartsPainter({
    required this.hearts,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var heart in hearts) {
      final y = size.height - ((progress * heart.speed * size.height) % size.height);
      final x = heart.xRatio * size.width + sin(progress * 2 * pi + heart.xRatio * 10) * 20;

      textPainter.text = TextSpan(
        text: '💖',
        style: TextStyle(
          fontSize: heart.size,
          color: Colors.white.withAlpha((heart.opacity * 255).toInt()),
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingHeartsPainter oldDelegate) => true;
}
