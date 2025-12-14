import 'package:flutter/cupertino.dart';
import 'package:snake_rush/utils/services/audio/audio_manager.dart';
import '../ui/colors.dart';
import '../ui/dimensions.dart';

class BackButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool useEmoji;

  const BackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.useEmoji = true,
  });

  @override
  State<BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<BackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  final _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    _audioManager.playButtonClick();
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final bgColor = widget.backgroundColor ?? AppColors.glassLight;
    final iColor = widget.iconColor ?? AppColors.textPrimary;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: d.backButtonSize,
          height: d.backButtonSize,
          decoration: BoxDecoration(
            color: _isPressed ? bgColor.withOpacity(0.5) : bgColor,
            borderRadius: BorderRadius.circular(d.radiusMedium),
            border: Border.all(
              color: AppColors.glassBorder,
              width: d.borderMedium,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Center(
            child: widget.useEmoji
                ? Text(
              '←',
              style: TextStyle(
                fontSize: d.iconMedium,
                fontWeight: FontWeight.bold,
                color: iColor,
              ),
            )
                : Icon(
              CupertinoIcons.back,
              size: d.iconMedium,
              color: iColor,
            ),
          ),
        ),
      ),
    );
  }
}