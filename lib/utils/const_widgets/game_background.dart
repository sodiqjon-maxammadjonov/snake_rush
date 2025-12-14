import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../ui/colors.dart';

class GlassBubblesBackground extends StatefulWidget {
  final Widget child;

  const GlassBubblesBackground({
    super.key,
    required this.child,
  });

  @override
  State<GlassBubblesBackground> createState() => _GlassBubblesBackgroundState();
}

class _GlassBubblesBackgroundState extends State<GlassBubblesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<GlassBubble> bubbles = [];
  late DateTime _lastUpdate;

  @override
  void initState() {
    super.initState();
    _lastUpdate = DateTime.now();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat();

    _initBubbles();
  }

  void _initBubbles() {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      bubbles.add(GlassBubble(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 60 + random.nextDouble() * 100,
        speedX: (-40 + random.nextDouble() * 80),
        speedY: (-40 + random.nextDouble() * 80),
        rotationSpeed: -0.3 + random.nextDouble() * 0.6,
        rotation: random.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateBubbles(Size size) {
    final now = DateTime.now();
    final dt = (now.millisecondsSinceEpoch - _lastUpdate.millisecondsSinceEpoch) / 1000.0;
    _lastUpdate = now;

    if (dt > 0.1) return;

    for (var bubble in bubbles) {
      final dx = bubble.speedX * dt / size.width;
      final dy = bubble.speedY * dt / size.height;

      bubble.x += dx;
      bubble.y += dy;
      bubble.rotation += bubble.rotationSpeed * dt;

      final marginX = (bubble.size / size.width) * 1.5;
      final marginY = (bubble.size / size.height) * 1.5;

      if (bubble.x < -marginX) bubble.x = 1 + marginX;
      if (bubble.x > 1 + marginX) bubble.x = -marginX;
      if (bubble.y < -marginY) bubble.y = 1 + marginY;
      if (bubble.y > 1 + marginY) bubble.y = -marginY;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        _updateBubbles(size);

        return Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                gradient: AppColors.mainGradient,
              ),
            ),

            ...bubbles.map((bubble) {
              final xPos = bubble.x * size.width;
              final yPos = bubble.y * size.height;
              return Positioned(
                left: xPos - bubble.size / 2,
                top: yPos - bubble.size / 2,
                child: Transform.rotate(
                  angle: bubble.rotation,
                  child: Container(
                    width: bubble.size,
                    height: bubble.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.4),
                        radius: 1.2,
                        colors: [
                          CupertinoColors.white.withOpacity(0.5),
                          CupertinoColors.white.withOpacity(0.3),
                          CupertinoColors.white.withOpacity(0.1),
                          CupertinoColors.white.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            }),

            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: CupertinoColors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ),

            widget.child,
          ],
        );
      },
    );
  }
}

class GlassBubble {
  double x;
  double y;
  final double size;
  final double speedX;
  final double speedY;
  final double rotationSpeed;
  double rotation;

  GlassBubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.rotationSpeed,
    required this.rotation,
  });
}