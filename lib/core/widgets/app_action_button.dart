library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppColors.primaryDark,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.iconSize = 20,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w800,
    this.semanticsLabel,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          minimumSize: const Size.fromHeight(48),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium - 6),
            side: borderColor == null
                ? BorderSide.none
                : BorderSide(color: borderColor!),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: iconSize),
        label: Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
