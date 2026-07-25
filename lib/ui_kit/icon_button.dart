import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class IconButton extends StatelessWidget {
  final String icon;
  final double size;
  final Color? color;
  final bool isPrimary;
  final void Function() onTapped;

  const IconButton({
    this.isPrimary = true,
    super.key,
    required this.icon,
    required this.onTapped,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        decoration: BoxDecoration(
          // border: BoxBorder.all(width: 1, color: U.Theme.secondaryButton),
          borderRadius: BorderRadius.circular(50),
          color: color ?? Colors.white.withValues(alpha: 1.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPrimary ? 19.0 : 9.0,
            vertical: 9,
          ),
          child: U.Image.icon(path: icon, size: size),
        ),
      ),
    );
  }
}
