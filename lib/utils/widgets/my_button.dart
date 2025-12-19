import 'package:flutter/cupertino.dart';
import '../services/audio/audio_manager.dart';
import '../services/service_locator.dart';
import '../ui/colors.dart';
import '../ui/dimensions.dart';

enum ButtonType { primary, secondary, glass, icon }

class MyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final ButtonType type;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool playSound;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const MyButton({
    super.key,
    this.onPressed,
    this.text,
    this.child,
    this.type = ButtonType.primary,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.playSound = true,
    this.padding,
    this.borderRadius,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final AudioManager _audioManager; // Cached singleton
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // ✅ Singleton ni bir marta cache qilamiz
    _audioManager = getIt<AudioManager>();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100), // Tezroq animation
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96, // Kamroq scale
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!mounted || widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!mounted) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!mounted) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;

    // ✅ INSTANT sound - await yo'q!
    if (widget.playSound) {
      _audioManager.playButtonClick();
    }

    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildButtonByType(d),
      ),
    );
  }

  Widget _buildButtonByType(Dimensions d) {
    switch (widget.type) {
      case ButtonType.primary:
        return _buildPrimaryButton(d);
      case ButtonType.secondary:
        return _buildSecondaryButton(d);
      case ButtonType.glass:
        return _buildGlassButton(d);
      case ButtonType.icon:
        return _buildIconButton(d);
    }
  }

  Widget _buildPrimaryButton(Dimensions d) {
    return Container(
      width: widget.width ?? d.buttonWidth,
      height: widget.height ?? d.buttonHeight,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: widget.backgroundColor != null
            ? null
            : AppColors.playButtonGradient,
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(d.radiusLarge),
        border: Border.all(
          color: AppColors.glassBorder,
          width: d.borderMedium,
        ),
        boxShadow: AppColors.buttonShadow,
      ),
      child: _buildButtonContent(d),
    );
  }

  Widget _buildSecondaryButton(Dimensions d) {
    return Container(
      width: widget.width,
      height: widget.height ?? d.buttonHeightSmall,
      padding: widget.padding ??
          EdgeInsets.symmetric(
            horizontal: d.paddingCard,
            vertical: d.paddingButton,
          ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.glassLight,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(d.radiusMedium),
        border: Border.all(
          color: AppColors.glassBorder,
          width: d.borderMedium,
        ),
      ),
      child: _buildButtonContent(d),
    );
  }

  Widget _buildGlassButton(Dimensions d) {
    return Container(
      width: widget.width,
      height: widget.height ?? d.cardHeightSmall,
      padding: widget.padding ?? EdgeInsets.all(d.paddingCard),
      decoration: BoxDecoration(
        color: _isPressed
            ? AppColors.glassLight.withOpacity(0.5)
            : AppColors.glassLight,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(d.radiusMedium),
        border: Border.all(
          color: AppColors.glassBorder,
          width: d.borderMedium,
        ),
      ),
      child: _buildButtonContent(d),
    );
  }

  Widget _buildIconButton(Dimensions d) {
    return Container(
      width: widget.width ?? d.backButtonSize,
      height: widget.height ?? d.backButtonSize,
      decoration: BoxDecoration(
        color: _isPressed
            ? (widget.backgroundColor ?? AppColors.glassLight).withOpacity(0.5)
            : widget.backgroundColor ?? AppColors.glassLight,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(d.radiusMedium),
        border: Border.all(
          color: AppColors.glassBorder,
          width: d.borderMedium,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Center(child: widget.child),
    );
  }

  Widget _buildButtonContent(Dimensions d) {
    if (widget.child != null) {
      return Center(child: widget.child);
    }

    final hasIcon = widget.icon != null;
    final hasText = widget.text != null;

    if (hasIcon && hasText) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: widget.textColor ?? AppColors.textPrimary,
            size: d.iconMedium,
          ),
          SizedBox(width: d.spaceMedium),
          Flexible(
            child: Text(
              widget.text!,
              style: TextStyle(
                fontSize: d.button,
                fontWeight: FontWeight.bold,
                color: widget.textColor ?? AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (hasIcon) {
      return Icon(
        widget.icon,
        color: widget.textColor ?? AppColors.textPrimary,
        size: d.iconMedium,
      );
    }

    if (hasText) {
      return Text(
        widget.text!,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: d.button,
          fontWeight: FontWeight.bold,
          color: widget.textColor ?? AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    return const SizedBox.shrink();
  }
}