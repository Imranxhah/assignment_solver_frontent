import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: BorderSide(
            color: backgroundColor ?? Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          foregroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
        ),
        child: _buildChild(context, isOutlined: true),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: textColor ??
            Theme.of(context).colorScheme.onPrimary, // This is the key fix!
        disabledBackgroundColor: Colors.grey[300],
        disabledForegroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildChild(context, isOutlined: false),
    );
  }

  Widget _buildChild(BuildContext context, {required bool isOutlined}) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? (backgroundColor ?? Theme.of(context).colorScheme.primary)
                : (textColor ?? Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      );
    }

    final Color finalTextColor = isOutlined
        ? (textColor ??
            backgroundColor ??
            Theme.of(context).colorScheme.primary)
        : (textColor ??
            Theme.of(context).colorScheme.onPrimary); // Use onPrimary color

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: finalTextColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: finalTextColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: finalTextColor,
      ),
    );
  }
}
