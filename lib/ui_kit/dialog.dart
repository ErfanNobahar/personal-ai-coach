import 'package:flutter/material.dart' as M;
import 'package:personal_ai_coach/ui_kit/ui_kit.dart' as U;
import 'package:flutter/widgets.dart';

class Dialog extends M.StatelessWidget {
  static Future<dynamic> show(Widget child, {required BuildContext context}) {
    return M.showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(child: child);
      },
    );
  }

  final M.Widget child;
  final M.Color? backgroundColor;
  final M.Color? color;
  final double maxWidth;
  final double maxHeight;
  final double radius;
  const Dialog({
    super.key,
    required this.child,
    this.color = U.Theme.secondaryButton,
    this.backgroundColor,
    this.maxWidth = 400,
    this.maxHeight = 400,
    this.radius = 22,
  });

  @override
  M.Widget build(M.BuildContext context) {
    return M.Dialog(
      backgroundColor: backgroundColor,
      constraints: M.BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: M.Container(
        decoration: BoxDecoration(
          color: color!.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}
