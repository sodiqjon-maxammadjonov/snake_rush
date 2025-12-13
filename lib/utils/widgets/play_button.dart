import 'dart:ui';
import 'package:flutter/cupertino.dart';

class GamePlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GamePlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(w * 0.08),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: w * 0.18,
            width: w * 0.55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CupertinoColors.systemGreen.withOpacity(0.9),
                  CupertinoColors.systemTeal.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(w * 0.08),
              border: Border.all(
                color: CupertinoColors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGreen.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.play_fill,
                  color: CupertinoColors.white,
                  size: w * 0.07,
                ),
                SizedBox(width: w * 0.03),
                Text(
                  'PLAY',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
