import 'package:flutter/cupertino.dart';
import 'dart:ui';

class MorphNavigator {
  static void open({
    required BuildContext context,
    required GlobalKey sourceKey,
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    double blurIntensity = 10.0,
  }) {
    final renderBox = sourceKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withOpacity(0),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, _) {
          return _MorphPageWrapper(
            animation: animation,
            startPosition: position,
            startSize: size,
            blurIntensity: blurIntensity,
            child: child,
          );
        },
      ),
    );
  }
}

class _MorphPageWrapper extends StatelessWidget {
  final Animation<double> animation;
  final Offset startPosition;
  final Size startSize;
  final Widget child;
  final double blurIntensity;

  const _MorphPageWrapper({
    required this.animation,
    required this.startPosition,
    required this.startSize,
    required this.child,
    this.blurIntensity = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(animation.value);

        final left = lerpDouble(startPosition.dx, 0, t)!;
        final top = lerpDouble(startPosition.dy, 0, t)!;
        final width = lerpDouble(startSize.width, screen.width, t)!;
        final height = lerpDouble(startSize.height, screen.height, t)!;
        final radius = lerpDouble(20, 0, t)!;

        final bgOpacity = (t * 0.3).clamp(0.0, 1.0);
        final borderOpacity = (t * 0.2).clamp(0.0, 1.0);
        final shadowOpacity = (t * 0.3).clamp(0.0, 1.0);
        final contentOpacity = t <= 0.3 ? 0.0 : ((t - 0.3) / 0.7).clamp(0.0, 1.0);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: CupertinoColors.black.withOpacity(bgOpacity),
                ),
              ),
            ),

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
                        color: CupertinoColors.white.withOpacity(borderOpacity),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(shadowOpacity),
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
                        : const SizedBox.shrink(),
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