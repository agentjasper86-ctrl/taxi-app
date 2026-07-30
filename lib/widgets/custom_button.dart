import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;
  final bool isSecondary;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.height = 54.0,
    this.width,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        (isSecondary ? AppTheme.primaryDark : AppTheme.accentGold);
    final effectiveTextColor = textColor ??
        (isSecondary ? Colors.white : AppTheme.primaryDark);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppTheme.borderRadius,
          boxShadow: isSecondary ? [] : AppTheme.buttonShadow,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBgColor,
            foregroundColor: effectiveTextColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.borderRadius,
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: effectiveTextColor),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: effectiveTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
