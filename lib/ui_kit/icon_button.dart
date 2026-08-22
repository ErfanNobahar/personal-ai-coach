import 'package:flutter/material.dart';
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;

class IconButton extends StatelessWidget {
  final String icon;
  final bool isDisabled;
  final double size;
  final Color color;
  final bool isPrimary;
  final void Function() onTapped;

  const IconButton({
    this.isPrimary = true,
    super.key,
    required this.icon,
    required this.onTapped,
    required this.size,
    this.color = Colors.white,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTapped,
      child: Container(
        decoration: BoxDecoration(
          // border: BoxBorder.all(width: 1, color: U.Theme.secondaryButton),
          borderRadius: BorderRadius.circular(50),
          color: isDisabled ? color.withValues(alpha: 0.5) : color,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPrimary ? 19.0 : 10.0,
            vertical: 10,
          ),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: U.Image.icon(path: icon, size: size),
          ),
        ),
      ),
    );
  }
}
