import 'package:flutter/cupertino.dart';
import 'dart:ui';

class MorphPageWrapper extends StatelessWidget {
  final Animation<double> animation;
  final Offset startPosition;
  final Size startSize;
  final Widget child;
  final String? flyingEmoji;
  final double blurIntensity;

  const MorphPageWrapper({
    super.key,
    required this.animation,
    required this.startPosition,
    required this.startSize,
    required this.child,
    this.flyingEmoji,
    this.blurIntensity = 10.0,
  });

  double _safeOpacity(double value) => value.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(animation.value);

        final left = lerpDouble(startPosition.dx, 0, t) ?? 0;
        final top = lerpDouble(startPosition.dy, 0, t) ?? 0;
        final width = lerpDouble(startSize.width, screen.width, t) ?? screen.width;
        final height = lerpDouble(startSize.height, screen.height, t) ?? screen.height;
        final radius = lerpDouble(20, 0, t) ?? 0;

        final backgroundOpacity = _safeOpacity(t * 0.3);
        final borderOpacity = _safeOpacity(t * 0.2);
        final shadowOpacity = _safeOpacity(t * 0.3);

        double emojiOpacity = t < 0.7 ? 1.0 : _safeOpacity(1.0 - (t - 0.7) / 0.1);
        double contentOpacity = t <= 0.3 ? 0.0 : _safeOpacity((t - 0.3) / 0.7);

        return Stack(
          children: [
            // Background
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: CupertinoColors.black.withValues(alpha: backgroundOpacity),
                ),
              ),
            ),

            if (flyingEmoji != null && t < 0.8)
              Positioned(
                left: lerpDouble(startPosition.dx, (screen.width - 30) / 2, t) ?? 0,
                top: lerpDouble(startPosition.dy, 60, t) ?? 60,
                child: Transform.scale(
                  scale: lerpDouble(1.0, 1.5, _safeOpacity(t * 1.25)) ?? 1.0,
                  child: Opacity(
                    opacity: emojiOpacity,
                    child: Text(
                      flyingEmoji!,
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),

            // Morphing page
            Positioned(
              left: left,
              top: top,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: (blurIntensity * t).clamp(0.0, blurIntensity),
                    sigmaY: (blurIntensity * t).clamp(0.0, blurIntensity),
                  ),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CupertinoColors.white.withValues(alpha: borderOpacity),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: shadowOpacity),
                          blurRadius: (30 * t).clamp(0.0, 30.0),
                          spreadRadius: (5 * t).clamp(0.0, 5.0),
                        ),
                      ],
                    ),
                    child: contentOpacity > 0.0
                        ? Opacity(
                      opacity: contentOpacity,
                      child: child,
                    )
                        : SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class MorphPage extends StatelessWidget {
  final Widget child;

  const MorphPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Bu faqat wrapper, haqiqiy animatsiya MorphPageWrapper da
    return child;
  }
}

// ============================================
// FOYDALANISH MISOLI
// ============================================


