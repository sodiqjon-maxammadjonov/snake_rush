import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
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
  late final Ticker _ticker;
  late final List<GlassBubble> _bubbles;
  Duration _lastElapsed = Duration.zero;

  static const int _bubbleCount = 8;
  static const double _maxDeltaTime = 0.1;

  @override
  void initState() {
    super.initState();
    _bubbles = _initBubbles();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  List<GlassBubble> _initBubbles() {
    final random = math.Random();
    return List.generate(_bubbleCount, (i) {
      return GlassBubble(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 60 + random.nextDouble() * 100,
        speedX: -40 + random.nextDouble() * 80,
        speedY: -40 + random.nextDouble() * 80,
        rotationSpeed: -0.3 + random.nextDouble() * 0.6,
        rotation: random.nextDouble() * math.pi * 2,
      );
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;

    if (dt > _maxDeltaTime) return;

    setState(() {
      _updateBubbles(dt);
    });
  }

  void _updateBubbles(double dt) {
    final size = MediaQuery.of(context).size;

    for (final bubble in _bubbles) {
      bubble.x += bubble.speedX * dt / size.width;
      bubble.y += bubble.speedY * dt / size.height;
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

    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.mainGradient),
          child: SizedBox.expand(),
        ),

        CustomPaint(
          size: size,
          painter: _BubblePainter(_bubbles, size),
        ),

        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: CupertinoColors.white.withOpacity(0.05),
            ),
          ),
        ),

        widget.child,
      ],
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<GlassBubble> bubbles;
  final Size size;

  _BubblePainter(this.bubbles, this.size);

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final xPos = bubble.x * size.width;
      final yPos = bubble.y * size.height;

      canvas.save();
      canvas.translate(xPos, yPos);
      canvas.rotate(bubble.rotation);
      canvas.translate(-bubble.size / 2, -bubble.size / 2);

      final paint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.2,
          colors: [
            CupertinoColors.white.withOpacity(0.5),
            CupertinoColors.white.withOpacity(0.3),
            CupertinoColors.white.withOpacity(0.1),
            CupertinoColors.white.withOpacity(0.05),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, bubble.size, bubble.size));

      canvas.drawCircle(
        Offset(bubble.size / 2, bubble.size / 2),
        bubble.size / 2,
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => true;
}

class GlassBubble {
  double x, y;
  final double size;
  final double speedX, speedY;
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