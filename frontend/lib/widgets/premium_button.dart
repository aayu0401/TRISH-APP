import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonType { primary, secondary, outline, gradient, glass }

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final Gradient? customGradient;
  final Color? customColor;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 56,
    this.customGradient,
    this.customColor,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height,
          decoration: _getDecoration(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppTheme.mediumRadius,
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: widget.isLoading
                    ? _buildLoadingIndicator()
                    : _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          color: widget.customColor ?? AppTheme.primaryPink,
          borderRadius: AppTheme.mediumRadius,
          boxShadow: [
            BoxShadow(
              color: (widget.customColor ?? AppTheme.primaryPink)
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        );
      case ButtonType.gradient:
        return BoxDecoration(
          gradient: widget.customGradient ?? AppTheme.primaryGradient,
          borderRadius: AppTheme.mediumRadius,
          boxShadow: AppTheme.glowShadow,
        );
      case ButtonType.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppTheme.mediumRadius,
          border: Border.all(
            color: widget.customColor ?? AppTheme.primaryPink,
            width: 2,
          ),
        );
      case ButtonType.glass:
        return AppTheme.glassmorphicDecoration(
          borderRadius: AppTheme.mediumRadius,
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: AppTheme.mediumRadius,
        );
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.type == ButtonType.outline ||
                    widget.type == ButtonType.secondary
                ? AppTheme.primaryPink
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final textColor = widget.type == ButtonType.outline ||
            widget.type == ButtonType.secondary
        ? AppTheme.textPrimary
        : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 12),
        ],
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
