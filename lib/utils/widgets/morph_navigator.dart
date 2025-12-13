import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'morph_page.dart';

class MorphNavigator {
  static void open({
    required BuildContext context,
    required GlobalKey sourceKey,
    required Widget Function(
        Animation<double> animation,
        Offset startPosition,
        Size startSize,
        ) builder,
    Duration duration = const Duration(milliseconds: 600),
    String? flyingEmoji, // Ixtiyoriy: uchuvchi emoji
  }) {
    final renderBox = sourceKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withOpacity(0),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, _) {
          return MorphPageWrapper(
            animation: animation,
            startPosition: position,
            startSize: size,
            flyingEmoji: flyingEmoji,
            child: builder(animation, position, size),
          );
        },
      ),
    );
  }
}